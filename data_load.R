# =============================================================================
# Part 1/3: 데이터 로드 및 기본 클리닝 (CSV버전)
# =============================================================================
#.  여기에 있는 오류 수정함
#------------------------------------------------------------------------------
# 0. 환경 설정
#------------------------------------------------------------------------------
library(tidyverse)      # 데이터 조작
library(readr)          # CSV 파일 읽기 (한글 인코딩 지원)
library(writexl)        # Excel 파일 쓰기
library(janitor)        # 변수명 클리닝
library(lubridate)      # 날짜 처리

# 작업 디렉토리 설정 (사용자 환경에 맞게 수정)
setwd("/Users/youjinlee/Library/Mobile Documents/com~apple~CloudDocs/My R/Fever c claude/2017_2025_s")

# 출력 디렉토리 생성
dir.create("cleaned_data", showWarnings = FALSE)
dir.create("cleaned_data/original_cleaned", showWarnings = FALSE, recursive = TRUE)
dir.create("reports", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

cat("\n")
cat("╔═══════════════════════════════════════════════════════════╗\n")
cat("  Part 1/3: 데이터 로드 및 기본 클리닝 (CSV버전)            \n")
cat("╚═══════════════════════════════════════════════════════════╝\n\n")

#------------------------------------------------------------------------------
# 1. 데이터 로드 & 백업
#------------------------------------------------------------------------------
cat("=== STEP 1: 데이터 로드 (CSV 파일) ===\n")

# 1.1 통합 파일 로드 (Base + Nurse + Fever Including)

# 두 기간 데이터 병합
combined_1_raw <- read_csv(
  "base_result_nurse_fever_s.csv",
  locale = locale(encoding = "CP949"),
  show_col_types = FALSE
)

combined_2_raw <- read_csv(
  "base_result_nurse_fever(3.0)_s.csv",
  locale = locale(encoding = "CP949"),
  show_col_types = FALSE
)

# 컬럼명 통일 (병합 전 처리)
# 1. "이름" = "환자명" 통일
if ("이름" %in% names(combined_1_raw)) {
  combined_1_raw <- combined_1_raw %>% rename(환자명 = 이름)
  cat("  - combined_1: '이름' → '환자명' 통일\n")
}

# 2. "전원온병원" = "전원온 병원" 통일 (띄어쓰기)
if ("전원온병원" %in% names(combined_1_raw)) {
  combined_1_raw <- combined_1_raw %>% rename(`전원온 병원` = 전원온병원)
  cat("  - combined_1: '전원온병원' → '전원온 병원' 통일\n")
}

# 3. "퇴원일" = "퇴원일자" 통일
if ("퇴원일" %in% names(combined_1_raw)) {
  combined_1_raw <- combined_1_raw %>% rename(퇴원일자 = 퇴원일)
  cat("  - combined_1: '퇴원일' → '퇴원일자' 통일\n")
}

# 4. "노트"는 combined_1에만 있음 → combined_2에 추가
if (!"노트" %in% names(combined_2_raw)) {
  combined_2_raw$노트 <- NA_character_
  cat("  - combined_2: '노트' 컬럼 추가 (NA)\n")
}

# 5. ⭐ 데이터 
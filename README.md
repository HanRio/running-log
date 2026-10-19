# 런닝 크루 기록

지원서를 내고 운영자 승인을 받은 회원만 러닝 기록을 남기고, 회원끼리 서로의 기록을 볼 수 있는 모바일 웹이에요.

- **프론트엔드:** `index.html` 한 파일 (HTML + CSS + JS, 빌드 과정 없음)
- **데이터베이스·로그인:** [Supabase](https://supabase.com) (Postgres + Google 로그인)
- **배포:** [Vercel](https://vercel.com) (정적 파일 호스팅)

## 기능

| 상태 | 보이는 화면 |
|---|---|
| 로그인 전 / 지원서 없음 | -5kg 챌린지 참가 신청서 (6개 구역: 선수 등록, 운동 레벨, 유혹, 훈련 계획, 멘탈 체크, 결승선 너머 + 개인정보 동의). 로그인 전에 작성하면 제출할 때 Google 로그인 후 자동 접수 |
| 지원서 검토 중 / 거절 | "검토 중이에요" / "이번엔 함께하지 못해요" |
| 승인됨 | 기록 페이지 (내 기록 추가·삭제, 합계, 체중 공개 설정, 회원 피드) |

- 기록마다 날짜, 체중, 거리, 시간을 넣으면 페이스와 소모 칼로리(체중 × 거리 × 1.036)를 계산해요.
- **체중 공개를 끄면** 회원 피드에서 내 체중과 칼로리가 모두 "—"로 보여요. 칼로리로 체중을 거꾸로 계산할 수 있어서 둘 다 가려요. 거리, 시간, 페이스는 항상 보여요.
- 지원서 내용(연락처, 거주지, 건강 상태 등)은 본인과 운영자만 볼 수 있어요. 회원 피드에는 실명 대신 챌린지 닉네임이 보여요.
- 모든 접근 제어는 데이터베이스의 보안 규칙(RLS)이 맡아요. 회원은 자기 승인 상태를 바꾸거나 남의 원본 기록을 읽을 수 없어요.

---

# 직접 설치하기

처음부터 내 사이트로 띄우는 순서예요. 30분 정도 걸려요.

## 0. 준비물

**계정** (모두 무료 플랜으로 충분해요)
- GitHub
- Supabase (무료 플랜은 활성 프로젝트 2개까지)
- Google Cloud (Google 로그인용)
- Vercel

**컴퓨터에 설치할 것**
- [Node.js](https://nodejs.org) 18 이상 (Vercel CLI 실행용)
- [Supabase CLI](https://supabase.com/docs/guides/cli/getting-started)
- Vercel CLI
- (선택) [Docker Desktop](https://www.docker.com/products/docker-desktop/): 로컬에서 보안 테스트를 돌릴 때만 필요

macOS 기준 설치 명령:

```bash
brew install supabase/tap/supabase
```

```bash
npm install -g vercel
```

## 1. 코드 받기

```bash
git clone https://github.com/HanRio/running-log.git
```

```bash
cd running-log
```

## 2. Supabase 프로젝트 만들기

1. [Supabase 대시보드](https://supabase.com/dashboard)에서 **New project**를 눌러요.
2. 이름(예: `running-log`), **Database Password**, Region(한국 사용자면 `Northeast Asia (Seoul)`)을 정하고 만들어요.
3. **Database Password는 꼭 따로 적어 두세요.** 아래 3단계와 나중에 스키마를 바꿀 때 필요해요.
4. 만들어지면 주소창의 `https://supabase.com/dashboard/project/<프로젝트-ref>` 에서 **프로젝트 ref**(영문 20자)를 확인해요.

## 3. 데이터베이스 테이블 만들기

터미널에서 (브라우저가 열리면 로그인해요):

```bash
supabase login
```

```bash
supabase link --project-ref <프로젝트-ref>
```

비밀번호를 물으면 2단계에서 적어 둔 Database Password를 넣어요. 그다음 테이블과 보안 규칙을 올려요:

```bash
supabase db push
```

`Finished supabase db push.` 가 나오면 성공이에요. 대시보드의 **Table Editor**에 `profiles`, `runs` 테이블이 보여요.

## 4. index.html 에 내 프로젝트 연결하기

1. Supabase 대시보드 → **Project Settings → API** (또는 **API Keys**)로 가요.
2. **Project URL** 과 **anon public** 키를 복사해요. (`service_role` 키는 절대 쓰지 마세요.)
3. `index.html` 에서 아래 두 줄을 찾아 바꿔요:

```js
const SUPABASE_URL = 'https://<프로젝트-ref>.supabase.co';
const SUPABASE_ANON_KEY = '<anon public 키>';
```

anon 키는 브라우저에 공개되도록 만들어진 키라 코드에 넣어도 괜찮아요. 데이터 보호는 보안 규칙(RLS)이 해요.

## 5. Vercel에 배포하기

```bash
vercel login
```

```bash
vercel deploy --prod
```

처음 실행하면 프로젝트 이름 등을 물어요. 기본값으로 진행하면 돼요. 끝나면 `Aliased https://<이름>.vercel.app` 처럼 **사이트 주소**가 나와요. 이 주소를 6, 7단계에서 써요.

- `.vercelignore` 때문에 `index.html` 만 올라가요. `.env` 나 `supabase/` 폴더는 올라가지 않아요.
- GitHub 저장소를 Vercel 대시보드에서 **Import**해도 돼요. Framework Preset은 **Other**, Build Command는 비워 두세요.

## 6. Google 로그인 키 만들기 (Google Cloud)

1. [Google Cloud Console](https://console.cloud.google.com)에서 새 프로젝트를 만들어요.
2. **APIs & Services → OAuth consent screen** (또는 **Google Auth Platform → Branding**)
   - User type: **External**
   - 앱 이름, 지원 이메일, 개발자 연락처 이메일을 넣어요.
   - Scopes는 기본값(`email`, `profile`, `openid`)이면 충분해요.
   - **Audience / Publishing status를 "In production"으로 바꿔요.** "Testing"이면 테스트 사용자로 등록한 계정만 로그인돼요.
3. **APIs & Services → Credentials → Create Credentials → OAuth client ID**
   - Application type: **Web application**
   - **Authorized JavaScript origins:** `https://<이름>.vercel.app`
   - **Authorized redirect URIs:** `https://<프로젝트-ref>.supabase.co/auth/v1/callback`
4. 만들어진 **Client ID** 와 **Client Secret** 을 복사해요.

## 7. Supabase에 Google 로그인 연결하기

1. Supabase 대시보드 → **Authentication → Sign In / Providers → Google**
   - **Enable** 을 켜고 Client ID, Client Secret을 붙여 넣고 저장해요.
2. **Authentication → URL Configuration**
   - **Site URL:** `https://<이름>.vercel.app`
   - **Redirect URLs** 에 추가: `https://<이름>.vercel.app/**`

## 8. 동작 확인하고 첫 회원(나) 승인하기

1. 사이트에 들어가 **Google로 지원하기** → 로그인 → 지원서를 제출해요. "검토 중이에요" 화면이 나오면 정상이에요.
2. Supabase 대시보드 → **Table Editor → profiles** 에서 내 행의 `status` 를 `pending` → `approved` 로 바꾸고 저장해요.
3. 사이트를 새로고침하면 기록 페이지가 열려요. 기록을 하나 추가해 보세요.

## 운영하기: 지원자 승인

- 새 지원자는 **Table Editor → profiles** 에 `status = pending` 으로 쌓여요.
- 승인: `approved` / 거절: `rejected` 로 바꾸면 돼요. 지원자는 다음에 사이트를 열 때 바뀐 화면을 봐요.
- 회원 탈퇴 처리: **Authentication → Users** 에서 사용자를 지우면 지원서와 기록도 함께 지워져요.

## 문제 해결

| 증상 | 원인과 해결 |
|---|---|
| Google 화면에 `redirect_uri_mismatch` | 6단계의 Authorized redirect URI가 `https://<프로젝트-ref>.supabase.co/auth/v1/callback` 과 정확히 같은지 확인 |
| 로그인 후 `localhost:3000` 으로 이동 | 7단계 Site URL이 아직 기본값. Vercel 주소로 바꾸기 |
| "Unsupported provider: provider is not enabled" | 7단계에서 Google Provider를 켜지 않음 |
| 일부 계정만 로그인됨 | 6단계 Publishing status가 "Testing". "In production"으로 변경 |
| "문제가 생겼어요: permission denied…" | 3단계 `supabase db push` 를 하지 않았거나 다른 프로젝트에 했음 |
| 계속 "검토 중이에요" | 정상이에요. Table Editor에서 `status` 를 `approved` 로 바꾸기 |
| 화면이 안 바뀌고 콘솔에 Invalid API key | 4단계 URL과 anon 키가 같은 프로젝트 것인지 확인 |

---

# 개발자용

## 파일 구조

```
running-log/
  index.html                                   # 앱 전체. 상단에 SUPABASE_URL / SUPABASE_ANON_KEY
  supabase/migrations/20261019000000_init.sql  # 테이블, 보안 규칙(RLS), feed() 함수
  supabase/tests/rls_test.sql                  # 보안 규칙 테스트 20개 (pgTAP)
  supabase/config.toml                         # Supabase CLI 로컬 설정
  .vercelignore                                # index.html 만 배포
  .gitignore                                   # .env, .vercel, supabase/.temp 제외
```

## 데이터 구조

- `profiles`: 지원서 + 회원 상태. `status` (`pending` / `approved` / `rejected`), `weight_public`
- `runs`: 러닝 기록. `run_date`, `km`, `minutes`, `weight`
- `feed(max_rows)`: 승인된 회원의 기록을 돌려주는 함수. 체중 비공개 회원의 `weight` 는 `null`

회원이 브라우저에서 할 수 있는 일은 데이터베이스 권한으로 제한돼요: 지원서 1회 제출, 체중 공개 여부 변경, 승인 후 본인 기록 추가·삭제. `status` 변경은 대시보드(운영자)만 가능해요.

## 로컬에서 실행하고 보안 테스트하기 (Docker 필요)

로컬 Supabase 켜기 (처음엔 이미지 내려받느라 몇 분 걸려요):

```bash
supabase start
```

보안 규칙 테스트 20개 실행:

```bash
supabase test db
```

로컬 접속 정보(API URL, anon key) 보기:

```bash
supabase status
```

`index.html` 상단 두 값을 로컬 값(`http://127.0.0.1:54321` 과 로컬 anon key)으로 잠시 바꾼 뒤 페이지 띄우기:

```bash
python3 -m http.server 3000
```

로컬에는 Google 키가 없으니, 테스트 사용자는 `supabase status` 의 Studio(또는 Auth admin API)에서 이메일·비밀번호로 만들고, 브라우저 콘솔에서 `sb.auth.signInWithPassword({ email, password })` 로 로그인해 확인해요. 끝나면 끄기:

```bash
supabase stop
```

**배포 전에 `index.html` 의 두 값을 운영 값으로 되돌리는 것을 잊지 마세요.**

## 스키마 바꾸기

새 마이그레이션 파일 만들기:

```bash
supabase migration new <이름>
```

`supabase/migrations/` 에 생긴 파일에 SQL을 쓰고, 로컬에서 `supabase db reset` → `supabase test db` 로 확인한 뒤 온라인 DB에 반영:

```bash
supabase db push
```

예: 지원서에 항목을 추가하려면 ① 마이그레이션에서 `profiles` 에 컬럼 추가 ② `grant insert (...)` 에 그 컬럼 추가 ③ `index.html` 지원서 폼과 `insert` 코드에 필드 추가.

## 꾸미기

- 색: `index.html` 의 `:root` 변수. 지금은 포인트 `#DEFF24`(라임, 위 글자는 진한색), 배경 `#F3F3EE`, 카드 `#FFFFFF`, 통계 타일 `#1C1C1A`
- 레이아웃: 벤토 그리드 (design-isms `bento-grid`), 모바일 폭 최대 430px
- 칼로리 공식: `index.html` 의 `kcal` 함수

## 만들지 않은 것

관리자 승인 페이지(대시보드로 대신), 음식 칼로리, 차트, 알림. 필요하면 추가할 수 있어요.

---

# 원작자 운영 정보

- 사이트: https://running-log-sigma.vercel.app
- Supabase 프로젝트: `running-log` (ref `tmvleiyuwvnamtnibxgb`, 서울 리전)
- 남은 설정: 위 **6, 7단계** (Google 로그인). 아직 온라인에서 지원 → 승인 → 기록 흐름을 확인하지 않았어요.
- DB 비밀번호는 로컬 `.env` 에만 있어요 (Git·Vercel에 올라가지 않음). `supabase db push -p "$SUPABASE_DB_PASSWORD"` 로 쓸 수 있어요.

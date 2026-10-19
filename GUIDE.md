# 비전공자를 위한 설치 가이드

이 가이드를 따라 하면 **프로그램을 하나도 설치하지 않고, 웹 브라우저만으로** 나만의 "-5kg 챌린지 신청 + 러닝 기록" 사이트를 만들 수 있어요.

- 걸리는 시간: 40분 ~ 1시간
- 비용: 0원 (모두 무료 플랜)
- 필요한 것: 인터넷 되는 컴퓨터, Google 계정 하나

> 💡 처음 보는 단어가 나오면 맨 아래 **[용어 사전](#용어-사전)** 을 보세요.

---

## 전체 그림

이 사이트는 서비스 4개를 이어 붙여서 움직여요.

| 서비스 | 하는 일 | 비유 |
|---|---|---|
| **GitHub** | 사이트 코드를 보관 | 설계도 보관함 |
| **Supabase** | 지원서·기록 저장, 로그인 처리 | 창고 + 경비실 |
| **Vercel** | 사이트를 인터넷에 띄움 | 건물(가게) |
| **Google Cloud** | "Google로 로그인" 버튼을 쓸 수 있게 허락 | 출입증 발급처 |

진행 순서:

1. GitHub에서 코드 복사해 오기
2. Supabase에 창고(데이터베이스) 만들기
3. 코드에 내 창고 주소 적기
4. Vercel로 사이트 띄우기
5. Google 로그인 출입증 만들기
6. Supabase에 출입증 등록하기
7. 직접 지원해 보고 승인하기

**중간에 복사해 둘 값이 5개** 있어요. 메모장을 하나 열어 두고 하나씩 적으면서 진행하세요.

```
① Supabase 프로젝트 주소 (Project URL):
② Supabase 공개 키 (anon public key):
③ 내 사이트 주소 (Vercel):
④ Google Client ID:
⑤ Google Client Secret:
```

---

## 1단계. GitHub에서 코드 가져오기

GitHub은 코드를 보관하는 곳이에요. 원본을 내 계정으로 **복사(Fork)** 해 올 거예요.

1. https://github.com 에 들어가서 오른쪽 위 **Sign up** 으로 가입해요. 이미 계정이 있으면 **Sign in**.
2. 원본 주소로 가요: https://github.com/HanRio/running-log
3. 오른쪽 위의 **Fork** 버튼을 눌러요.
4. 다음 화면에서 아무것도 바꾸지 말고 초록색 **Create fork** 를 눌러요.
5. 주소가 `https://github.com/내아이디/running-log` 로 바뀌면 성공이에요. 이제 이 코드는 내 것이에요.

---

## 2단계. Supabase에 데이터베이스 만들기

### 2-1. 가입과 프로젝트 만들기

1. https://supabase.com 에 들어가서 **Start your project** → **Continue with GitHub** 으로 가입해요 (1단계 GitHub 계정으로 바로 가입돼요).
2. 조직(Organization)을 만들라고 하면 이름은 아무거나(예: 내 이름), Plan은 **Free** 로 만들어요.
3. **New project** 를 눌러요.
   - **Project name:** `running-log`
   - **Database Password:** **Generate a password** 를 눌러 자동으로 만들고, 옆의 복사 버튼으로 복사해 **메모장에 따로 저장**해요. (지금 가이드에서는 다시 쓰지 않지만, 나중에 필요할 수 있어요.)
   - **Region:** `Northeast Asia (Seoul)`
4. **Create new project** 를 누르고 1~2분 기다려요. 초록색 불이 들어오면 준비 완료예요.

> ⚠️ 무료 플랜은 **켜져 있는 프로젝트를 2개까지**만 만들 수 있어요. 안 만들어지면 안 쓰는 프로젝트를 Pause(일시정지)하세요.

### 2-2. 표(테이블) 만들기

사이트가 쓸 표(지원서 표, 기록 표)와 보안 규칙을 만들어요. 준비된 글을 복사해서 붙여 넣기만 하면 돼요.

1. 새 탭에서 내 GitHub 저장소(`https://github.com/내아이디/running-log`)를 열어요.
2. `supabase` 폴더 → `migrations` 폴더로 들어가요. 파일이 2개 있어요:
   - `20261019000000_init.sql` (첫 번째)
   - `20261019120000_challenge_application.sql` (두 번째)
3. **첫 번째 파일**을 눌러 열고, 오른쪽 위의 **Copy raw file** 버튼(네모 두 개 겹친 아이콘)을 눌러 전체를 복사해요.
4. Supabase 탭으로 돌아와 왼쪽 메뉴에서 **SQL Editor** 를 눌러요.
5. 빈 칸에 붙여 넣고 오른쪽 아래 **Run** 을 눌러요. 아래쪽에 `Success. No rows returned` 가 나오면 성공이에요.
6. SQL Editor 왼쪽 위 **+** (New query) 를 눌러 빈 칸을 새로 열고, **두 번째 파일**도 똑같이 복사 → 붙여넣기 → **Run** 해요.

> ⚠️ **반드시 첫 번째 → 두 번째 순서로**, 각각 **한 번씩만** 실행하세요. 두 번 실행하면 "already exists" 오류가 나요 (이미 만들어졌다는 뜻이라 괜찮아요).

7. 왼쪽 메뉴 **Table Editor** 를 누르면 `profiles`, `runs` 표가 보여요. 성공!

### 2-3. 주소와 공개 키 복사하기

1. 왼쪽 아래 톱니바퀴 **Project Settings** → **Data API** (또는 **API**) 를 눌러요.
2. **Project URL** (`https://영문자.supabase.co` 모양) 을 복사해서 메모장 **①** 에 적어요.
3. **Project Settings → API Keys** 에서 **Legacy API Keys** 탭의 **anon public** 키 (`eyJ...` 로 시작하는 긴 글자) 를 복사해서 메모장 **②** 에 적어요.

> 🔒 **service_role** 이라고 적힌 키는 절대 복사하거나 어디에도 붙여 넣지 마세요. 모든 권한을 가진 열쇠예요. **anon public** 키는 공개해도 되는 키라 괜찮아요.

---

## 3단계. 코드에 내 데이터베이스 주소 적기

지금 코드에는 원작자의 데이터베이스 주소가 적혀 있어요. 내 것으로 바꿔요. GitHub 웹사이트에서 바로 고칠 수 있어요.

1. 내 GitHub 저장소에서 `index.html` 파일을 눌러요.
2. 오른쪽 위 **연필 아이콘(Edit this file)** 을 눌러요.
3. 키보드 `Ctrl + F` (맥은 `Cmd + F`) 로 `SUPABASE_URL` 을 찾아요. 이런 두 줄이 있어요:

   ```js
   const SUPABASE_URL = 'https://tmvleiyuwvnamtnibxgb.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJhbGciOi...아주 긴 글자...';
   ```

4. **따옴표 `' '` 안의 글자만** 지우고 내 값으로 바꿔요.
   - 첫 줄 따옴표 안 → 메모장 **①** (Project URL)
   - 둘째 줄 따옴표 안 → 메모장 **②** (anon public 키)
5. 바꾼 결과는 이런 모양이어야 해요 (따옴표와 끝의 `;` 는 그대로):

   ```js
   const SUPABASE_URL = 'https://abcdefghijklmnopqrst.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJ내키...';
   ```

6. 오른쪽 위 초록색 **Commit changes...** → 다시 **Commit changes** 를 눌러 저장해요.

> ⚠️ 가장 흔한 실수: 따옴표를 같이 지우거나, 키 앞뒤에 빈칸이 들어가는 것. 따옴표 안에 값만 딱 들어가야 해요.

---

## 4단계. Vercel로 사이트 띄우기

1. https://vercel.com 에서 **Sign Up** → **Continue with GitHub** 으로 가입해요. (Hobby / 개인용 선택)
2. 대시보드에서 **Add New...** → **Project** 를 눌러요.
3. GitHub 저장소 목록에서 `running-log` 옆 **Import** 를 눌러요.
   - 목록에 안 보이면 **Adjust GitHub App Permissions** 를 눌러 `running-log` 저장소 접근을 허용해요.
4. 설정 화면에서:
   - **Framework Preset:** `Other`
   - 나머지(Build Command 등)는 **비워 두고** 건드리지 않아요.
5. **Deploy** 를 누르고 30초쯤 기다리면 축하 화면이 나와요.
6. **Continue to Dashboard** → 화면의 **Domains** 에 보이는 주소 (`https://running-log-xxxx.vercel.app`) 를 메모장 **③** 에 적어요.

> 💡 앞으로 GitHub에서 `index.html` 을 고치고 Commit 하면, Vercel이 **자동으로 1분 안에 사이트를 업데이트**해요.

이 시점에 주소에 들어가면 신청서가 보여요. 하지만 아직 **Google 로그인이 안 돼요.** 5, 6단계를 마저 해요.

---

## 5단계. Google 로그인 출입증 만들기 (Google Cloud)

가장 단계가 많지만, 순서대로 누르기만 하면 돼요.

### 5-1. 프로젝트 만들기

1. https://console.cloud.google.com 에 Google 계정으로 들어가요. 처음이면 약관에 동의해요. (결제 정보는 **필요 없어요.**)
2. 화면 맨 위 왼쪽의 프로젝트 선택 버튼 (`프로젝트 선택` 또는 `Select a project`) → **새 프로젝트(New Project)**.
3. 이름 `running-log` → **만들기(Create)**. 만들어지면 위쪽에서 그 프로젝트를 선택해요.

### 5-2. 동의 화면 (로그인할 때 사용자에게 보이는 화면) 설정

1. 위쪽 검색창에 `OAuth 동의 화면` (또는 `Google Auth Platform`) 을 검색해 들어가요.
2. **시작하기(Get started)** 를 누르고:
   - **앱 이름:** `-5kg 챌린지` (로그인할 때 사용자에게 보이는 이름)
   - **사용자 지원 이메일:** 내 이메일
   - **대상(Audience):** **외부(External)**
   - **연락처 정보:** 내 이메일
   - 동의 체크 → **만들기(Create)**
3. 왼쪽 메뉴 **대상(Audience)** → **앱 게시(Publish app)** → **확인**.
   상태가 **프로덕션 단계(In production)** 로 바뀌어야 해요.

> ⚠️ "테스트(Testing)" 상태로 두면 내가 등록한 몇 명만 로그인돼요. 꼭 **게시**하세요. 이 앱은 이메일·이름 정보만 쓰기 때문에 Google 심사가 필요 없어요.

### 5-3. 출입증(OAuth 클라이언트) 만들기

1. 왼쪽 메뉴 **클라이언트(Clients)** → **클라이언트 만들기(Create client)**.
   (예전 화면이면: **API 및 서비스 → 사용자 인증 정보 → + 사용자 인증 정보 만들기 → OAuth 클라이언트 ID**)
2. **애플리케이션 유형:** **웹 애플리케이션(Web application)**
3. **이름:** `running-log web` (아무거나)
4. **승인된 자바스크립트 원본(Authorized JavaScript origins)** → **+ URI 추가** → 메모장 **③** (내 Vercel 주소, 끝에 `/` 없이)
   예: `https://running-log-xxxx.vercel.app`
5. **승인된 리디렉션 URI(Authorized redirect URIs)** → **+ URI 추가** → 메모장 **①** 뒤에 `/auth/v1/callback` 을 붙여서 넣어요.
   예: `https://abcdefghijklmnopqrst.supabase.co/auth/v1/callback`
6. **만들기(Create)** 를 누르면 창이 떠요.
   - **클라이언트 ID** → 메모장 **④**
   - **클라이언트 보안 비밀번호(Client secret)** → 메모장 **⑤**

> 🔒 Client Secret은 비밀번호예요. 코드나 GitHub에 붙여 넣지 말고 6단계의 Supabase 칸에만 넣으세요.

---

## 6단계. Supabase에 Google 로그인 연결하기

### 6-1. Google 켜기

1. Supabase 대시보드 → 왼쪽 **Authentication** → **Sign In / Providers** (또는 **Providers**).
2. 목록에서 **Google** 을 눌러요.
3. **Enable Sign in with Google** 스위치를 켜요.
4. **Client ID** 칸 → 메모장 **④**, **Client Secret** 칸 → 메모장 **⑤**
5. **Save**.

### 6-2. 로그인 후 돌아올 주소 정하기

1. **Authentication** → **URL Configuration**.
2. **Site URL** → 메모장 **③** 으로 바꾸고 **Save**.
3. **Redirect URLs** → **Add URL** → 메모장 **③** 뒤에 `/**` 를 붙여 넣고 저장.
   예: `https://running-log-xxxx.vercel.app/**`

---

## 7단계. 직접 지원해 보고 승인하기

1. 휴대폰이나 컴퓨터로 내 사이트(메모장 **③**)에 들어가요.
2. 신청서를 끝까지 작성하고 **챌린지 참가하기 🔥** 를 눌러요.
3. Google 로그인 화면이 나오면 로그인해요. 사이트로 돌아오면서 **자동으로 접수**되고 "검토 중이에요" 화면이 나와요. 🎉
4. 이제 운영자(나)로서 승인해요:
   - Supabase → **Table Editor** → **profiles**
   - 방금 지원한 줄에서 `status` 칸을 더블클릭 → `pending` 을 `approved` 로 바꾸고 엔터 → 아래쪽 **Save** (화면에 따라 자동 저장)
5. 사이트를 새로고침하면 **러닝 기록 페이지**가 열려요. 기록을 하나 추가해 보세요.

다 됐어요! 이제 주소를 크루 단톡방에 공유하면 돼요.

---

## 운영하기

### 지원자 승인 / 거절
- **Table Editor → profiles** 에 새 지원서가 `pending` 상태로 쌓여요.
- 승인: `approved` / 거절: `rejected` 로 바꾸면, 지원자가 다음에 사이트를 열 때 바뀐 화면이 나와요.
- 지원서 내용(연락처, 거주지, 운동 계획, 건강 상태 등)도 이 표에서 볼 수 있어요. 오른쪽으로 스크롤하세요.

### 벌칙 투표 결과 보기
- Supabase → **SQL Editor** 에 아래를 붙여 넣고 **Run**:

  ```sql
  select penalty_vote, count(*) from profiles where status = 'approved' group by penalty_vote order by count desc;
  ```

  `fine`=벌금, `selfie`=셀카, `coffee`=커피, `squat`=스쿼트

### 회원 내보내기 / 챌린지 끝난 뒤 정보 파기
- **Authentication → Users** 에서 회원 오른쪽 `⋯` → **Delete user**. 그 회원의 지원서와 기록이 함께 지워져요.
- 신청서에 "모임 종료 후 파기합니다" 라고 약속했으니, 챌린지가 끝나면 꼭 지워 주세요.

### 회원 기록 보기
- **Table Editor → runs** 에 모든 기록이 있어요.

### 사이트 문구 바꾸기
- GitHub에서 `index.html` → 연필 아이콘 → 원하는 글자를 찾아(`Ctrl/Cmd + F`) 고치고 **Commit changes**. 1분 뒤 사이트에 반영돼요.
- 색은 `index.html` 위쪽 `--accent: #DEFF24;` 같은 줄을 바꾸면 돼요.

> ⚠️ 신청서 **항목을 새로 추가하거나 빼는 것**은 데이터베이스도 같이 바꿔야 해서 개발자 도움이 필요해요. 문구(설명, 예시 글)만 바꾸는 건 괜찮아요.

---

## 문제가 생겼을 때

| 화면에 보이는 것 | 이유 | 해결 |
|---|---|---|
| Google 화면에 **오류 400: redirect_uri_mismatch** | 5-3단계의 리디렉션 URI가 틀림 | `https://내프로젝트.supabase.co/auth/v1/callback` 과 **글자 하나까지** 같은지 확인 (끝에 `/` 없음) |
| 로그인 후 **localhost:3000** 이라는 접속 안 되는 화면 | 6-2단계 Site URL이 기본값 | Site URL을 내 Vercel 주소로 바꾸기 |
| **Unsupported provider: provider is not enabled** | 6-1단계에서 Google을 안 켬 | Google 스위치 켜고 Save |
| **이 앱은 Google에서 확인하지 않았습니다** 경고 | 정상 (작은 앱이라 심사 안 받음) | **고급 → (안전하지 않음)으로 이동** 을 누르면 진행돼요 |
| 나는 되는데 **친구는 로그인이 안 됨** | 5-2단계 앱 게시를 안 함 | Audience에서 **앱 게시(Publish app)** |
| 화면 위에 **문제가 생겼어요: permission denied** | 2-2단계 표 만들기를 안 했거나 다른 프로젝트에 함 | SQL Editor에서 파일 2개를 순서대로 다시 실행 |
| **문제가 생겼어요: Invalid API key** | 3단계에서 주소와 키가 서로 다른 프로젝트 것이거나 잘못 붙여 넣음 | 2-3단계 값을 다시 복사해서 3단계 다시 |
| 사이트가 하얗거나 아무 반응 없음 | 3단계에서 따옴표나 `;` 를 지움 | 3단계 예시 모양과 똑같은지 확인 |
| 제출 후 계속 **검토 중이에요** | 정상이에요 | 7단계 4번처럼 `approved` 로 바꾸기 |
| GitHub에서 고쳤는데 사이트가 그대로 | Vercel 반영 중이거나 브라우저 캐시 | 1~2분 뒤 새로고침 (`Ctrl/Cmd + Shift + R`) |
| Supabase 프로젝트가 **Paused** | 무료 플랜은 1주일간 아무도 안 쓰면 잠들어요 | 대시보드에서 **Restore project** |

---

## 용어 사전

| 용어 | 뜻 |
|---|---|
| **저장소 (Repository)** | GitHub에 있는 코드 폴더 하나 |
| **Fork** | 남의 저장소를 내 계정으로 통째로 복사해 오는 것 |
| **Commit** | 고친 내용을 저장하는 것 (저장 버튼) |
| **데이터베이스** | 지원서와 기록이 저장되는 엑셀 같은 표 묶음 |
| **SQL** | 데이터베이스에게 "표 만들어 줘" 같은 일을 시키는 글. 이 가이드에서는 복사·붙여넣기만 해요 |
| **anon public 키** | 사이트가 데이터베이스에 말을 걸 때 쓰는 공개용 열쇠. 공개돼도 보안 규칙이 막아 줘서 안전해요 |
| **service_role 키** | 모든 걸 할 수 있는 관리자 열쇠. **절대 공개 금지** |
| **OAuth** | "Google로 로그인" 같은 남의 계정으로 로그인하는 방식 |
| **Client ID / Secret** | Google이 "이 사이트는 Google 로그인을 써도 돼"라고 발급해 준 아이디와 비밀번호 |
| **리디렉션 URI** | 로그인 후 돌아올 주소 |
| **배포 (Deploy)** | 만든 사이트를 인터넷에 올려 누구나 들어올 수 있게 하는 것 |
| **RLS (보안 규칙)** | "자기 기록만 지울 수 있다", "승인된 사람만 기록할 수 있다" 같은 데이터베이스 규칙 |

---

## 더 알고 싶다면

- 개발자용 설명 (내 컴퓨터에서 실행하기, 보안 테스트, 명령어로 배포하기): [README.md](README.md)

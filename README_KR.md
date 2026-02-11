# Assetto Corsa 스킨 폴더명 정리 스크립트

[English](README.md)

Assetto Corsa 스킨 폴더명에서 영문/숫자를 제외한 모든 문자를 언더스코어(`_`)로 치환하는 PowerShell 스크립트입니다.

## 왜 필요한가요?

일부 Assetto Corsa 모드의 스킨 폴더명에 특수문자(공백, 유니코드, 기호 등)가 포함되어 Content Manager, 온라인 서버 등에서 문제를 일으킬 수 있습니다. 이 스크립트는 모든 스킨 폴더명을 안전한 `[a-zA-Z0-9_]` 패턴으로 정리합니다.

## 요구 사항

- Windows + PowerShell 5.1 이상
- Steam 기본 경로에 Assetto Corsa 설치

## 실행 권한 설정 (중요! 처음 한 번만 하면 됩니다)

Windows는 기본적으로 PowerShell 스크립트(.ps1 파일) 실행을 막아놓았습니다.
그래서 스크립트를 처음 실행하면 아래와 같은 **빨간색 오류**가 뜹니다:

```
.\rename_skins.ps1 : 이 시스템에서 스크립트를 실행할 수 없으므로 ... 파일을 로드할 수 없습니다.
```

이 오류가 뜨면 **아래 방법 중 하나**를 골라서 따라하세요.

---

### 방법 1: 영구 허용 (권장 - 한 번만 하면 끝!)

이 방법을 쓰면 앞으로 내 PC에서 PowerShell 스크립트를 자유롭게 실행할 수 있습니다.

**1단계:** 키보드에서 `Windows 키`를 누르고 **"PowerShell"** 을 입력합니다.

**2단계:** 검색 결과에서 **"Windows PowerShell"** 을 찾아 **마우스 오른쪽 클릭** → **"관리자 권한으로 실행"** 을 클릭합니다.

**3단계:** "이 앱이 디바이스를 변경할 수 있도록 허용하시겠어요?" 라는 팝업이 뜨면 **"예"** 를 클릭합니다.

**4단계:** 파란색 PowerShell 창이 뜨면, 아래 명령어를 **그대로** 복사해서 붙여넣고 `Enter`를 누릅니다:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**5단계:** 아래처럼 물어봅니다:

```
실행 규칙 변경
실행 정책은 신뢰하지 않는 스크립트로부터 사용자를 보호합니다. ...
[Y] 예(Y)  [A] 모두 예(A)  [N] 아니요(N)  [L] 모두 아니요(L)  [S] 일시 중단(S)  [?] 도움말(기본값은 "N"):
```

**`Y`** 를 입력하고 `Enter`를 누릅니다.

**6단계:** 아무 메시지 없이 다음 줄로 넘어가면 **성공**입니다! PowerShell 창을 닫아도 됩니다.

> 이제부터 `.ps1` 스크립트를 자유롭게 실행할 수 있습니다. 이 설정은 한 번만 하면 됩니다.

---

### 방법 2: 이번 한 번만 허용 (임시)

설정을 바꾸기 싫고, 지금 **딱 한 번만** 실행하고 싶을 때 쓰는 방법입니다.

PowerShell을 열고 (관리자 권한 필요 없음) 아래 명령어를 그대로 복사해서 붙여넣고 `Enter`를 누릅니다:

```powershell
powershell -ExecutionPolicy Bypass -File .\rename_skins.ps1
```

> 이 방법은 PC 설정을 전혀 바꾸지 않습니다. 대신 스크립트를 실행할 때마다 매번 이 긴 명령어를 입력해야 합니다.

---

### 방법 비교

| 방법 | 장점 | 단점 |
|---|---|---|
| **방법 1** (영구 허용) | 한 번만 설정하면 끝. 다음부터 `.\rename_skins.ps1`만 입력하면 됨 | 관리자 권한 필요, PC 설정이 바뀜 |
| **방법 2** (이번만 허용) | 설정 변경 없음, 관리자 권한 불필요 | 매번 긴 명령어를 입력해야 함 |

---

### 제대로 됐는지 확인하기

설정이 끝나면 아래 명령어를 입력해서 확인할 수 있습니다:

```powershell
Get-ExecutionPolicy -Scope CurrentUser
```

결과가 `RemoteSigned` 또는 `Bypass`라고 나오면 정상입니다.
`Restricted`라고 나오면 아직 설정이 안 된 것이니 위 방법을 다시 따라해 주세요.

## 사용법

```powershell
# 미리보기만 (실제 변경 없음)
.\rename_skins.ps1

# 실제 실행
.\rename_skins.ps1 -Execute

# 중복 발생 시 자동 번호 부여 (_1, _2, ...)
.\rename_skins.ps1 -Execute -AutoSuffix

# 중복 발생 시 원본 폴더 삭제
.\rename_skins.ps1 -Execute -OverlapDel

# 도움말 표시
.\rename_skins.ps1 -Help
```

## 옵션

| 옵션 | 설명 |
|---|---|
| `-Execute` | 실제로 폴더명 변경을 실행합니다. 없으면 미리보기만 표시됩니다. |
| `-AutoSuffix` | 이름 충돌 시 `_1`, `_2` 등 번호를 붙여 고유한 이름을 만듭니다. |
| `-OverlapDel` | 이름 충돌 시 원본 폴더를 삭제합니다. |
| `-Help` | 도움말을 표시합니다. |

> `-AutoSuffix`와 `-OverlapDel`은 동시에 사용할 수 없습니다.

## 동작 방식

1. Assetto Corsa `content/cars` 폴더 아래 각 차량의 `skins/` 하위 디렉토리를 스캔합니다.
2. 각 스킨 폴더명에서 영문/숫자 외 문자를 `_`로 치환하고, 연속된 `_`를 하나로 합치고, 앞뒤 `_`를 제거합니다.
3. 이미 정리된 이름은 건너뜁니다.
4. 이름 충돌은 선택한 옵션에 따라 처리합니다.

## 기본 경로

```
C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\content\cars
```

## 라이선스

[LICENSE](LICENSE) 파일을 참고하세요.

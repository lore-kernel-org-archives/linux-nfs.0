Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CB0B1DEFE8;
	Tue,  6 Oct 2026 15:24:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791300269; cv=none; b=KL8MqKG04tCTppGPmdWb7G4znAKGBCGJouhQWu2aIPJE60WtrbQD6m6eAYLnSIIo2+UyRWAAygXT/B79XEXs6m3LSmXhEzv/YDAdiXBUnOg+Esu3EQVEZruXnM40i92h6uTVE9JnHtfDUEyrB4EVMcKLoj9KooB0vcHIdJeflRg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791300269; c=relaxed/simple;
	bh=cQZRfzS2KhOMkAkgm8EaH2oFcdBoIYJioDuvAhj8GmY=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=ju5Ookx7CSuU8vA+k0uCVl2iUSkDk2g3NBNU7pInYDV6zxSVChrUYsaoFvCZpnmw5MLxIP9C6A0ERa2LTYTmmpH8/47m6fTFYOJ6IX63GLsWMZXaeA3+mgTUDjF9wa4t+WY7rcnVxLF39LsKz1xmQTzrCIiLFJyeA5A9j/akuI0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lD12VJ64; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lD12VJ64"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E856C1F0089B;
	Tue,  6 Oct 2026 15:24:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791300268;
	bh=2QqwhX9nYV+ydjceTGIVFqWwDaA6mKlrf3O2s0MXKBk=;
	h=From:Subject:Date:To:Cc;
	b=lD12VJ64apAUlEj0IsekoQ9A0UR5rU1AWK5MDj7zOcHDtLvjjl3YI3Gpfq4ph45RA
	 MUUwIqav0VLh7sASLhaNlnKtS/1wpRkN+lFNBDbq1Kp2YHXA80Q/YVAKfp9+LNQaWe
	 3VwN2+0gznJbiE5v5qFhGA+AMpFNJPbvmsbEBxpPPZyjY+EhpxM6Du/QaqYldy4aQE
	 gqqMYK2Wu1nnahMD4SQXnOOHV1wkJXfPZ5VhX+7upM/7fKm9IlUuVHL2vqH1xyQLzs
	 0Tzh7oXoftLtshgewz08LczChYwS9hV9CZY7mj3Y4/EHPqdfrNIXQw2empNSsGpMpV
	 sMWwlZJYeWLFw==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH RFC v3 0/5] NFS: isolate mTLS client credentials by network
 namespace
Date: Tue, 06 Oct 2026 11:24:01 -0400
Message-Id: <20261006-nfs-mtls-identity-v3-0-58a69fb107cc@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22OQQ7CIBBFr2JYiym0BXRlYuIB3BoXFKYtWqkBJ
 BrTu0urC026/H9m3psX8uAMeLRZvJCDaLzpbQr5coFUK20D2OiUEc0oy9aEY1t7fA2dTz3YYMI
 TZ4UiRc3qvBAapbubg9o8JuYRHfY7dPqU/l6dQYWRNq5V0gOunLSqHavIVzl2io2j1vjQu+f0V
 CQT5+sXM/5IcIbJmkPJhOZC8u0FnIVu1btmckf6g6DlHIImhJS51IRrzZT4QwzD8Abc8zEbKAE
 AAA==
X-Change-ID: 20260917-nfs-mtls-identity-04c14f6f348d
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, 
 Christian Brauner <brauner@kernel.org>, David Howells <dhowells@redhat.com>, 
 Sagi Grimberg <sagi@grimberg.me>, Eric Dumazet <edumazet@kernel.org>
Cc: linux-nfs@vger.kernel.org, keyrings@vger.kernel.org, 
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-doc@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2939; i=cel@kernel.org;
 h=from:subject:message-id; bh=cQZRfzS2KhOMkAkgm8EaH2oFcdBoIYJioDuvAhj8GmY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqxRKWgSzhVs+LcAfSOfiFfNuFF8HW/NXB3f5V6
 9GsqkJH18SJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasUSlgAKCRAzarMzb2Z/
 lxo8D/42lrs7+cvxdZNWhesO1iAldFm5m7vBoSFr1rL+HizOHrgNlKafdsqN0bZnPRqoBmPPbRT
 ts9wTUgtzRKcVfr2L0iJvvwhzKFNZwCcF0EMi8ZNsQUmED/Fa+0X3GgCkuKl+KR86CRVMcu9kvj
 RxNeMpyfOqob/8Uc6SXedRzxq8Nfid9iJDuBHCbmW6Aug1gv1fdMDBbtAapjrpH16HKPCvDtGuu
 +gzZOduL2+kRQ3iPXeHaxbpQ/0wfiEibTraUTyKJyCnu94+cmdHzCJJuRpviBoACHvQC1Pctmtb
 SJ+MfGa1VsfdKDx/bWAlFsYE0woyIvub1XCrECvij3KI/Y7S3ppVyNoUQ05yx7VsOUrhiwaJJwg
 KBg8xRVALvNCi4YeOtTRCpkZ9VEeBWeekVJk3MIPpIhot8eXjXov6piKLcdHF6ykuqtur2AGDoJ
 QEEp4wgYbQ57BvoI28Yoir8xGr3WDx5gm8DWHZGzrqoGwUqgIXE7t3/j3oKTvreQ7TYbjxrP/eE
 p0blVQt6j+xLUasqgmMGGVZvapJrPxHK4jzCmPRKAjCNlgboaECc6vqFpU0wdTcADFdBAZF1kuo
 T8omCGHSFnZztpUqwLXGfBfYrVtS3zqcTps2Beq8HIJE5Sqx7g7Nj1q5n9V+EdYfiBVnttJIK9C
 xMXjTiTT/3VAXZQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An xprtsec=mtls mount names its client certificate and private key
by keyring serial number. tlshd reads those keys with its own
credentials. Each key has to grant user read permission, and any
tlshd on the host that learns a serial number can read it.

The RFC thread asked whether the user or mount namespace is a
better binding than the network namespace. tlshd services the
handshake socket of one network namespace, so that is the namespace
tlshd already lives in.

  https://lore.kernel.org/linux-nfs/20260602154740.49861-1-cel@kernel.org/

After this series each network namespace has its own .nfs keyring,
and the keyring's serial number travels with each handshake (patches
3-4). Possessing that keyring lets tlshd read a key that does not
grant user read permission. tls_handshake_accept() and tlshd already
link a keyring named in the handshake. The handshake genetlink ABI
and the cert_serial= and privkey_serial= mount options are not
changed.

The owner of the network namespace's user namespace now owns the
keyring, so global root on the host cannot write to a container's
keyring from outside.

nfstlskey, the provisioning tool that consumes the key type, is in
https://github.com/linux-nfs/ktls-utils/ .

Tested on v7.3-rc4 plus this series, on one Fedora VM as both NFS
client and NFSD, with tlshd from ktls-utils 1.4.0.

---
Changes in v3:
- Rebased on v7.3-rc6
- No reviews received; stripped the "RFC" Subject prefix
- Link to v2: https://patch.msgid.link/20260925-nfs-mtls-identity-v2-0-aa3ad17dd6c8@kernel.org

Changes in v2:
- Write "serial number" rather than "serial" throughout (Randy)
- Give the .nfs keyring to the netns's user_ns owner (sashiko)
- Link to v1: https://patch.msgid.link/20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org

---
Chuck Lever (5):
      NFS: name the init_nfs_fs() error labels
      NFS: allocate the .nfs keyring per network namespace
      SUNRPC: pass a keyring serial number to the TLS handshake
      NFS: name the namespace .nfs keyring in the x509 handshake
      NFS: add a key type that reveals the namespace .nfs keyring serial number

 Documentation/filesystems/nfs/index.rst   |   1 +
 Documentation/filesystems/nfs/keyring.rst |  69 ++++++++++
 fs/nfs/client.c                           |   9 +-
 fs/nfs/fs_context.c                       |   1 +
 fs/nfs/inode.c                            | 211 ++++++++++++++++++++++--------
 fs/nfs/netns.h                            |   9 ++
 fs/nfs/nfs3client.c                       |   1 +
 fs/nfs/nfs4client.c                       |   1 +
 include/linux/sunrpc/xprt.h               |   1 +
 net/sunrpc/xprtsock.c                     |   1 +
 10 files changed, 248 insertions(+), 56 deletions(-)
---
base-commit: a90ee4305c4a5df72c11b31dacfdc76e00fcf78a
change-id: 20260917-nfs-mtls-identity-04c14f6f348d

Best regards,
--  
Chuck Lever <cel@kernel.org>


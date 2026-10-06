Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7956049CF4C;
	Tue,  6 Oct 2026 15:31:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791300678; cv=none; b=p8Yu9m89hzC8AD8BXTTqqMX0WTBEkBdrAAkn4HBvK5VaynVU+X2vXrG+7SOUI0WjZez1+1TDp3otUdwsn3e/KOeWfUjdwEIacP49fftvEo35Nt0LJ/PTU7SrG7aUO0knMHwOROY3w8lb2+WlM0W5NiLrKEpjIUeXngHHfV409fE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791300678; c=relaxed/simple;
	bh=F5B3CZTA65su7M8ff7YsR1a8Jb5cnIE6Zoa8egmFADc=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=n9AHIjb6tv4k3Py8DUXTQvXCjlmSXPKUK+/mb2hBpbZzmU5c3UnN9Gh3Cmyrj+4itmEqyOKgKvQCePAjvzTamn3WAxmBrYfUb0I6T5+hrFJ+KMEbG48veKBPEI6I4v/U20YJz8WvTNqsQ8S9N24yQpyochJCG6e2wfznMf+KtHA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=n1nB5XDQ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="n1nB5XDQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ACD871F0089B;
	Tue,  6 Oct 2026 15:31:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791300677;
	bh=Swn7cPNxeZeaH9+lQJyU84fhbw9MKElYXahSa5rMa54=;
	h=From:Subject:Date:To:Cc;
	b=n1nB5XDQeAv4op2oWJ8o2DQGELIp+MH/Gtf0Vd/khq/f2bSOVVDgwOJzRcfSqljjL
	 LpeUzgPrTPnqbr55HkD1IXS2s03A0gEILN3EghTOOHhAxSt7Ad3UZZGF2r16Qwi7xg
	 lq0jx8oMGFEXNwtbndHwgFs+UnT+fod6+z9HBr8UzOz7b7JkfYuDlXvHEskesuvwlS
	 JXi5hanMGHE29e/FaOxAJrOStJ3iBkwRxSkrjZLRMLcaj7gs9fdcfPeaSFnEFAYiTI
	 P4u4EK6QVB4lXWA1JZx73aIrHlWFpklzGPv9ZRpOcGj44//mpDhKtkYG5OeRDmgbtH
	 7nouALSfuPVrA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v4 0/5] NFS: isolate mTLS client credentials by network
 namespace
Date: Tue, 06 Oct 2026 11:31:11 -0400
Message-Id: <20261006-nfs-mtls-identity-v4-0-1fdf8cc65da7@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/23OTW7DIBAF4KtErEPEjw04q96j6gLDENMkuAKKa
 kW+eyFVolb18s3A9+aGEkQPCR13NxSh+OTnUEO33yEz6XAC7G3NiBEmyEAlDi7ha76kOoeQfV4
 w6QztnHC8UxbVfx8RnP+6m69vPzl9ju9gcoPai1EnwGPUwUxtVOSB42hEW00+5Tku93sKbcSjW
 m1UF4oJpoOEXigrlZYvZ4gBLoc5nlDrLuwXwfotglVCa64tldYKo/4R/ElQQsQWwSvRKy0GN1I
 ijflDrOv6Df8DLTRmAQAA
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3193; i=cel@kernel.org;
 h=from:subject:message-id; bh=F5B3CZTA65su7M8ff7YsR1a8Jb5cnIE6Zoa8egmFADc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqxRRDChWfWxzkw8FvxZf7RMzIgy2Ous9I+ecT9
 Bj+ws/tOS6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasUUQwAKCRAzarMzb2Z/
 l+GPEACuoGzlUyANfpnFrQBefFUvNcHO3RIAkCPoJb0WdjZzK+9CKaUIUkraGgk6j9InIFU8TO4
 vog21EXGu0tIDqpWQGAyjSOj1s3jlMGtRUeCF+9RF8bpSXgmIUU8HFP+++rX4oHwoNbYZZVFHV+
 gM/DE3VUkCOX6Nm7RdMPkKidRS14hdu9txjkTM6MZlSyhx4DLkXO4opvva+LVaP+IGBmVn0b0OW
 HC7kGULkZRwCwkhEk/nmrHw85qd8bYYsRl7WTK25aZEjfCoCwIRYwa7n1aircKpNTDYOKvT3gVP
 szBw0YuMWRhUE0W5bp7A5EcVkvzOVAiaNifsu6tw8VjKf8cNiTZEcOfkXnQ3yaop7mlBc56Cp8l
 o4goMhxneM7q13RFewgn93roxSk33Vm5brdK4ksuTLUK3VvhUlEG8oe9pqmiyFvrjVD8VnXkaoX
 GpiB1qd8Wrcf7/y00wsAyUecOF7ltUq3m9ZcJc4sYgJu+fBSJDd5dh1WhiawEt1xQz31tSw+HER
 YbyUo+Rto6ejjD9ZOmJDydT0QYPbhn4IQ0ebeXl7XPe/lVoSORVee7aR1hY+b/1+IJR5xRZ2w02
 0c+fDsZDGkZ1DW9c93QSZCBqj8rBrflCaJa959qLIrxVP6G9lH03IeASRtf3P5BxVNfuaSzzZb0
 NFa5JWkORvM5j4g==
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
Changes in v4:
- Repost in full; only part of v3 reached the list
- Drop the "RFC" Subject prefix that v3 carried by mistake
- No code changes since v3
- Link to v3: https://patch.msgid.link/20261006-nfs-mtls-identity-v3-0-58a69fb107cc@kernel.org

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


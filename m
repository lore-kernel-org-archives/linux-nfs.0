Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1F1336655C;
	Fri, 25 Sep 2026 19:16:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790363799; cv=none; b=pcSrscTK34iGD8cUJ+7N1N9VHmmFFyQVHF0w5sH0krbAQXnNiQd/4xIwAhbRGPpdGkv6i2MSwj3XD/cDofhdRqIXlosuTjQhhkLm21WtLcVLuqMXaGxgKZiRLLRg034OMOBASWdUm1dZixsgjm3XIKR6rquBDHUSVP1UvBFC4z8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790363799; c=relaxed/simple;
	bh=nyMpWEPFZh1yvWrMy+o3UY9J/iCI0gPVCFVoM29ZVXc=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=dqgpaz1HWbFfiwWJrOXSCsRAO+o3Dbyu1QwUJUzx0NZABTptb9yX3I1DYp87/034jSogt5rN4dSHrUMTKS0PR7PaAsTXMCLRRDrGuj5RLpSe4bhQd20YFuAz9JMrmLAI/tDfexRB6K+iQyO3DkMqZaw77aIYR9CGW0PfvF5RzFg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OsAtbxWV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OsAtbxWV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 280B61F000FF;
	Fri, 25 Sep 2026 19:16:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790363797;
	bh=HpN2OhOrodHkPWUvKj/Ar1FiMoNTYNdUdcV94TXSHHY=;
	h=From:Subject:Date:To:Cc;
	b=OsAtbxWVL0pnv1KZ0nMLwxyqW0xXWZLZwMoS70uV38d3OYc2tvZGCD/7lFQ2t+YCA
	 dYZ3eVOk9UlsBI5rzB2i73RO/aAhr9yWK/HMps/fE8RgYNNz2RJJztsJ6S6TmtxqGW
	 zUT2QvCVjtMpvEeqfpe/PwHPxGjFDqcaOtcLXiGLFvIzqLv1W+f9Vnwo59q/oVtGMK
	 PoMNzzF1fgnLLdvP+jSIJN0Ejz4GIuNC4/yiY1nO2sFTXvq4jdCNcqnTlKQUakMG9T
	 dj2OIQp8MgYvlJd1KRYJcSRdMZHCwxC3FjoPkYrXouFpHCA7H1Zz5oa5K+c4YhZAGg
	 DY45LJJYWQVHg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH RFC v2 0/5] NFS: isolate mTLS client credentials by network
 namespace
Date: Fri, 25 Sep 2026 15:16:22 -0400
Message-Id: <20260925-nfs-mtls-identity-v2-0-aa3ad17dd6c8@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22Oyw6CQAxFf8V07SiDyMOViYkf4Na4GKBAFQbTj
 kRj+HcZdOnynt7enDcIMqHAbvEGxoGEejuFcLmAojG2RkXllCEMwjjIdKJsJapzrUwcrSP3UkF
 U6KiKq02UljD93Rkres6bZzgdD3D5QnnkVyycX/O13AiqnI0tGo96pprsujPikP29IXE9v2azQ
 c9jP4n0j8SgVaB0luA2TsskNcn+hmyxXfVcw2Ucxw+MDUeV6gAAAA==
X-Change-ID: 20260917-nfs-mtls-identity-04c14f6f348d
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, 
 Christian Brauner <brauner@kernel.org>, David Howells <dhowells@redhat.com>, 
 Sagi Grimberg <sagi@grimberg.me>
Cc: linux-nfs@vger.kernel.org, keyrings@vger.kernel.org, 
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-doc@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3712; i=cel@kernel.org;
 h=from:subject:message-id; bh=nyMpWEPFZh1yvWrMy+o3UY9J/iCI0gPVCFVoM29ZVXc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqtsiJHKR24/pVxYQFtUWB/KXIfJEpSAsKRm5MS
 rEHQtw1eHCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarbIiQAKCRAzarMzb2Z/
 lwZgD/9QE9Jc4twnUjXcRAmZDaJEigYQSfTpENIGpn2rSDxaO14MIECid4BV2gTZfehuOoyaNO4
 5TQdmIUvjy3c9SlGGr3mxEJpr4iq2u3ucCpI1vKkGbN5KrSiyWIq/3klR3ABkMm5R9rBiFUuuZK
 vpjQYGBcIa6hb+cYJCvBJtZT6LsJWUB70wBhQvVsh4r08W9KaJ1uMh2ct7zXn9jdNIaADyA9kWp
 P0xZHMN392aECY01EV6HfR5P7Ie/vHSpkNKv+HaH39HY2/Za/zLKDdp5KRRZHoV/JnVU486JnD+
 AHX09Wgi0edCrTo5NQaCOkafT6tEmoiJ0n2SrTQJYWKzIw97RBndfscloJb7TFfCyNwiEVhb9rv
 9Mhn67z01zQa2/AzYzYYL2XPwOOqsFvkFaLL96ts1z863ChHqCnVeqkVC4d6ZwQdp3Xs5CjQ8ZF
 BUMFc027TQ3FPJg1QfhaQeBbc3j1rLrCXDDw6QeqQdil5TBD0Y6GKuy6bfx23vmiDNLsZyBi7Pl
 03Ew3mdsXnPql9R22f5tUquCtoSuSOKnBxOksu0rGpJiIYq9r07w4z3PoHYm4MWzxS1X4BPJmRi
 Qyp+bWk8/5N0Ukx0DWeVQoG8L2AeW9SFjgz4f2JezTLw/U2qymBxAA2RcM4Jy8YZMSyD9QI1oiR
 k0X+1fQolQEfT1A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An xprtsec=mtls mount names its client certificate and private key
by keyring serial number, and tlshd reads those keys with its own
credentials. Each key therefore has to grant user read permission,
and any tlshd on the host that learns a serial number can read it.
Nothing separates one network namespace's credentials from
another's.

This series makes the network namespace the isolation domain. The
RFC thread asked whether the user or mount namespace is the better
binding. tlshd services the handshake socket of one network
namespace, so that is the namespace it already lives in.

  https://lore.kernel.org/linux-nfs/20260602154740.49861-1-cel@kernel.org/

The keyring is held in struct nfs_net rather than found by name,
because /proc/keys is not namespace scoped. Its serial number
travels with each handshake instead (patches 3-4), and tlshd's
possession of that keyring is what lets a provisioned key grant no
user read permission at all. Both ends of the link exist today, in
tls_handshake_accept() and in tlshd. The handshake genetlink ABI and
the cert_serial= and privkey_serial= mount options do not change.

The keyring is owned by the owner of the network namespace's user
namespace, and grants no permission to anyone else. In a container
with its own user namespace, the container's root can provision the
keyring and its tlshd can link it, while global root on the host
cannot write to it without entering that user namespace. For a
namespace in the initial user namespace the owner is global root,
as before.

Still open is how userspace names the kernel-held keyring. Patch 5
prototypes a request_key type handled in the kernel and tagged
KEY_TYPE_NET_DOMAIN. A keyctl modeled on KEYCTL_GET_PERSISTENT, or a
read-only attribute on the netns-tagged nfs_client sysfs kobject,
would do the same job if the keyrings maintainers prefer one. Keys
that userspace adds are quota-charged by user namespace while the
keyring lives in nfs_net. Confirmation that this is sane when the
two boundaries differ would be welcome.

nfstlskey, the provisioning tool that consumes the key type, is
merged in https://github.com/linux-nfs/ktls-utils/ .

Tested on a v7.3-rc4 kernel carrying this series, on one Fedora VM
acting as both NFS client and NFSD, with tlshd from ktls-utils
1.4.0.

---
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
base-commit: aa98230e410f0ed212b6788c46b1e4d49e0ff7ca
change-id: 20260917-nfs-mtls-identity-04c14f6f348d

Best regards,
--  
Chuck Lever <cel@kernel.org>


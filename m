Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4A423A873C;
	Fri, 18 Sep 2026 14:05:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789740335; cv=none; b=p+cJdR9qYE6+J7kWip0xVYX1zvKmMpghCkOY23nN37uXxL9YN895sWqM8zd4FmU60CuJwjqFRu40F6DuFblHHUxLCDLQI8I0k/dkmvEWQ6UiCBu+u4MS1FuItsY/v0R8/j3mDqRAEA7A/h5qPuGp3HJ6eLXcPYUwEv8zvuGnHfw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789740335; c=relaxed/simple;
	bh=Bcwy+E6Oi4b2berfQyScAitGGyv5fqsNPnDcrsX0nZM=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=T4gwm4YC2PNDJsWhBHPazH4JrRtxBeG0YR2U2sh8KJb3xg9eJsk17lSSSoEISxFY+vqZiIf5ksVgnSQ4tYNwFb5UecDEcvQh+1vlGsecNDxP1b4U2sq8JjFFLwJpgDt99Ai4FwhW2LIXFMRFjM7rahX8RIP4vEsYpwKh6PNPNns=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LnTkSueR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LnTkSueR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 98B6E1F000FF;
	Fri, 18 Sep 2026 14:05:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789740333;
	bh=6poMYmfx2QCRu6OebYOQVuSs9AtiKnZz0sS56fkFvHI=;
	h=From:Subject:Date:To:Cc;
	b=LnTkSueRiZtJazx9N12EVScAkE9TOYSRbcSMyLVtqpVFDomLjrkXKXqwB51ooB/PY
	 3S/rIV6sXHh9BIGOF2ENXBrt8MMuZ0jqF0AZcLmv0dNG2vEzXGELqH6+KYrJftn4g/
	 AJY6HNrBn5LMYacAIc1Foua767Uj4lnFab/uw9EbL8TSacpKoVQ7CuzeCjYGJFOfqB
	 +86sqi0a1TCwapaLe2NMt4zB2fif8PR9kvkNqoutUsey0ZTv/S+M+B2lsfp7ajtHql
	 ntw0XJR0K5Dn3XC3S10Vi6r9XANmBNimsML2zVtzf1ehBi8JDy9S7k0LMpzO2NfZus
	 EarewJPihl3sw==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH RFC 0/5] NFS: isolate mTLS client credentials by network
 namespace
Date: Fri, 18 Sep 2026 10:05:15 -0400
Message-Id: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMywrCMBBFf6XM2kBSQ31sBT/ArbhI0okdsalkR
 lFK/91El+dw75mBMRMy7JsZMr6IaUoFzKqBMLh0RUV9YWh12+md2agUWY1y5+IxCclHaRuMjV1
 c220P5ffIGOn9a57hdDzA5S/56W8YpNbqzDtG5bNLYahqdCyYYVm+WtrzkZMAAAA=
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3117; i=cel@kernel.org;
 h=from:subject:message-id; bh=Bcwy+E6Oi4b2berfQyScAitGGyv5fqsNPnDcrsX0nZM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrUUh2otE4UaTM/4UNJvbzhYbfEh/zl+1BjUur
 mLLDfM8QIWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1FIQAKCRAzarMzb2Z/
 l1VBEACkGjBjcvS+UuHhBY7gD+YJfo1EWWJzk9olQk61PsAcxYmhEg93mXosFxeiQr8dn7UfaMA
 e2Xp4qNzcDoqNC0PbeYZQ+B5w0dDp744+PEewcdazX8ToJ7+6PuHVvgUe5cKnml4Uiht0BFLGgQ
 BSu6qhPSsVsgBhP2gvN/AyeusuO/rY/eWeliyR22W2oLdGhfdw++4gTfSeh44a2afzMVXdGJwjM
 i7AVXGvWAu7D5ksVCm5/hj8cLzuVH/wLQ/XXsHXf2hW6o4lVwIadS086XiOVCJSa6Y6u9D45Pyh
 Dpsy5P7UzAsqE8ZlyibJKfsMP6oTYj6SZicbaNvK40j/lse0ZbhK1kYs+AjsnVsk3E2pxBk80+/
 T/3MEguppu8cK2jO5oYTSK3hrTmtENwne/iAtgJjQusILaEmDwGgBtqRYEi5JCQnA466nQXHeUW
 Tw1uP7x44w3GBUbGrqyazMnMjs1Fc6GKtAIfEPINPqypOQeD1IbtO8cDRD9ro8iW9k9XhmI+egX
 uWWH9cviVl1g/Y1QCZgq9TQPB/r9fUvd00PpvDwacWzo9rnCBCLaQoTIT6PN9jcGngeRrRq7Fmb
 G9nNZfALfFdoqSQE3C/HWGzRRxYfed+ojzNt6gb2AHtrO1pez8lbHkezd20x3Y9cNZc/WwWvj6G
 ktgK8+0efSBKggA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An xprtsec=mtls mount names its client certificate and private key
by keyring serial, and tlshd reads those keys with its own
credentials. Each key therefore has to grant user read permission,
and any tlshd on the host that learns a serial can read it. Nothing
separates one network namespace's credentials from another's.

This series makes the network namespace the isolation domain. The
RFC thread asked whether the user or mount namespace is the better
binding. tlshd services the handshake socket of one network
namespace, so that is the namespace it already lives in.

  https://lore.kernel.org/linux-nfs/20260602154740.49861-1-cel@kernel.org/

The keyring is held in struct nfs_net rather than found by name,
because /proc/keys is not namespace scoped. Its serial travels with
each handshake instead (patches 3-4), and tlshd's possession of that
keyring is what lets a provisioned key grant no user read permission
at all. Both ends of the link exist today, in tls_handshake_accept()
and in tlshd. The handshake genetlink ABI and the cert_serial= and
privkey_serial= mount options do not change.

Still open is how userspace names the kernel-held keyring. Patch 5
prototypes a request_key type handled in the kernel and tagged
KEY_TYPE_NET_DOMAIN. A keyctl modeled on KEYCTL_GET_PERSISTENT, or a
read-only attribute on the netns-tagged nfs_client sysfs kobject,
would do the same job if the keyrings maintainers prefer one. Keys
that userspace adds are quota-charged by user namespace while the
keyring lives in nfs_net. Confirmation that this is sane when the
two boundaries differ would be welcome.

nfstlskey, the provisioning tool that consumes the key type, is
merged in https://github.com/oracle/ktls-utils/ .

Tested on one Fedora VM acting as both NFS client and NFSD, with
tlshd from ktls-utils 1.4.0: NFSv4.2 mounts with xprtsec=tls, with
xprtsec=mtls using the identity in tlshd.conf, and with xprtsec=mtls
using serials that nfstlskey provisioned.

---
Chuck Lever (5):
      NFS: name the init_nfs_fs() error labels
      NFS: allocate the .nfs keyring per network namespace
      SUNRPC: pass a keyring serial to the TLS handshake
      NFS: name the namespace .nfs keyring in the x509 handshake
      NFS: add a key type that reveals the namespace .nfs keyring serial

 Documentation/filesystems/nfs/index.rst   |   1 +
 Documentation/filesystems/nfs/keyring.rst |  67 ++++++++++
 fs/nfs/client.c                           |   9 +-
 fs/nfs/fs_context.c                       |   1 +
 fs/nfs/inode.c                            | 209 ++++++++++++++++++++++--------
 fs/nfs/netns.h                            |   9 ++
 fs/nfs/nfs3client.c                       |   1 +
 fs/nfs/nfs4client.c                       |   1 +
 include/linux/sunrpc/xprt.h               |   1 +
 net/sunrpc/xprtsock.c                     |   1 +
 10 files changed, 244 insertions(+), 56 deletions(-)
---
base-commit: df2908090cda368b01ff43709f51890076c56157
change-id: 20260917-nfs-mtls-identity-04c14f6f348d

Best regards,
--  
Chuck Lever <cel@kernel.org>


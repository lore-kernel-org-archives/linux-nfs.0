Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795490532;
	b=IZXco3nEnvIbIoVnCIN/4ByhH+tQCvUzEp++KWDMTrz6Z72YC69IQlWj2OsZzd9KIUI5
	 6JXjHOBsGsoEjAi5Nx8KSbGFYpRq2MlDHhXELvSRQ6evXZimziXUAh2614UZ1I5OxOoLN
	 n7QFd9zdm/Ge+B7IO322hpFwTFQras+mU9yDidtqjzf/HxkQKiIJwIyCS57KBnqIHTckG
	 uuBFGWySlI3Hjz2y4eJSqprjWqKAPu7Bem2+QYadHidy65lGCX+phdzgxfrALUixncswq
	 bzwaOqM7UQ4NblJMP8g7WuFWbBm9kvuGNRhfceJuyJuZO/70tH24tI+ajKIVMd/+z4A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795490532;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=UF/vrNKdeCXscBU4U717Ao0uSBj8CV2Xxs94+V1pjhc=;
	b=FkxMC65jwaigiPmQFEgnYsU6+AAJmy/ZTxdGqXQR9lkiMkrCJgAu1VpOEv+qKfqew2FX
	 fxIlU6cnEBIhzeqQr9371u76UjH2NZ9oocGBcaSMe9qHaQGlDanJYQVgFsw05s1H7j8aQ
	 g65efCT9JG6YoK8Ql773zVIhhkox7fm+7BBFclJnFNW4Fyee8sHCNh+WxzW3Ao0JT0tej
	 vZGReKzAA29LzW/r8RjLmrzk+d9dfpkPyLCVKKFvVTJdH3lXSjC+JKaQ08hsrUHVPCkKu
	 0wJrISy7vMzp1FyM3LfCPBaMTvsKrYBky/Pg07GUjABGug+XC0lhcPDH9FvG1jnGG9g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="T+YrSS/5";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 525A9606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 03:22:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T+YrSS/5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 02A781F000CA;
	Tue, 24 Nov 2026 03:22:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795490531;
	bh=UF/vrNKdeCXscBU4U717Ao0uSBj8CV2Xxs94+V1pjhc=;
	h=From:Subject:Date:To:Cc;
	b=T+YrSS/5zKL9ZdOELEG52yIUa6uFk1iOBiSK7E22Y6ITVtdfy3u8mNIga7BLe0YCG
	 5XyNcHzNuxNtDgOJnIKinqhpx1FVVMgPDsVM4Yxg6QGUi4E0L7pLD3gUCFqCr3FJml
	 8YxS4arDbQKOwPhbenk6a0p4JotseLtyZqm+yjIg6kz6WtnjOfGfGpHLVaHSZLwYj3
	 O6zKvAfBWOeo4uQdvhiTyfnbG479mpdiOq1U6gPmFersipg4tNEwP0eJbIxtMBfyqT
	 0Ld+1oac9vBytdeyFW1V1yptd1VREo6U6LecMJwMRykgSk3d7ABnrFU6oMWrBf35F+
	 mqPeg7nfubpAg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/7] SUNRPC: Harden the server-side RPC-with-TLS transition
Date: Mon, 23 Nov 2026 22:22:01 -0500
Message-Id: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMywrCMBBFf6XM2kETNaK/UlzkMW0ikpaZWAql/
 26iy3O552wgxIkEHt0GTEuSNOUK6tCBjzaPhClUBn3SRil9xnXmIuSRyS8o2c4Sp4IXY65a3YI
 KdwXVnZmGtP66/fPP8nEv8qXF2sNZIXRss49t8vQ+5kECFpKS8gj7/gXDIqUbnAAAAA==
X-Change-ID: 20261123-xprtsec-recv-snapshot-4665217d1d91
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2210; i=cel@kernel.org;
 h=from:subject:message-id; bh=H3sxHLjfffanbQT82BuxuPuP73B/mtFSGvXnP6JElR8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrBQLb01xF4d2pABGjhCU1p1y0rdQYZBj/nMu+a
 lPKb2/eHqSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawUC2wAKCRAzarMzb2Z/
 l/c2EACOBJnxauUHGERRhXNZzSmlkUgzPqp7PdJi+cZVODpPASUGcTCaJelXGf9hDYvG9Y/y4bh
 fXfO58mm0o/R8ivK5sBJHPOLdNvnZc6nVvz3QHD7+7bS3szKyvoVijtTewB3y7yykSGJ6hD+ro9
 JPOBGbUCg+Jw54MgEutVyIZoA3Qdh68iuH39NFsBcqVysppkWcBYh7uI7PkWewHpuXUaafXPqdH
 cWGwjtpZkiJn2y4wnI5UdBWzt89Qka8yUhdoGrI3U6wKYuLZ7X2LeaBMeEprDY8Z+65z0lzkujt
 HwcKkXKFMGSSdJ9vG8gc5hKtoevQoy5QRkDsoOCGZzeCZbXf7zU7nSy8eA+VCwheqTZ5GAiaP6w
 eoumlIEY6Rwb1MM2bi39zmv0IxHfr3ghX+2kX34bf98hvejNS7qT7B1hZ6HmOF+60VzdPzuw2q/
 a7pe96YfAJJLHV/S7sGFQH4gVRfi6anPskiJQE7TzWN6p5Qfw2iKCKApO0fnvQZRa2gE3EyP2iO
 u/WvdybfMR21YEQU9oE0JFPFS/B2SHdBrwI88719Z5CXpqNTwPlpy8TwBFbJGlXCarV1U1FRg/2
 TFR9Hoik/j9PJpYyaMq9KLCJnta30qdmyae1IxmGNOgr1mWx9fdY7o/6JtWsSiuMoiox0/LALOL
 tcYMBvOPk+A3dlg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_tcp_recvfrom() reads an AUTH_TLS probe and re-queues the transport
before svcauth_tls_accept() sets XPT_HANDSHAKE. In the meantime,
another nfsd thread can read the plaintext record that follows the
probe. If the request in that record is deferred until after the
handshake, check_xprtsec_policy() tests the request against the new TLS
session and grants access to an xprtsec=tls or xprtsec=mtls export. A
partial record read in the same window is completed from the decrypted
stream once the handshake finishes. Either way, an on-path attacker who
appends bytes to a client's probe can run a request under that client's
TLS identity.

Tested over loopback on arm64 with KASAN: NFSv3 and NFSv4.2 mounts in
each xprtsec mode against exports of each policy, 200 mount cycles each
with tls and mtls, and a CB_RECALL over an mTLS backchannel. A raw RPC
client sent a plaintext CREATE, a partial record, or a second probe
behind an AUTH_TLS probe nearly 1,800 times in all. NFSD never executed
the CREATE and closed every one of those connections.

---
Chuck Lever (7):
      SUNRPC: Do not read the socket once a TLS handshake is pending
      SUNRPC: Check for the backchannel first in svcauth_tls_accept()
      SUNRPC: Close the transport when a handshake finds a partial record
      NFSD: Check xprtsec policy against the state at receive time
      SUNRPC: Drop replies to plaintext requests on a TLS transport
      SUNRPC: Discard plaintext records that follow an AUTH_TLS probe
      SUNRPC: Reject an AUTH_TLS probe within an existing TLS session

 fs/nfsd/export.c                | 12 +++----
 include/linux/sunrpc/svc.h      |  6 ++++
 include/linux/sunrpc/svc_xprt.h |  1 +
 include/trace/events/sunrpc.h   | 11 ++++--
 net/sunrpc/svc.c                |  1 +
 net/sunrpc/svc_xprt.c           | 18 ++++++++--
 net/sunrpc/svcauth_unix.c       | 21 ++++++-----
 net/sunrpc/svcsock.c            | 78 ++++++++++++++++++++++++++++++++++++++---
 8 files changed, 125 insertions(+), 23 deletions(-)
---
base-commit: 194069b5ff38d82d302c33a4dd280d948c96cfe6
change-id: 20261123-xprtsec-recv-snapshot-4665217d1d91

Best regards,
--  
Chuck Lever <cel@kernel.org>


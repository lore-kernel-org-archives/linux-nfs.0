Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794597750;
	b=oKHprRDg70ecDUhzZ4jWuuqfZRnIIawS+lg7VB3SOCrzUAS1tYEBANvngpXgucsR1HKH
	 4sW4qfitVHpojoHM2bVEfFFKh5OSWE7LEYl/QPMc6DthoPRV7jic90pkLJ4XD9RvrZfQQ
	 mbo66+vwDTnM8qRClRGhl9Cl8yIB7hrDPoUp5qGNcpx89641TPhG75DTStm6DcDz2SZeV
	 h190In8UwgHeIf+CmR/cPHbsApSnZ9ap//S7h1l5ZeHK27qaAkRjxHxQd9SL7AmxyDrFJ
	 SLWIxfVkP/c2Cd5tgeo48/TOZVPkntRmY8ZT089WsYn4Sjhj7fEhrrsw0gdweIa/oIg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794597750;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=27YnK0mIQ1El2Ibmc5yNrcj3chHt28Bbq28AK8+7QzY=;
	b=3kdf6bXJbugZSAoxwgAoRtRmJkl0TB7ahrvB2ckByWCNtEoHxNJUPeNkNZOBcxvRejw2
	 b91T5rsagH5l2CRfGDh8XrIQliHtiCWcivLYeS+XAQKklLhzJT6h+wpB0RNa1MDASmB8o
	 PStNaheT7AxEeYzcxa3G1MLZ1Of+/WSqmK846uZ3RHh4xpeknQhT/n9wDVanFKQwnfs5+
	 64rdEsBz3nf76hq8WqVUw3Fc+W2wez679Cc6buyLcUqBBeqH0/c3XW+KYJBCFjz7w4OID
	 lLhLXbvdruBdNwegjvXGuKqgsp2GUYXO69Izhtsze0zfxTqHnMcQL6Bxh4DsLJLVqlg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KlhAfgSk;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45FA6606A333;
	Fri, 13 Nov 2026 19:22:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KlhAfgSk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BFBD41F000CB;
	Fri, 13 Nov 2026 19:22:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794597750;
	bh=27YnK0mIQ1El2Ibmc5yNrcj3chHt28Bbq28AK8+7QzY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KlhAfgSknztvukwtUVuJ4j0XUGXXOIKv+CK10gEqBB9F0rEXMkUxdDW0QSHwQni3w
	 2+tKxwJ3bI2rYjYYUzQMO2Qw/tFQXoH/qOnu2tVCoa5IsahBn8jO0jXsKeVTRH4WJZ
	 Fyq691QvRj9sFiiQpoXwtHI7spTEJ2u+f6KopaDvXkeN6QOxqc26V6oRXIZB0xReJg
	 LTCSXM6nXteFXWU2PN6386Y2SDxTyYm/YxgKYygEoU41cML0QgmmSdHYJchQw96nlt
	 cEf/uu5lsYsSJVvj0wJPFyJgPQpZYgfXYPVKWRfpJkDSInNvEG2Eui5X3tOMrhz6B5
	 vhWFic8ds75Gg==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:22:05 -0500
Subject: [PATCH net-next v3 07/10] handshake: Advertise the session-tag cap
 to user space
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
Message-Id: <20261113-tls-session-tags-v3-7-91271964cdb0@kernel.org>
References: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
In-Reply-To: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, 
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Eric Dumazet <edumazet@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3642; i=cel@kernel.org;
 h=from:subject:message-id; bh=6WJYNUk3mTi3dfWS3T6XBU0WWobsjkHpHjYrqsRESwM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92NfAsSMYH3NRNO9SX3JN7hMb+KnvWLpXw8gp
 perhWZplyOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdjXwAKCRAzarMzb2Z/
 l03BEACxkj2CK/fgunf5lIxUN98bAhN9vpWJnZQRqs8sUKUJZtPiyK3GJe0yybW5c0ST8IV2ced
 DYfthOGmQ6kEdOrlXAyZYVFU0JLFXV+kXE11ww0OJZuXW69CpHEZDjP4o5nuaWriojWa0PwvvEp
 qQl7SfCIHDvcwaCyq/gVnbgnH4uGw90G7dje0AD5g1bEt//RJsl/lzX0OqRJm8ogjFkesVpuSy+
 DhIqA8mIhf2k7rK9+l0+3mxTaXFnOonqig8JmykdGM22FYzkVWZPjL6x7GqKCkc/FuoxF8ZH115
 rbIgL1bJLHl+iRmmeDn8kjLunR9WN1qK7id8Vb5N5tThApSjHFU1p9mQ9mS/CclA6x8bU9tUD2d
 iTvIZrxkG6pQXHpNbkBJ3kU1J42XZqr70LlaUbUJwZxQQsX02QGNYlMUqh1NoxhCvb3VEBceEXN
 I1CkbBQet9UFKAZ3Oq+AQKztPgiSez04Qss8Qswt/bIO1vZ7FbZlzhV+89NHMsHZ4VrPn7wPRTz
 gyoytCL2LmfSKkNATWxXPMCvI29xy8UkSUYjJOOARybIbBrm0z+6RdV/HwnAzWwsX5TCibCqCEF
 ipsjEZ+SlczaGl79lUEG61LLC7eaCNF2txsBDHsxMdJyFI/0J88/pRF43Y5T1FdOdtzIA+rZWTR
 xYVwFvIp3MwsA4A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The kernel caps the number of session tags it accepts in a DONE
downcall at HANDSHAKE_MAX_SESSIONTAGS. tlshd has no way to learn
this cap. The value lives in include/net/handshake.h, not in the
UAPI header, so a daemon cannot size its tag list to it. An
over-cap list is truncated with one pr_warn_once per boot, which is
recoverable but easy to miss.

Carry the cap on every ACCEPT reply as
HANDSHAKE_A_ACCEPT_MAX_SESSION_TAGS, a u32 attribute populated by
the kernel. User space reads the value at ACCEPT time and can gate
its DONE-side tag list against it. A list longer than the cap then
becomes a user-space policy choice instead of a kernel-side
truncation.

An attribute lets the kernel raise the cap in a later release
without a new UAPI constant.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/netlink/specs/handshake.yaml | 4 ++++
 Documentation/networking/tls-handshake.rst | 8 ++++++++
 include/uapi/linux/handshake.h             | 1 +
 net/handshake/tlshd.c                      | 5 +++++
 4 files changed, 18 insertions(+)

diff --git a/Documentation/netlink/specs/handshake.yaml b/Documentation/netlink/specs/handshake.yaml
index 17521b159e89..f86490cd14c6 100644
--- a/Documentation/netlink/specs/handshake.yaml
+++ b/Documentation/netlink/specs/handshake.yaml
@@ -85,6 +85,9 @@ attribute-sets:
       -
         name: keyring
         type: s32
+      -
+        name: max-session-tags
+        type: u32
   -
     name: done
     attributes:
@@ -136,6 +139,7 @@ operations:
             - certificate
             - peername
             - keyring
+            - max-session-tags
     -
       name: done
       doc: Handler reports handshake completion
diff --git a/Documentation/networking/tls-handshake.rst b/Documentation/networking/tls-handshake.rst
index eb8cfe3367cb..ca8f06973fac 100644
--- a/Documentation/networking/tls-handshake.rst
+++ b/Documentation/networking/tls-handshake.rst
@@ -272,3 +272,11 @@ If the handshake failed or no tags were assigned, the stringset is
 empty. The handshake layer always delivers a finalized stringset to
 the callback, so consumers may call stringset_is_member() and
 stringset_intersection() unconditionally without a separate guard.
+
+The stringset delivered to the consumer may contain fewer tags than
+the handshake agent assigned. The kernel caps the per-DONE tag
+count at HANDSHAKE_MAX_SESSIONTAGS, and individual tags within
+the cap may be dropped under memory pressure. The kernel reports
+the cap in every ACCEPT reply as
+HANDSHAKE_A_ACCEPT_MAX_SESSION_TAGS, so the agent can size its
+DONE-side tag list to it.
diff --git a/include/uapi/linux/handshake.h b/include/uapi/linux/handshake.h
index bbb9ea2fa4fb..a22393527342 100644
--- a/include/uapi/linux/handshake.h
+++ b/include/uapi/linux/handshake.h
@@ -52,6 +52,7 @@ enum {
 	HANDSHAKE_A_ACCEPT_CERTIFICATE,
 	HANDSHAKE_A_ACCEPT_PEERNAME,
 	HANDSHAKE_A_ACCEPT_KEYRING,
+	HANDSHAKE_A_ACCEPT_MAX_SESSION_TAGS,
 
 	__HANDSHAKE_A_ACCEPT_MAX,
 	HANDSHAKE_A_ACCEPT_MAX = (__HANDSHAKE_A_ACCEPT_MAX - 1)
diff --git a/net/handshake/tlshd.c b/net/handshake/tlshd.c
index a9c5e5bedced..ec050058805a 100644
--- a/net/handshake/tlshd.c
+++ b/net/handshake/tlshd.c
@@ -238,6 +238,11 @@ static int tls_handshake_accept(struct handshake_req *req,
 			goto out_cancel;
 	}
 
+	ret = nla_put_u32(msg, HANDSHAKE_A_ACCEPT_MAX_SESSION_TAGS,
+			  HANDSHAKE_MAX_SESSIONTAGS);
+	if (ret < 0)
+		goto out_cancel;
+
 	ret = nla_put_u32(msg, HANDSHAKE_A_ACCEPT_AUTH_MODE,
 			  treq->th_auth_mode);
 	if (ret < 0)

-- 
2.56.0


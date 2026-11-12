Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794495157;
	b=cW28MRJ0ndrMwc/fEHgMWB0mGgEPeq3MUFXlMJkc8UkBSmjhbEIDcqlWzRMZZeHbU9EE
	 EgUdszTkxfDvKkCzeDFRcZdUSQJSijFw/aPHiun2kiqSbZRlUjrXfiSpjtUyDmkQxFGsC
	 nOO1RnadPydIFI+C5qw4rSzmtQW1tObzFs4p2Fldlf2VhaSOw8voREF/oBczvl7Nh1Yh/
	 GmZc5/PPiiJ1Ug8aCJulfMIhBmtdS+v3AR4f3v2abUR6nnJ0x8lxuUKvpW/1lspoLraW7
	 9F+D8K7LFEufz20r445ccYaKCpkz47wjVOzi94vgLn98ESf1S5da51tvDd0NXPpEEVA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794495157;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=27YnK0mIQ1El2Ibmc5yNrcj3chHt28Bbq28AK8+7QzY=;
	b=ns/TGt3nziLMCaR9dUDsOIn7Kb+gN58beu+kn6XCDnXw20OgeoTSQYQrGnLGlXC7b4Tr
	 Bm7w8gtFT6ghShO3+ijissjtQnxns7zdQds6ulPoEdGeg3ZWhZfG4qOrtG731374hj4EK
	 lL/bSRTILLehq45wsn2EcjWprkWxU06x50UwtXcylEoIQ7C4jsMR1KkLiRX88oxti/99J
	 +8Z+AqrFIhblLgCcFjJcGWLrBRDoYD/bti+hincViHsqH3YRz+xGmnz1d9MXuzjepK0xX
	 Z3BShOWZ2i4aER21pWGS2vWAqd6rPk2oXbkDZprjGzHk57AzcHXWIPmQXNJkltkJasg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=d9DqX3np;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DEF6606A32D;
	Thu, 12 Nov 2026 14:52:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=d9DqX3np
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A18BD1F00A06;
	Thu, 12 Nov 2026 14:52:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794495156;
	bh=27YnK0mIQ1El2Ibmc5yNrcj3chHt28Bbq28AK8+7QzY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=d9DqX3npg7c9thjD/nFj9vkWGpy8Scl4HjvUz4i3Zc/4IBJpRf6JmB5/3gBD2rdR8
	 cBgLZplfjl3DWBs63orMdBLHModOWdzY/YX8dDMGoKD+OqrLMUdW+oiF6t7dCUkOtG
	 Z2NhRewZ7idxdL6fLHfSG6sGrdVOq+tC5b3KfT2YDuDNBNL7+8b5BWsxNXQC0msERR
	 W3s2mbrKaGxlVSRmOQBOMDObm47CzTzqIPCWv7MQv3ANxdK7Oo2+3p0OjiEOU2f+pH
	 1Fg11RXXtrou1+zvJnKvv7a96elt+l/HqfvH8VdR0xjUE+ah6qAbJUEvRjL/YRiT5z
	 m7/1mdBfCogvA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 09:52:11 -0500
Subject: [PATCH net-next v2 07/10] handshake: Advertise the session-tag cap
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
Message-Id: <20261112-tls-session-tags-v2-7-a587a50de7fc@kernel.org>
References: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
In-Reply-To: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
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
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9dKgPAu00EyZMiug6EzJN+CfNXB2t/tGDY39s
 FiITKqGPXCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavXSoAAKCRAzarMzb2Z/
 l0Y1D/9m4JP2gyCPgit1MJB3KfWCxCv80IL/9m1EfD+K+QWMTZIA7U1YZ1ikM12kQHE7NSWbGtL
 QYNl5rW59mY5bvhIckWiyj7Posie2o+Ba21k+dUxnOAbYUMsnK7HUfvmnb3Is9oGSi3I8a42rtL
 pcGP2oAGtaFe3w4Max2YTW5HhAiFOzQWiFsS2xrtDBemxVNldg/gJaGBZ6h56BYfuBGEjkIa1Mf
 IUSrfpvP3pq9B12GGixMkLCuL1pn0x5bsLTlQEgbm40iSow10kdK3xcsTqgTgaMKKW6QtZOnuIJ
 Er/xhwk+Af8mA8bGFxIfTBvxdBHaow6FoL/ATL2V20AvuXuIcTr3LHSfqt12x95WIujz1Yo8nd+
 aDh4df3eZCs7FGHmA90mXapHN0cBKxnv3r2xctGCjP5N8ku5Uo9qOVLeUraL6jCrSQ5s545Xeti
 ZN6DciTgNFuAzZQRfBJ1vOpapLpotQZKZokm4S5kJUGFCLMqvBpbLQm0hZi3+AvZ8bjouXwpopn
 Mo/2aZERQ5NNKOfEscjRsrwg9LFXFXSWeXWSLq/o3cJ1voa/I07oP5SLDuRMLb7r8IW0UVbaKuk
 pKfhrJZ24RrnOIyo+kfBBcSc8MAb5Q5KtUBWcAP8zBzRIqPIv3S6abddYHuwmZvaMyhuvrKXXVO
 09VDOGLuoaUbq+Q==
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


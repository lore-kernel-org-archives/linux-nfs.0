Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EF3A38C41E;
	Fri,  5 Jun 2026 17:34:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780680898; cv=none; b=oB/E9fpMWlvSePns21fJGzx7rTdXTnLYJPaMXP4eXkEA3GlnvuSAB+/GaK6mEMflpyMDLDtxU2QXoOiD5qmHXGcjdQGlKF6sDk8rPvs1gi4IY/3cWYTtAkmqrp167Vr9HsJvKBrSv7pGb7Nt1k6K1HBt5/OZpA5SaIQ0n+ziVg8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780680898; c=relaxed/simple;
	bh=UCXrX+vIyOZ0h24OX73cnYfWMBefZ/c2qqexeBh0eig=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=giIiVWm1pbCTUHwVzoIWsaFCohtzZNXumoz9aZIo+SjQ8MywhmWffWJZEfIUoxa+sBzz+sT/iPx+ah5+80NtIGo1nKBqoDPE+TTGjMEWlJn5D6FA5HzMCLHS8M4E2sC4HabBa942snnX8dKeARPs2sxNOq/1Ylpc9iekhWmjgaM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gJX8afqz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gJX8afqz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 525751F00898;
	Fri,  5 Jun 2026 17:34:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780680895;
	bh=Lmt81ZJHUa9/Dy6f3u38aR8njR9hQTHsWXL/TFPponw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gJX8afqz0uqYEU8NTxdKthKjD42R/Og2SA1zSDvdk/mwPSWUkuv8ctgrA/v6y8Fnz
	 uSL6Yo/sURdL1Apf0Qj4lEqm1bPEs7NYoKhrHr53yml88n/S5MRBNYL2niiox8EPV7
	 7wC3EqPoknULhb54TcKLcUzZvO6Ah5vNlh1x7xsNrtxaDCMMPibK+N1fZAOJpSm8+p
	 4WBC5p3r7UaOVX2uZWQcfBVx+DkO0gLU1o5PUa1Crr3WdatPUlbXhLk0miHHJ+21WS
	 Q/uGFSggU7LxPkt1Cv2aaHlf+y5pW8r1sMmwRkw/7pYzsZjoV10aD9z8DqmGVd7JKi
	 29TeY6GUSkkrA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 05 Jun 2026 13:34:40 -0400
Subject: [PATCH 6/9] handshake: advertise the session-tag cap to user space
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260605-tls-session-tags-v1-6-47bd1d94d552@oracle.com>
References: <20260605-tls-session-tags-v1-0-47bd1d94d552@oracle.com>
In-Reply-To: <20260605-tls-session-tags-v1-0-47bd1d94d552@oracle.com>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Andrew Morton <akpm@linux-foundation.org>, 
 John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, 
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3686;
 i=chuck.lever@oracle.com; h=from:subject:message-id;
 bh=eZItOmbD+o1elSmdVDo5Cpkih6J8F7WbYVZN0wVN2Wc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqIwi46v9p2d3+oScL92LFAH+aBZmPUTrpjbdUx
 QZENJg5n66JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaiMIuAAKCRAzarMzb2Z/
 l8nTD/4uSiHlj6Cz6mSsMFmjFvakzWG2R/ch+YmuoqNZQnatoAbEaZo/QQLm+vSkGAZv/F53ump
 4zwM2/8C77XJGGOx4ayEjl5hlf2pbqGBpfjpEFLHgsn4aJ7AIQnvEGj7jP257IUH6Wc46QAG6sq
 HrLHLOfJYazJv2wTqP/rSqdpQGgIHNJPY94TccBwBULX6le+2BK/dJKXJVRv5Bl814N/tXntvhz
 Gd7jqkQHK5vtOZ4dK4Z14r8v4C/mVUXIJ1MWVpPHwx2rpkX2kCC7PsluYdHmj0Tnw5+sRXXBbl+
 5DN2LybUrw9Ci0C2EkZdvgR0ORLwnH1+GHbHZyaw73EhiLn5HL2fSQ1LIj5hZdWnn/wwKA+XqDZ
 Q5cCfQVBDbgggnocuW4bU1HfxN5qQd9Gne6lwuVLT6n7nMT1fEEYO5BCBWDMYh67PJFhqEAb6pM
 AVMJltShhe5cJawqobo6RwBe5fJAL4eQ1XqzImRNOlB4KX8l4tmTgbTGBHH83p3mpFimik+E4Ex
 1QoE7aTOjJZ/y5/g0kihXSHLHQreFaygh4IslcpB2gGTo6JgCyGNsXSxf02eBebHZXGKUjqjgcx
 4aG5dinbKF5n7tw/YKtxBPIT8HSSvGKkI4GM4Ogk9cznWQYlNkPFA1uSgoZ+OOrV/KMSn3EifBq
 muz11En0zZzC7zg==
X-Developer-Key: i=chuck.lever@oracle.com; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: Chuck Lever <chuck.lever@oracle.com>

The kernel caps the number of session tags it accepts in a DONE
downcall at HANDSHAKE_MAX_SESSIONTAGS. tlshd has no way to learn
this cap today: a daemon built against newer UAPI headers than
the running kernel silently overruns it, and the kernel truncates
the list with one pr_warn_once per boot. Truncation is
recoverable but the underlying misconfiguration is easy to miss.

Carry the cap on every ACCEPT reply as HANDSHAKE_A_ACCEPT_MAX_TAGS,
a u32 attribute populated by the kernel. User space reads the
value at ACCEPT time and can gate its DONE-side tag list against
it, turning over-cap into a user-space policy choice rather than
a silent kernel-side truncation.

Putting the cap in the ACCEPT reply keeps a single source of
truth and lets the kernel raise it in a later release without
bumping the daemon's UAPI header dependency.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 Documentation/netlink/specs/handshake.yaml | 4 ++++
 Documentation/networking/tls-handshake.rst | 7 +++++++
 include/uapi/linux/handshake.h             | 1 +
 net/handshake/tlshd.c                      | 5 +++++
 4 files changed, 17 insertions(+)

diff --git a/Documentation/netlink/specs/handshake.yaml b/Documentation/netlink/specs/handshake.yaml
index df36ff7da18f..614d31bee656 100644
--- a/Documentation/netlink/specs/handshake.yaml
+++ b/Documentation/netlink/specs/handshake.yaml
@@ -78,6 +78,9 @@ attribute-sets:
       -
         name: keyring
         type: u32
+      -
+        name: max-tags
+        type: u32
   -
     name: done
     attributes:
@@ -123,6 +126,7 @@ operations:
             - certificate
             - peername
             - keyring
+            - max-tags
     -
       name: done
       doc: Handler reports handshake completion
diff --git a/Documentation/networking/tls-handshake.rst b/Documentation/networking/tls-handshake.rst
index 352842a74e6b..ea2e090a1ed8 100644
--- a/Documentation/networking/tls-handshake.rst
+++ b/Documentation/networking/tls-handshake.rst
@@ -273,4 +273,11 @@ empty. The handshake layer always delivers a finalized tagset to
 the callback, so consumers may call tagset_is_member() and
 tagset_intersection() unconditionally without a separate guard.
 
+The tagset delivered to the consumer may contain fewer tags than
+the handshake agent assigned. The kernel caps the per-DONE tag
+count at HANDSHAKE_MAX_SESSIONTAGS, and individual tags within
+the cap may be dropped under memory pressure. The cap rides on
+every ACCEPT reply so the agent can size its DONE-side tag list
+to it; see Documentation/netlink/specs/handshake.yaml.
+
 See Documentation/core-api/tagset.rst for the complete tagset API.
diff --git a/include/uapi/linux/handshake.h b/include/uapi/linux/handshake.h
index 1ed309e475b4..1445983e7369 100644
--- a/include/uapi/linux/handshake.h
+++ b/include/uapi/linux/handshake.h
@@ -49,6 +49,7 @@ enum {
 	HANDSHAKE_A_ACCEPT_CERTIFICATE,
 	HANDSHAKE_A_ACCEPT_PEERNAME,
 	HANDSHAKE_A_ACCEPT_KEYRING,
+	HANDSHAKE_A_ACCEPT_MAX_TAGS,
 
 	__HANDSHAKE_A_ACCEPT_MAX,
 	HANDSHAKE_A_ACCEPT_MAX = (__HANDSHAKE_A_ACCEPT_MAX - 1)
diff --git a/net/handshake/tlshd.c b/net/handshake/tlshd.c
index 9bcaeba74f8c..eae4a4a0a9ef 100644
--- a/net/handshake/tlshd.c
+++ b/net/handshake/tlshd.c
@@ -238,6 +238,11 @@ static int tls_handshake_accept(struct handshake_req *req,
 			goto out_cancel;
 	}
 
+	ret = nla_put_u32(msg, HANDSHAKE_A_ACCEPT_MAX_TAGS,
+			  HANDSHAKE_MAX_SESSIONTAGS);
+	if (ret < 0)
+		goto out_cancel;
+
 	ret = nla_put_u32(msg, HANDSHAKE_A_ACCEPT_AUTH_MODE,
 			  treq->th_auth_mode);
 	if (ret < 0)

-- 
2.54.0


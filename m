Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B9884A2A62
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 20:20:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788294004; cv=none; b=kowAgj3vWkR+1O5wV2xkp5v0JQC10buB2I0bacRX/a3iq07bDZONrDDNZ/Ws/N0wdmPM3yHB+xbS8ifJOESxA/CnAZ4mQsocVG/wOeQJCJKbHjWj3KGKgmhuIU3qWXC12fLdrxHV3dBXrNTHTnw4hHapRYXYeGFBOGgOJnHo37Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788294004; c=relaxed/simple;
	bh=wZ4AS6SxQXuwfyXnJXgKQS8NkrLF+8yVWKvZBEaJyVc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=HTBprQnsH7fT4C8CkDZUtSeer2aCSF7zygbsTjhMkVgzfwxYS9dyHwjYPVdQCY0MUWVeK/swoBHphZA1Uhn9NIgd1Z4sfjrf7Vu0Kld7Q72p4FpZddKwOQu4dxQ99cWMIIppF+bVmYTvRfTNGBPGQwW2vXB08f8FWZLAGnf6EDc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HJv795kd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HJv795kd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7EA5B1F00A3A;
	Tue,  1 Sep 2026 20:20:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788294003;
	bh=wxOAltMg+6yG/Aa1L/WpkDV8Pz9HUfYbJiSl0okfHc4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HJv795kdu2jbXZ52SoolvUXKADmU3ugmoaOGYzmtHypdHbmGrm403Gq25mWrcaLTO
	 6GcMW4K5Ix/wk8qlMkRWjbHaFaVL7rpHcDbmobgeuUp9ZI7fJVveYpY4T3z8BNYWCl
	 MQpThZQtGskeoUQ60TQy9HEYz5NX0Rl0XlYt2zs6exe6rpsuuRe/O/m/2hb4ulN946
	 WxlVjf1zbBedTCGOziuQ4z+GDPUL4N7C5z6bgBMyIGJ0UgkbzlN4qoGENPIGnCuIlT
	 i/jxnOqgV3dA9/hzf2NBk7vikF/ss71RwCHr/jiJFZF7r2sqeYCyANrdwqaRUQVzpt
	 9sO20Xig4Gi2A==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 01 Sep 2026 16:19:46 -0400
Subject: [PATCH v2 6/8] NFSD: Set nn->cld_net before registering the cld
 pipe
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-alemi-v2-6-e163f94a3a6e@kernel.org>
References: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
In-Reply-To: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Scott Mayhew <smayhew@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1613; i=cel@kernel.org;
 h=from:subject:message-id; bh=wZ4AS6SxQXuwfyXnJXgKQS8NkrLF+8yVWKvZBEaJyVc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlzNr1zrXLBWEDSzSJ25lUg3pD8MDoiVqu44lQ
 nuJY8UpJeOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapczawAKCRAzarMzb2Z/
 lzYnEACJBTre+7qUyDVzwZHbZpKIPNPDJ8oocfk4Sd6UfYFHo4PKMi1Ti8bXQOUBmREKI4V7gXe
 CCeMdtNJqOzqOZ6T4H0W3JOvOaa3xzU7c0yAG6MBVgIq2/PildMbngDuMsfEd+CgLC0uNpQZk4s
 3yawsR7WzMQmI9+vNmSo6j4zOSWT+Tr4JVB1ok4Q1HJ9k5cz2sXj1jx9Jf8d+ylQSh/r5wmKwUP
 7XEuiEtufnW8P8mqSnGm9kcfFFjFCh85tpC8UmBdTd6ox0HphWDeFBwEcR2yI3bN0zkthCQlWj2
 e7LL1kHw/icgi4rnRqv2edCC0mjVuJpPiF2zEqhKEyrZB2AaosqgbNCyX/t5HkQXyrVDTzbGTuD
 ZXtALrvfBz1JT/ZRmdlz4e1FuWK8g91YT9SfdfBI3FuKrBdwTMpbOcG5ERpodAW0DdAhGXt2bmu
 rOBB5A/NRYf5r371E0Ifa2bL++wkal4g19nFAhXpgySsUqNc3s9QxjoKEiaOD8KrkPtTZK7jPDn
 iGW6cPNaUKNHVFj8IRjUxTyBBbsz9aDdOKqB51OG9qIUHrgzvvfcqb+jTBZRJhOG8jmzs9noW4a
 jdsjtKJ9ingv4XqW71HqRPvoOf1BVcSSmEtRTEO5VpIHpReE5Yiu/aMAw/k9g0FgM9aNGHCH6iP
 jtUGxw0MEJaZDcg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

rpc_mkpipe_dentry() instantiates the pipe's dentry before it returns,
so the cld pipe can be opened as soon as nfsd4_cld_register_net() has
run. __nfsd4_init_cld_pipe() does not store the new cld_net in
nn->cld_net until after that call. cld_pipe_downcall() reaches the
cld_net only through that pointer and takes cn_lock without checking
it, so a write() that lands in the window oopses.

Store nn->cld_net once @cn is fully initialized and before the pipe is
registered, and clear it again when registration fails.

Fixes: f3f8014862d8 ("nfsd: add the infrastructure to handle the cld upcall")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4recover.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 8af935ed0c4e..1a9ea6393740 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -941,18 +941,24 @@ __nfsd4_init_cld_pipe(struct net *net)
 	}
 	spin_lock_init(&cn->cn_lock);
 	INIT_LIST_HEAD(&cn->cn_list);
+#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
+	cn->cn_has_legacy = false;
+#endif
+
+	/*
+	 * The pipe's methods reach @cn through nn->cld_net, so set
+	 * it before the pipe can be opened.
+	 */
+	nn->cld_net = cn;
 
 	ret = nfsd4_cld_register_net(net, cn->cn_pipe);
 	if (unlikely(ret))
 		goto err_destroy_data;
 
-#ifdef CONFIG_NFSD_LEGACY_CLIENT_TRACKING
-	cn->cn_has_legacy = false;
-#endif
-	nn->cld_net = cn;
 	return 0;
 
 err_destroy_data:
+	nn->cld_net = NULL;
 	rpc_destroy_pipe_data(cn->cn_pipe);
 err:
 	kfree(cn);

-- 
2.54.0


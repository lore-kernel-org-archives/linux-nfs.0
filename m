Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79A7B449EB8
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 03:49:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792381787; cv=none; b=KK/fWwDYmJSifnz9z1RFgBANGA2GyjvpvA4n/QwO5ib9fvAnIzw1GRTEMRFl48mtWptYcHKbuN02MZn5bB+iWdIOWDzUs+/qH1iB312O+jtTR6oiFj9uq1uaGBTWbegQf5PbyJOWAmhqN2w/329d/y7o/Xp53eBAgl3BCITKCjc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792381787; c=relaxed/simple;
	bh=Rc0rtw98330olCXuWrerwM/gtVYdNhCfNO7m7fODKMQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pjJBtiQEec42NC2Vna9IuRvTLlbVO/eXL9xR8YLX5sajPAMz4+Vvek16wbo05bXPdxGV03+izGFpO/EedlJZ482OjZuB73s3Y3fRIN2/iuGXTRHyOvJPjRyJq0lpj6uQvJXlt78KC5Nhe8tRuPrYw8cK+GEuWkFsmTDfzSU5TdQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=oEeXJZRL; arc=none smtp.client-ip=209.85.128.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oEeXJZRL"
Received: by mail-wm1-f45.google.com with SMTP id 5b1f17b1804b1-4a018792ab3so11482075e9.0
        for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 20:49:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792381785; x=1792986585; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=gLP09gfxsdDIc/q/EDWd5kMOmE8V5HDp5Pekpaep0vw=;
        b=oEeXJZRLY5Q1Xg0k7iM0ex5otSf0n7UGdiLrADQA4mW3C9MkyrvN6oE+3Ju7ozpjNj
         3krgk2dqhpZ0uowxAqYhhyc37qflT4wG1+p3fFPaIjAugMhpwxDbWFYqgUFsfgJfDX0P
         Tp+iqFeNtGQDMpWDgIemnyt9N/L7zRK2ZWgAZvuKvEkAOEbIP8j2WgzqbzSaOoOPQV7F
         nLOIfXwCKmwinvM8tXK1I0oE2M7mfs+dkDF17e3mI3QCu4YrFoEDkFkYp6nB13qIkfS9
         q2pznLPVJnZsmiYOJ+6ZPQ6eVnGwAYemMH1H6uJnRNG7Kx2gYA4gM8/+cx0F5qS/kS80
         pY6w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792381785; x=1792986585;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gLP09gfxsdDIc/q/EDWd5kMOmE8V5HDp5Pekpaep0vw=;
        b=GHT2/K6ysF3Ut1uzTp6/OmSvyVp5STHAVaottOg+QRVGTpreCHOcd9b8icWnPsqGhl
         VfF79ili1XHb1CT9SJoL5lUcgIRXS1sRqOO3aqSkInoV4n4poh1CvrH8CjJp5NpSqONF
         h0JGoFRiaEN3T2iAa6JGghT1ZWmg9Id2qLSWo4q3R0ORJr5wjXYtx4T7KtgqMYo8rvtA
         HjI0t/ByYTmiCLQOPDxnbcA5nkUZsHNm4pXcyjpMkUL0PoDQIcEAoijKqRZ0vO/f8EIm
         qtxG4WwUL7YRpqJRsLs/bmt+n8E9ME81UMhtSXfdh4mRwCjuHL4XSuwoYsOnOJwg41sW
         k/fA==
X-Gm-Message-State: AFq9FYI8kkfE27eYiJNVtMzbdedjLyw8Mbiir4a5R4SqqmwyGx757RJg
	czuAILwKUy2om/Ad3lnHIbnVkSaeIlhXM+/FuWekdFXcia1VwMzbNIPu1+21QlWA
X-Gm-Gg: AYBFou0IQDkB24WIICCvPdff4RJtxQgBKoefUz9aQ1+vUKipTPgGNVqcfsR6cjnAOgw
	mGzLL2BZs9B+S6+eFVN6cSFuQabN1Lkl4zCOkUmdLPRtHXcIr9F9cJU8id0rNZndU5Agb5ahJhQ
	Ng4MnDcuXLjGNCZbo01QaK8tQlu4RgWFdof6KNfi6Avpsc/ttQyWYceh1SFGdxPW/9jOohh9+mP
	yL4wb/OxvlwXDKCHBO21j54v4fgSb/s5Ez00aK7bnV2qtnbbKb9QrlxSlpDuOJLazu5/FBSef+I
	mlZjM3bb0iywdaozivkYQsOW2HxKD2fWyEvFwq+JaoR1slLzElKhDL6Lp+okuZMRkFyV2fzDXuo
	ClwMj4q0tgRB7IqeqIxTMRArJ4Lo7R2GMWeEtP2+EIh/6udiF1Ex3cSa+oWBlySYM30lfbaQ1fX
	F7Xc0NzABehZgEgO9yRdt6gPA5jxzxdqG6Sa0jN9c/21D0zeCd/OuSRN2bf2jvTwZnIHveQcKio
	5HvgoVVfhP4RECZIKGH1szNi+w6ntzBeqstyhBtYIm4GK13KVj2Cdj5uW/D8e6mU6/XkenLLf1l
	i5PktnSKL1RmYGr7
X-Received: by 2002:a05:600c:4e94:b0:4a0:1a7f:2abf with SMTP id 5b1f17b1804b1-4a1d75e3996mr127574245e9.7.1792381784530;
        Sun, 18 Oct 2026 20:49:44 -0700 (PDT)
Received: from center.jhjvjihww5qejoy14qwv1cc4td.frax.internal.cloudapp.net ([131.189.143.225])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a1e8ef76fbsm25056185e9.0.2026.10.18.20.49.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 18 Oct 2026 20:49:44 -0700 (PDT)
From: Orgad Shaneh <orgads@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com
Subject: [PATCH rpcbind RESEND] rpcbind: bind the TCP listeners to the -h addresses too
Date: Mon, 19 Oct 2026 03:49:43 +0000
Message-ID: <20261019034943.3805918-1-orgads@gmail.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

-h restricts only the datagram transports: tcp and tcp6 still bind to
the wildcard address, so rpcbind answers on every interface over TCP
even when -h names loopback and a single internal address. A host that
uses -h to keep rpcbind off its external interfaces gets that only for
UDP.

When -h is given, take the stream transports through the same
per-address loop as the datagram ones (AF_LOCAL ones have no address
and keep their own path), with the SO_REUSEADDR and listen() that the
wildcard path already does for them. Without -h nothing changes.

Assisted-by: Claude:claude-opus-5-5
Signed-off-by: Orgad Shaneh <orgads@gmail.com>
---
RESEND: unchanged, no reply in two weeks; it still applies to master
(dd1d77b, 1.3.1).
v1: https://lore.kernel.org/all/20261006083746.353335-1-orgads@gmail.com/
 man/rpcbind.8 |  2 +-
 src/rpcbind.c | 15 ++++++++++++++-
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/man/rpcbind.8 b/man/rpcbind.8
index 15b70f9..03b5514 100644
--- a/man/rpcbind.8
+++ b/man/rpcbind.8
@@ -85,7 +85,7 @@ checks are shown in detail.
 .It Fl f
 Do not fork and become a background process.
 .It Fl h
-Specify specific IP addresses to bind to for UDP requests.
+Specify specific IP addresses to bind to for UDP and TCP requests.
 This option may be specified multiple times and can be used to
 restrict the interfaces rpcbind will respond to.
 When specifying IP addresses with
diff --git a/src/rpcbind.c b/src/rpcbind.c
index c39df97..1215c73 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -535,7 +535,13 @@ init_transport(struct netconfig *nconf)
 		hints.ai_socktype = si.si_socktype;
 		hints.ai_protocol = si.si_proto;
 	}
-	if (nconf->nc_semantics == NC_TPI_CLTS) {
+	/*
+	 * With -h, bind the stream transports to the given addresses too,
+	 * not only the datagram ones; AF_LOCAL transports have no address.
+	 */
+	if (nconf->nc_semantics == NC_TPI_CLTS ||
+	    (nhosts > 0 && strcmp(nconf->nc_netid, "local") != 0 &&
+	     strcmp(nconf->nc_netid, "unix") != 0)) {
 		/*
 		 * If no hosts were specified, just bind to INADDR_ANY.  Otherwise
 		 * make sure 127.0.0.1 is added to the list.
@@ -621,6 +627,11 @@ init_transport(struct netconfig *nconf)
 			}
 			addrlen = res->ai_addrlen;
 			sa = (struct sockaddr *)res->ai_addr;
+			if (nconf->nc_semantics != NC_TPI_CLTS &&
+			    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on,
+				       sizeof(on)) != 0)
+				syslog(LOG_ERR, "cannot set SO_REUSEADDR on %s",
+				    nconf->nc_netid);
 			oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
                         if (bind(fd, sa, addrlen) != 0) {
 				syslog(LOG_ERR, "cannot bind %s on %s: %m",
@@ -673,6 +684,8 @@ init_transport(struct netconfig *nconf)
 				(void) free(uaddr);
 			}
 #endif
+			if (nconf->nc_semantics != NC_TPI_CLTS)
+				listen(fd, SOMAXCONN);
 			my_xprt = (SVCXPRT *)svc_tli_create(fd, nconf, &taddr, 
                                 RPC_MAXDATASIZE, RPC_MAXDATASIZE);
 			if (my_xprt == (SVCXPRT *)NULL) {
-- 
2.53.0


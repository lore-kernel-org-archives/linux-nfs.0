Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33657 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965716AbbDXA1v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 20:27:51 -0400
Received: by wiax7 with SMTP id x7so23748832wia.0
        for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2015 17:27:50 -0700 (PDT)
From: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/7] getrpcport: rephrase host lookup
Date: Fri, 24 Apr 2015 02:27:41 +0200
Message-Id: <1429835262-16861-7-git-send-email-rep.dot.nop@gmail.com>
In-Reply-To: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
References: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most folks seem to copy this gentoo patch to silence an alleged
_FORTIFY_SOURCE=2 warning:
http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/net-libs/libtirpc/files/libtirpc-0.2.1-fortify.patch?diff_format=s&revision=1.2&view=markup

Given that gethostbyname is obsolescent, let's just use getaddrinfo
instead (to silence warnings about the OB function).

I am undecided if setting AI_V4MAPPED and AI_ADDRCONFIG is a good idea.
Personally i would be inclined to s/if 0/if 1/ but i'll leave that up to
you.

Signed-off-by: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
---
 src/getrpcport.c | 37 +++++++++++++++++++++++++------------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/src/getrpcport.c b/src/getrpcport.c
index b452c99..f36158d 100644
--- a/src/getrpcport.c
+++ b/src/getrpcport.c
@@ -48,19 +48,32 @@ getrpcport(host, prognum, versnum, proto)
 	int prognum, versnum, proto;
 {
 	struct sockaddr_in addr;
-	struct hostent *hp;
+	struct addrinfo hints, *result, *rp;
+	int ret = 0;
 
 	assert(host != NULL);
-
-	if ((hp = gethostbyname(host)) == NULL)
+	memset(&hints, 0, sizeof(struct addrinfo));
+	hints.ai_family = AF_INET; /* ??? :-( */
+#if 0
+#ifdef AI_V4MAPPED
+	hints.ai_flags |= AI_V4MAPPED;
+#endif
+#ifdef AI_ADDRCONFIG
+	hints.ai_flags |= AI_ADDRCONFIG;
+#endif
+#endif
+	if (getaddrinfo(host, NULL, &hints, &result) != 0)
 		return (0);
-	memset(&addr, 0, sizeof(addr));
-	addr.sin_family = AF_INET;
-	addr.sin_port =  0;
-	if (hp->h_length > sizeof(addr))
-	  hp->h_length = sizeof(addr);
-	memcpy(&addr.sin_addr.s_addr, hp->h_addr, (size_t)hp->h_length);
-	/* Inconsistent interfaces need casts! :-( */
-	return (pmap_getport(&addr, (u_long)prognum, (u_long)versnum, 
-	    (u_int)proto));
+	for (rp = result; rp != NULL; rp = rp->ai_next) {
+		assert (rp->ai_family == AF_INET && rp->ai_addrlen == 16);
+		memcpy(&addr, rp->ai_addr, rp->ai_addrlen);
+		assert (addr.sin_family == AF_INET && addr.sin_port == 0);
+		/* Inconsistent interfaces need casts! :-( */
+		ret = (pmap_getport(&addr, (u_long)prognum, (u_long)versnum,
+		    (u_int)proto));
+		if (ret)
+			break;
+	}
+	freeaddrinfo(result);
+	return (ret);
 }
-- 
2.1.4


Return-Path: <SRS0=DdpP=YD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04C7DC4360C
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Oct 2019 12:47:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CFB3F2067B
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Oct 2019 12:47:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ApSOMcr1"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387860AbfJJMrB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 10 Oct 2019 08:47:01 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:39848 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387594AbfJJMrB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Oct 2019 08:47:01 -0400
Received: by mail-io1-f66.google.com with SMTP id a1so13334819ioc.6
        for <linux-nfs@vger.kernel.org>; Thu, 10 Oct 2019 05:47:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=oYFP7LnHnffo4j/n4viWpRrrs/1IS/MsGu8QY/P3UN4=;
        b=ApSOMcr1yUQwVOzZymeBElC9ryUuopJvqSGcUe16g1XV2Nlk5P4irFpXf3f3cvdpeW
         PwbI0S5l7CxP9AalDESHrlAM5ktIdKBO6OIGp/ZzoWJP+knKjaecsQpHb57CNpin0dfm
         Sw2s7uSz2te118/CsFO88ddY1/1V8TOB80LHolKGWYiisOkWs4/rkxIE4b+rTZN4/jqX
         aqoYY9KQJLTpljRO3jejN8YgUwIecseLBJz/w+MBWFYRiP2uSZAYw/ct+GQHI+glF22q
         07RC8K38SnxDO17FItkBAAcuLw4uPuVDCa0ZAEuL/sRvhFh2cpaeUPlC+KxoTiIv0+d/
         TzXw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=oYFP7LnHnffo4j/n4viWpRrrs/1IS/MsGu8QY/P3UN4=;
        b=gCvXEBmAfLrQEYfqcjbTpUyYxgnkzQMlY/RavF9P0V9Ai+1kQDp2QS4YV415AKrv+h
         KmwvK8zxx+mucgsUa+UJdchV3FsgD7NcQKCWOw46MdQ7qqgnS77uB+nsMVCrb3FU1oPi
         v2SozkL1EiSshgKM4Ss720nZANPYjxuv9jFgA5pySl2cg1mavh/2shwCewYMXrykgx1N
         rC4gZoZMpcBZHCwQ1oBKHACeJJectB3tC+3YMbHDKjrtpUrsrYhqDNHCl/NcNZt8mMaK
         MLDfr65qgeRdf/o0QtrxuAFrSOgf7U0XZ7IJ3HLwI9vi09B/3OejnhCJbzZYeCS5aIO1
         VtoQ==
X-Gm-Message-State: APjAAAUNls7nTPrJK1GAnXAdjZgdn79VM/s6bAGs6FUY5aTaQW30rCW9
        JFTaWY7DepjqBD8dKNa+l+A=
X-Google-Smtp-Source: APXvYqxIRbX5LSqGFkMkvxYy+uS1Yr7qDt4+VjziBcXBFGuaDhGphHAqAMG5bR8DtqqzksokAtbjdw==
X-Received: by 2002:a6b:16c4:: with SMTP id 187mr9887629iow.88.1570711620327;
        Thu, 10 Oct 2019 05:47:00 -0700 (PDT)
Received: from Olgas-MBP-201.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r2sm1100930ilm.17.2019.10.10.05.46.59
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Oct 2019 05:46:59 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v8 13/20] NFSD fill-in netloc4 structure
Date:   Thu, 10 Oct 2019 08:46:15 -0400
Message-Id: <20191010124622.27812-14-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20191010124622.27812-1-olga.kornievskaia@gmail.com>
References: <20191010124622.27812-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

nfs.4 defines nfs42_netaddr structure that represents netloc4.

Populate needed fields from the sockaddr structure.

This will be used by flexfiles and 4.2 inter copy

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfsd.h | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index af29475..687f8e1 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -19,6 +19,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svc_xprt.h>
 #include <linux/sunrpc/msg_prot.h>
+#include <linux/sunrpc/addr.h>
 
 #include <uapi/linux/nfsd/debug.h>
 
@@ -386,6 +387,37 @@ static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 
 extern const u32 nfsd_suppattrs[3][3];
 
+static inline u32 nfsd4_set_netaddr(struct sockaddr *addr,
+				    struct nfs42_netaddr *netaddr)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)addr;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)addr;
+	unsigned int port;
+	size_t ret_addr, ret_port;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		port = ntohs(sin->sin_port);
+		sprintf(netaddr->netid, "tcp");
+		netaddr->netid_len = 3;
+		break;
+	case AF_INET6:
+		port = ntohs(sin6->sin6_port);
+		sprintf(netaddr->netid, "tcp6");
+		netaddr->netid_len = 4;
+		break;
+	default:
+		return nfserr_inval;
+	}
+	ret_addr = rpc_ntop(addr, netaddr->addr, sizeof(netaddr->addr));
+	ret_port = snprintf(netaddr->addr + ret_addr,
+			    RPCBIND_MAXUADDRLEN + 1 - ret_addr,
+			    ".%u.%u", port >> 8, port & 0xff);
+	WARN_ON(ret_port >= RPCBIND_MAXUADDRLEN + 1 - ret_addr);
+	netaddr->addr_len = ret_addr + ret_port;
+	return 0;
+}
+
 static inline bool bmval_is_subset(const u32 *bm1, const u32 *bm2)
 {
 	return !((bm1[0] & ~bm2[0]) ||
-- 
1.8.3.1


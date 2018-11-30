Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 594EAC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:03:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1AD972082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:03:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Zw/9LYLt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AD972082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726555AbeLAHOW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:14:22 -0500
Received: from mail-oi1-f193.google.com ([209.85.167.193]:42859 "EHLO
        mail-oi1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725790AbeLAHOW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:14:22 -0500
Received: by mail-oi1-f193.google.com with SMTP id w13so5763835oiw.9;
        Fri, 30 Nov 2018 12:03:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=1adVQGu3EzleOzF5553sjm9Y+OTh0F8rRsMvzXeiYLM=;
        b=Zw/9LYLtl29uqW/YnJZj+22JU0fgMEofliECH1R+e7N5JMHy6ZqMR5UgCbrrz5s8Lv
         4t0QjFAhnorPuas5LvzoIAd3qP8QXfhhNTkchLs2TCwMkXujvFPa7/QNIn4la3qil9kk
         IbiBVNkIzRbi5yRx1typ7oPdUTkmdJZL3qr5chgJlk49J/CX6Eh0o+hg1ibaJzS6Pr9J
         q9Ccw1r8qfetzgkbGA4Etazh3Bmw7Gu5wm7jHfzLybOP52Sm63OBYHSRgmrtEIKCZQK1
         g6rn3Rz9YhD5hnA/gaNkjdz4tRIPeciZYJSn/w2kly+C8qVIffjHikHd60K4fK+anCdJ
         Xz0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=1adVQGu3EzleOzF5553sjm9Y+OTh0F8rRsMvzXeiYLM=;
        b=bFFmn/hHS6KrWYjDldwDByuDuoWI+Z4A9jOPJ0kIuFHqclRd2Lxrxaf5ks1ihuKy8M
         +196/gCW0/02G9kNdulAlhY/DLt0Rj1REVb7wRllEYmYHBr8vrhDEWCg2uGk6jYD3bnr
         miSKxjn8rKlPn+6Y43zJNGV/zCUyxI8JMp1nZCQ8/YHDrrz3VyKVjJm86XH8tRTT4yk/
         OCjxcl8HKrlc9XTf43nWSMdCwYzRd75HTyL77j5cprYEHO440Fto0ABZHMhNnewjybW3
         nG9a4bA6tD//95hTGnCbrgEIFpBXDeCTStHn/BHQM2ncGELN5y1SGEUvsgE1BFLQBYfR
         ov6w==
X-Gm-Message-State: AA+aEWY7Bu33R68J+Mly20IhLIiE8P3G24fwHXiWw/i81TlyKKrOxZEG
        Lbvbs2Skc/rvf9nfLFN1LdUM49Rj
X-Google-Smtp-Source: AFSGD/WPHu3XxwqKCQCVYrc4KK2qhasqXmsoOZ75yWO8yH32Oe77m9eFcYIwKyFeh4yW7qvu+37UwA==
X-Received: by 2002:aca:a90f:: with SMTP id s15mr4289512oie.137.1543608237537;
        Fri, 30 Nov 2018 12:03:57 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id q10sm2065289otl.15.2018.11.30.12.03.55
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Nov 2018 12:03:56 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 03/10] NFSD fill-in netloc4 structure
Date:   Fri, 30 Nov 2018 15:03:41 -0500
Message-Id: <20181130200348.59524-4-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

nfs.4 defines nfs42_netaddr structure that represents netloc4.

Populate needed fields from the sockaddr structure.

This will be used by flexfiles and 4.2 inter copy

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfsd.h | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 0668999..a8fec63 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -18,6 +18,7 @@
 #include <linux/nfs4.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/msg_prot.h>
+#include <linux/sunrpc/addr.h>
 
 #include <uapi/linux/nfsd/debug.h>
 
@@ -366,6 +367,37 @@ static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 
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


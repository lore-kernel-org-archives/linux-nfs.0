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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54E69C64EB4
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:04:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 189672082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:04:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A8J9a603"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 189672082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726641AbeLAHOY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:14:24 -0500
Received: from mail-oi1-f194.google.com ([209.85.167.194]:33231 "EHLO
        mail-oi1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725790AbeLAHOY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:14:24 -0500
Received: by mail-oi1-f194.google.com with SMTP id c206so5811549oib.0;
        Fri, 30 Nov 2018 12:03:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=EIjBAKvsbMeb7MgWFADN1dVY8VW4BHqmrp8gpJd97KM=;
        b=A8J9a603h7oQeqogg5aS1htMTKzAHVARQuxsHE+so524cOG2x5HLGKyFFdyPwNKW7m
         Hdmxm5yl3HGPmSafuW+1iG+K3LNflcyrcZ5NZBfA5wanptLOpBnPynfA2NYbNvRtTG0f
         3pwhfkM9p8Xq2x76WKD0lScBnDxihsAhcyfODwGsxNbisU+oHAACnfq4HJwiBT8b1NUK
         Bh3dvz+tb+9DlFeIBfkY8rXVtphn1CX9VrICeEUqSSkZA3hVh6c6q9zgw45V6WyhAeXU
         0P/sC/0EPHvKp9YXLYqyySu5pgjq+O5h/bQhcfziFFEtjdOIDUgpFgmYv4uumf4Z2sAH
         BfkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=EIjBAKvsbMeb7MgWFADN1dVY8VW4BHqmrp8gpJd97KM=;
        b=PGS9ksPaUDuqyoyZzBmTqdyXKbjFNbmZZxUD6cgtHF/COAvQHRXo1/ifumhoO4B43r
         L78YqE2S3z/7MDrtVWCgcWOqAp5AAQBDtmYbVI28ce6vyYSUAH/DBv+5/B/E+ytdGRtk
         DBapBLpuM+1ldITuaEubrFfcAfDGBIuvPNmq3MSmw27n8O4hxBcfzwoQ/ItL9FPUxAga
         yy1hvOqJeWshL0b6JD+VefOFIIbj6PZQgHjN2tNx5WblriNRlTyO9IIvCylUUYaCO6VL
         YtlpYABWXoJeSbnNa4cWPsVuKbJVnE+zdPpd0ds/uKruUDXBMFuv4CsIB5Pa4cIz0GJ6
         GrMQ==
X-Gm-Message-State: AA+aEWbGR52iXJpFd1aoP5CdSzvBe7chgMnGk/Miy27SGrzPK1pZaI2K
        fVAPMFLQUrXe007PxTOPTjo=
X-Google-Smtp-Source: AFSGD/VaHdWqMdmcREr80qi+2DgThHqBtyz2x/m5/E4yV5sprR4ldWFT2WdVaZYd4fIchQpiRWPiAQ==
X-Received: by 2002:aca:7581:: with SMTP id q123mr4345229oic.176.1543608239187;
        Fri, 30 Nov 2018 12:03:59 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id q10sm2065289otl.15.2018.11.30.12.03.57
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Nov 2018 12:03:58 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 04/10] NFSD add ca_source_server<> to COPY
Date:   Fri, 30 Nov 2018 15:03:42 -0500
Message-Id: <20181130200348.59524-5-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Decode the ca_source_server list that's sent but only use the
first one. Presence of non-zero list indicates an "inter" copy.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4xdr.c | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/xdr4.h    | 12 ++++++----
 2 files changed, 74 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3de42a7..879ddc6 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -40,6 +40,7 @@
 #include <linux/utsname.h>
 #include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/sunrpc/addr.h>
 
 #include "idmap.h"
 #include "acl.h"
@@ -1743,11 +1744,58 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	DECODE_TAIL;
 }
 
+static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
+				      struct nl4_server *ns)
+{
+	DECODE_HEAD;
+	struct nfs42_netaddr *naddr;
+
+	READ_BUF(4);
+	ns->nl4_type = be32_to_cpup(p++);
+
+	/* currently support for 1 inter-server source server */
+	switch (ns->nl4_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		READ_BUF(4);
+		ns->u.nl4_str_sz = be32_to_cpup(p++);
+		if (ns->u.nl4_str_sz > NFS4_OPAQUE_LIMIT)
+			goto xdr_error;
+
+		READ_BUF(ns->u.nl4_str_sz);
+		COPYMEM(ns->u.nl4_str,
+			ns->u.nl4_str_sz);
+		break;
+	case NL4_NETADDR:
+		naddr = &ns->u.nl4_addr;
+
+		READ_BUF(4);
+		naddr->netid_len = be32_to_cpup(p++);
+		if (naddr->netid_len > RPCBIND_MAXNETIDLEN)
+			goto xdr_error;
+
+		READ_BUF(naddr->netid_len + 4); /* 4 for uaddr len */
+		COPYMEM(naddr->netid, naddr->netid_len);
+
+		naddr->addr_len = be32_to_cpup(p++);
+		if (naddr->addr_len > RPCBIND_MAXUADDRLEN)
+			goto xdr_error;
+
+		READ_BUF(naddr->addr_len);
+		COPYMEM(naddr->addr, naddr->addr_len);
+		break;
+	default:
+		goto xdr_error;
+	}
+	DECODE_TAIL;
+}
+
 static __be32
 nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
 {
 	DECODE_HEAD;
-	unsigned int tmp;
+	struct nl4_server ns_dummy;
+	int i, count;
 
 	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
 	if (status)
@@ -1762,8 +1810,25 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	p = xdr_decode_hyper(p, &copy->cp_count);
 	p++; /* ca_consecutive: we always do consecutive copies */
 	copy->cp_synchronous = be32_to_cpup(p++);
-	tmp = be32_to_cpup(p); /* Source server list not supported */
+	count = be32_to_cpup(p++);
 
+	copy->cp_intra = false;
+	if (count == 0) { /* intra-server copy */
+		copy->cp_intra = true;
+		goto intra;
+	}
+
+	/* decode all the supplied server addresses but use first */
+	status = nfsd4_decode_nl4_server(argp, &copy->cp_src);
+	if (status)
+		return status;
+
+	for (i = 0; i < count - 1; i++) {
+		status = nfsd4_decode_nl4_server(argp, &ns_dummy);
+		if (status)
+			return status;
+	}
+intra:
 	DECODE_TAIL;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index feeb6d4..513c9ff 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -516,11 +516,13 @@ struct nfsd42_write_res {
 
 struct nfsd4_copy {
 	/* request */
-	stateid_t	cp_src_stateid;
-	stateid_t	cp_dst_stateid;
-	u64		cp_src_pos;
-	u64		cp_dst_pos;
-	u64		cp_count;
+	stateid_t		cp_src_stateid;
+	stateid_t		cp_dst_stateid;
+	u64			cp_src_pos;
+	u64			cp_dst_pos;
+	u64			cp_count;
+	struct nl4_server	cp_src;
+	bool			cp_intra;
 
 	/* both */
 	bool		cp_synchronous;
-- 
1.8.3.1


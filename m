Return-Path: <SRS0=SPQs=WE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E4E7C433FF
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Aug 2019 20:18:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E59242173E
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Aug 2019 20:18:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Bl2BWPlV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2404588AbfHHUSy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Aug 2019 16:18:54 -0400
Received: from mail-ot1-f66.google.com ([209.85.210.66]:35852 "EHLO
        mail-ot1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2404329AbfHHUSx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Aug 2019 16:18:53 -0400
Received: by mail-ot1-f66.google.com with SMTP id r6so123774529oti.3
        for <linux-nfs@vger.kernel.org>; Thu, 08 Aug 2019 13:18:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=XL+yl/IdkZ6v8a9Bn/wwa3yKd1v2tHt/DxTYczYrYOw=;
        b=Bl2BWPlVVNNDLz6RiyZj3MNpvEjAIfWSigJioF67hz/6rKSLodYaWCpb/On4MumI4A
         7xS+vxqfRBlPQ27vXwIcybjN/b/F57Aj8mV93xLTjvOoF7EnaYziLwx5uvZgn0LVJwfO
         Xkl055QEDj94aAiTr8zCqdO5qpeT3npGcKizRj4qjs+aSAx8nS5I2s6J1Tu/1O9l5CUN
         fPKL187jEO0l3snWJllFg0o8579Oj7NMMWv9W6huQS1IibqUwwkF5M79S3lueSaE68H7
         moifDIIorx4ZLCUfw4A4Uk0IyqX/Rekgl5nMD3zMF1KRg2P1ywIZn4o0I6KmOlKo5OV7
         USRg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=XL+yl/IdkZ6v8a9Bn/wwa3yKd1v2tHt/DxTYczYrYOw=;
        b=dPShf3sCqgXH3ykvXZB3PdjiB/4XIw/Wls/6oBmJVjrgblWnPZ6Ee0GnnxvGYiPhR5
         yK83TCSxeGOS3Y7UPBkfYGevdhySzPG8fa2xneG5grfSNlPKUnx9nLJEqLlynUUfX5dS
         nr9L9zzf2L/wWrOGFduESXse8JuEHi4tG0R597+3Cjg0wXz/0J8iDl/PtwH0P4ZLfMrH
         STX1uSek4zuYCqelpzv1m1HTd7xh7C0ivbxvnd11D2/wehaaTUpylr3yany3yPPtEPqK
         F7JNpT0Hvjcu3Ojl/x8BxlEWZKOgJF4J1u7uhRNgKcnfGa9UpMZ1Ef2EvisFLbBzcGv4
         MOWQ==
X-Gm-Message-State: APjAAAX+Jzdu9Oc7Gpgz1QilYF5SboUs+Q8BfVTs8+WALhxxU/EkwI26
        VaGK9eYutzYDqs+e0Y6xrGA=
X-Google-Smtp-Source: APXvYqwhanzzxNobFi/tFnG8o5dtic5Wtk8jiQWwPQu8lh38ItjBii/2D0oUbTndW16xeq93unH4lw==
X-Received: by 2002:a5d:9703:: with SMTP id h3mr907977iol.152.1565295532952;
        Thu, 08 Aug 2019 13:18:52 -0700 (PDT)
Received: from Olgas-MBP-201.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id m20sm93590523ioh.4.2019.08.08.13.18.52
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Aug 2019 13:18:52 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v5 2/9] NFSD add ca_source_server<> to COPY
Date:   Thu,  8 Aug 2019 16:18:41 -0400
Message-Id: <20190808201848.36640-3-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20190808201848.36640-1-olga.kornievskaia@gmail.com>
References: <20190808201848.36640-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Decode the ca_source_server list that's sent but only use the
first one. Presence of non-zero list indicates an "inter" copy.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4xdr.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/xdr4.h    | 12 ++++++-----
 2 files changed, 69 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4428118..4059a09 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -40,6 +40,7 @@
 #include <linux/utsname.h>
 #include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/sunrpc/addr.h>
 
 #include "idmap.h"
 #include "acl.h"
@@ -1732,11 +1733,47 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
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
+	struct nl4_server *ns_dummy;
+	int i, count;
 
 	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
 	if (status)
@@ -1751,8 +1788,31 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	p = xdr_decode_hyper(p, &copy->cp_count);
 	p++; /* ca_consecutive: we always do consecutive copies */
 	copy->cp_synchronous = be32_to_cpup(p++);
-	tmp = be32_to_cpup(p); /* Source server list not supported */
+	count = be32_to_cpup(p++);
+
+	copy->cp_intra = false;
+	if (count == 0) { /* intra-server copy */
+		copy->cp_intra = true;
+		goto intra;
+	}
 
+	/* decode all the supplied server addresses but use first */
+	status = nfsd4_decode_nl4_server(argp, &copy->cp_src);
+	if (status)
+		return status;
+
+	ns_dummy = kmalloc(sizeof(struct nl4_server), GFP_KERNEL);
+	if (ns_dummy == NULL)
+		return nfserrno(-ENOMEM);
+	for (i = 0; i < count - 1; i++) {
+		status = nfsd4_decode_nl4_server(argp, ns_dummy);
+		if (status) {
+			kfree(ns_dummy);
+			return status;
+		}
+	}
+	kfree(ns_dummy);
+intra:
 	DECODE_TAIL;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index d64c870..dedc316 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -519,11 +519,13 @@ struct nfsd42_write_res {
 
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


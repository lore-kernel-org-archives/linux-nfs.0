Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BF43ECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:51:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 514152082E
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:51:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pJrf8JBp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 514152082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727615AbeJZG0U (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:26:20 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:39027 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727428AbeJZG0U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:26:20 -0400
Received: by mail-qt1-f194.google.com with SMTP id g10-v6so11789951qtq.6;
        Thu, 25 Oct 2018 14:51:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=MFrexHXO7yQY1QRrDlhjfVTvrBtGmp73ZTx4Rn7FdtQ=;
        b=pJrf8JBpy3pMJupv3zJvx5vJveiEgKc6bu8mMzT5NCKAPblvo2JMpgATDuiH89VyjF
         +yusXl1HjPwJ9+/28ERp61HJyVYi3z/R5EWPkPEjG45mJsEAUZ5nC9pkALQrwINYtC0A
         uYZU+I19k/lY9ItIJ22wV39fxDGlfLR+UVgX1wkWrolIBGrPct41dQJLx5EZgXTfKqkC
         7V07BzoEsKk38h/XGew1xaZe9s3N4TZt8BEoHpat3tj+25SljldSOOhRx8grpa7DPvv5
         3FqB/afodTP0Vg9+1aPnFfZOsYowy0zHRPJNZXdSNFnF53c8mr6Kbk+QsI4Lz79G6Jtt
         QD2g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=MFrexHXO7yQY1QRrDlhjfVTvrBtGmp73ZTx4Rn7FdtQ=;
        b=ZR9nBGsyGdLe65MwMtkX1zPRRHkTaFdhKDnrelLqrFvYH25J2JkBJRU3DQpdlsrRia
         HpWZk+1ScKO1oLD2akrLtydOPB2c+UrNCS1hJXOYPrJd/sVf0CmJkpyIdtXCvfpB2u2Y
         ZNIxOet9mzmU3j3o6jqeH6ldYH0EUjGUaqVwtZfOfBnqjL3m76f16lBHGjdi42gA6JRp
         BneJUZpJZvpSIqcBJ1p0WClc8PvWtjHUUwBOp0GzGHPUDo2l0tz60TF8BBobT11GxTHv
         PQe/Y55zvSRWleCKkB4Li0Ruwyiqrsxh8nV9A1nPHPoOeWYkZRNSik0OSPhVGDAZ1sxE
         ahjw==
X-Gm-Message-State: AGRZ1gLgy6XLGzxgXLUcyskgBh7fPHLVZQtYtieIJAX+98BuPXdQPJpj
        saojkg++0XmXoW40GKvcC9g=
X-Google-Smtp-Source: AJdET5eyFZvApxpObGMDdY80RIHFf4J07hNly0RPW3ZDnoRcsls0RFRgDYPSuXZru19HlQlWr/ApUg==
X-Received: by 2002:ac8:7211:: with SMTP id a17-v6mr920740qtp.213.1540504315548;
        Thu, 25 Oct 2018 14:51:55 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm5895927qkc.96.2018.10.25.14.51.54
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 14:51:55 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v3 03/11] NFS NFSD defining nl4_servers structure needed by both
Date:   Thu, 25 Oct 2018 17:51:39 -0400
Message-Id: <20181025215147.36248-5-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

These structures are needed by COPY_NOTIFY on the client and needed
by the nfsd as well

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 include/linux/nfs4.h | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 1b06f0b..4d76f87 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -16,6 +16,7 @@
 #include <linux/list.h>
 #include <linux/uidgid.h>
 #include <uapi/linux/nfs4.h>
+#include <linux/sunrpc/msg_prot.h>
 
 enum nfs4_acl_whotype {
 	NFS4_ACL_WHO_NAMED = 0,
@@ -672,4 +673,27 @@ struct nfs4_op_map {
 	} u;
 };
 
+struct nfs42_netaddr {
+	char		netid[RPCBIND_MAXNETIDLEN];
+	char		addr[RPCBIND_MAXUADDRLEN + 1];
+	u32		netid_len;
+	u32 addr_len;
+};
+
+enum netloc_type4 {
+	NL4_NAME		= 1,
+	NL4_URL			= 2,
+	NL4_NETADDR		= 3,
+};
+
+struct nl4_server {
+	enum netloc_type4	nl4_type;
+	union {
+		struct { /* NL4_NAME, NL4_URL */
+			int	nl4_str_sz;
+			char	nl4_str[NFS4_OPAQUE_LIMIT + 1];
+		};
+		struct nfs42_netaddr	nl4_addr; /* NL4_NETADDR */
+	} u;
+};
 #endif
-- 
1.8.3.1


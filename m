Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 432ABECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E476A20824
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sTNYR2vN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E476A20824
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727851AbeJ0Eta (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:49:30 -0400
Received: from mail-qt1-f193.google.com ([209.85.160.193]:37595 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725965AbeJ0Et2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 00:49:28 -0400
Received: by mail-qt1-f193.google.com with SMTP id d14-v6so2684816qto.4;
        Fri, 26 Oct 2018 13:11:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=MFrexHXO7yQY1QRrDlhjfVTvrBtGmp73ZTx4Rn7FdtQ=;
        b=sTNYR2vN+IhZdVxV+w3+wC1V0R0BmZMyFbEd/ciK2QVbxfr+ClYnSMvqbkYaUhku/i
         qvsmzMrH4nHlyDVaTTfTJLwwHV5bE1shou/Nk/idVvr2uzvDMp+mBoOOfJvLiajT8fgf
         tT9RAJyeGmxfVmaYXEI6zZd1LotxSbAiqLsjtapc4Px3XeU+ajNjtPGy9nEJLLeoZ6JM
         c1IE2Q4XGMccbO6sUkc9Y8LzLpdWNFv0jtLCISxzInL3Xs1OQ4clQmXm9wKqJPL8UIhC
         hidql0e5OEe6ZjKjy1khk/o7Aqm9AY9TBLpqhzWa+72EhSzuWFFIZoSbj1ByvN7uwEEn
         8ARQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=MFrexHXO7yQY1QRrDlhjfVTvrBtGmp73ZTx4Rn7FdtQ=;
        b=XYTiQKUbGdjWetDRukV8v+w4HXkvtJcqn2Q4x6rt1RUsLdgC2qr9oHLuSp09YlbgSM
         wgkKCaJ6FLFB8YAJuF0uON4UYf3Z/yXu006rppvGunTbv3yKbh/h3ti0i58wvhYnPyN2
         YTxHp81EJ7lkCt5wZ0rR/BFLYZFeoZ/y1n0jZgubQ36+SlkBFG7152hNSFv0aHL0ZHXv
         8KbDQ8+3l/IzH7g8woN+LL1ZZ77Iv8qD2Gu+HSIH1gsZfwCnyPqbbKfpqpvNvUD7Jpr+
         QbMMrU4Bs4RKz1OwWM3G3Ullafi/zPsSAq8PGqz8l3WW7whB+ii3qfKWtS88RDiRk7WI
         NcgA==
X-Gm-Message-State: AGRZ1gIBjzDDYuvj49dGKOJL5o3V7zQtybdSYcc/INMYDqdy+SXtNc4F
        yhesB3Ap3zf1zmjsq/BZmV/9sIWT
X-Google-Smtp-Source: AJdET5d2nL0J4cBaNQAyInGmRoIEMRV1IJozM6Scq6HtOEnR/3bXOsyl3Pk0obuF63kWdbop8zrCPA==
X-Received: by 2002:a0c:90a6:: with SMTP id p35mr4664083qvp.79.1540584665080;
        Fri, 26 Oct 2018 13:11:05 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm8037667qkc.96.2018.10.26.13.11.03
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 13:11:04 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v4 03/11] NFS: NFSD defining nl4_servers structure needed by both
Date:   Fri, 26 Oct 2018 16:10:49 -0400
Message-Id: <20181026201057.36899-5-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
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


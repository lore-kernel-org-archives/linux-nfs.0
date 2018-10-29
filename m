Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69F07C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3772D2082B
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JfXeKTxl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3772D2082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728043AbeJ3Car (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:30:47 -0400
Received: from mail-qk1-f193.google.com ([209.85.222.193]:34099 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726330AbeJ3Caq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:30:46 -0400
Received: by mail-qk1-f193.google.com with SMTP id a132so5489259qkg.1;
        Mon, 29 Oct 2018 10:41:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=CNj2pCMxPlcH1fEKnenx/QqOVUgHVEB5Ekmf2YUbfVA=;
        b=JfXeKTxlyulMMtigTci4rQFzaymnMXYE/zRUUbXhSK+5DWIv9M4+bRSOwhaBB4C/0f
         1PE5jy17xbY+BGAJno/ofqw/B60ME2D9KcRAT85Awbb0hqR5+Ow6/X1JuTlY6xHDOPpz
         8MyMM2GeNFvMHgOGjdnbKpVBtpc5tQUXjku0r65i/YrQv0N1ZkzCWYFutApGWUkAYwKI
         d0/0uVBc5K+P3uNsyRnM52Rx34R8GSLD5rzXAb1eWeXjHg6SN/XVTHMbpQv1n+RWrQgQ
         udkK1199e8YbemKGVpgeLbhCjrQ+tEdiX5n4VuetquyN5qyJVbgVtO/3cq9ynFxZB8fZ
         cYsA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=CNj2pCMxPlcH1fEKnenx/QqOVUgHVEB5Ekmf2YUbfVA=;
        b=qinTwb/M6Y5y0M9AuJ0cPO1pAAnpU9bXui8KdM+JM3dIrHp8bYHAhC8sVwU5Xd79Ti
         wVE8S+rSW59hCo2b7GWWBVNHKHUyGr4LkLbZzW0cKEwxjJGd/xXA6celkvG7HTydqNtK
         o66QRWJsJjdVVhh1wDntB+B2a7w25YH13NvkdyFFtEQy7AEkQZO0NNq1os7m1GWaFdaT
         j+fygDGfvSiFXUBGV61BDpgT7ho4fYvDX/VgbAzJHCC4uy3Gcic4rfyf5ahzDvXQT+/I
         CfXQXxeFzcmyJghHu8jsSD058Fx9wfG4SnuPEAMzpChxWql/WcuN+8sclZmRnumcp0yk
         3XIA==
X-Gm-Message-State: AGRZ1gK1FZPmJw9RnpAxZjp56Q5vpydqXGKgBd6ursF3Mz1hybB/BYPL
        uVGGAyLWa7BPD4fsQBbwh5A=
X-Google-Smtp-Source: AJdET5e1cGvPizEUVNJ/rzXIjUootGq97/yYRadEKDCon4BdsG8DOThbEsjKgBd/z5z+K+D6SrDBgQ==
X-Received: by 2002:a37:611:: with SMTP id 17mr6506899qkg.123.1540834869198;
        Mon, 29 Oct 2018 10:41:09 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n190-v6sm13148929qkb.29.2018.10.29.10.41.07
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 10:41:08 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v5 04/12] NFS NFSD: defining nl4_servers structure needed by both
Date:   Mon, 29 Oct 2018 13:40:51 -0400
Message-Id: <20181029174059.38326-6-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

These structures are needed by COPY_NOTIFY on the client and needed
by the nfsd as well

Reviewed-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 include/linux/nfs4.h | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 1b06f0b..4803507 100644
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
+	u32		addr_len;
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


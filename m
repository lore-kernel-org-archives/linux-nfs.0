Return-Path: <SRS0=zNNA=XL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF2E6C4CECD
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Sep 2019 21:13:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AFFDE216C8
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Sep 2019 21:13:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ccK1AHn5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387878AbfIPVN7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 16 Sep 2019 17:13:59 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:34008 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2389144AbfIPVN7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Sep 2019 17:13:59 -0400
Received: by mail-io1-f67.google.com with SMTP id q1so2563432ion.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 Sep 2019 14:13:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=XsCVxoMR45LfMXA6Sd1k+7LRp9n+Zt/u7Ma/oGmC6xY=;
        b=ccK1AHn5Y/Bmi0KjKNneF6oVHZf5lsH8U7MDwAPbfOVLiSaLtZN8h1GsO2d+lkxvtZ
         Yq3VE81/Za8J1K2DwBdCzwkiQ83BY62dtS/RkNZAuREoncX6+Bg60qJmH86CxJaUa1lh
         zbxZTFHLJEa86X3cZ4W8qdi5xIc1CbLg6o37b+xaPbTXJ/2upmFDaRUjKJSCtjZ5Gaz2
         pdTg3bxNyW/D6VyvNPxmKmyry4M3mNfxBWzeOISiszKgOcHWVzcdeYDYhnZxRErcVIMh
         QU0WL0/MR7eoP4yvjMuI0rVpX5e8F7ZF4jeuKsuvxGCYwm7XM//GV0R2kwnC0Tch9VVg
         AkVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=XsCVxoMR45LfMXA6Sd1k+7LRp9n+Zt/u7Ma/oGmC6xY=;
        b=gXHk/eBJTmI9imgFcOzM9qHvq2ZiTwf242z81EOet1PdxoWN3IY/H6Ad7pzo6MEiKX
         3unBZXO9HusqgMhw7dSmSNm6HTl9VPb54CNa5wEtbMaJuYCsCV8tzTPxxg9tIMTIm+zS
         PPVRkMIawZ6eIs4rZLnsR+BWHYEcwkOn+XcT+STH95sImqncMJv6J/PqlMxbPWjdXlEc
         +0SeIL68bP6mPJXjEqdMFWkxUh8vY6iYO20zzMNdUpI4IgqwAACOJHThszdhQTPT+kZK
         sQr9lbZwSrmyRUfxdG0R9m1hT3Enae+3djG9PATFUHvRCrY/T1wbVghlViB0+3ByDOIr
         vnuw==
X-Gm-Message-State: APjAAAVC5kH/h/WXAOROpGJ64T0cSz3NR1k6Vlo5tJdRxuDjBnLvbbM3
        pL731/AMzTpwq5WhgUf2hvONmAhK
X-Google-Smtp-Source: APXvYqwXPAtCPJvFyuWsViK3rXfHoWLS4NvRXRXLB2F72XmyIQjOdlXGEP0YuAYCT0MfSfXQZkAJDg==
X-Received: by 2002:a02:7810:: with SMTP id p16mr5989jac.55.1568668436615;
        Mon, 16 Sep 2019 14:13:56 -0700 (PDT)
Received: from Olgas-MBP-201.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id l186sm71853ioa.54.2019.09.16.14.13.55
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Sep 2019 14:13:56 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v7 01/19] NFS NFSD: defining nl4_servers structure needed by both
Date:   Mon, 16 Sep 2019 17:13:35 -0400
Message-Id: <20190916211353.18802-2-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20190916211353.18802-1-olga.kornievskaia@gmail.com>
References: <20190916211353.18802-1-olga.kornievskaia@gmail.com>
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
index fd59904..5810e24 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -16,6 +16,7 @@
 #include <linux/list.h>
 #include <linux/uidgid.h>
 #include <uapi/linux/nfs4.h>
+#include <linux/sunrpc/msg_prot.h>
 
 enum nfs4_acl_whotype {
 	NFS4_ACL_WHO_NAMED = 0,
@@ -674,4 +675,27 @@ struct nfs4_op_map {
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


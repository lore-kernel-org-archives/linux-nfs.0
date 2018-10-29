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
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAF63C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B35962082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gwEh1aZy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B35962082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729442AbeJ3DyI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:54:08 -0400
Received: from mail-qk1-f194.google.com ([209.85.222.194]:44998 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725923AbeJ3DyI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:54:08 -0400
Received: by mail-qk1-f194.google.com with SMTP id n12so5638389qkh.11;
        Mon, 29 Oct 2018 12:04:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=CNj2pCMxPlcH1fEKnenx/QqOVUgHVEB5Ekmf2YUbfVA=;
        b=gwEh1aZyYGSNFFFz5kk7BIr2QIx4YC+/5+qpHQpOrqJvTQYESWipOP1iaLwC+XErI/
         m1tedvFSKKF13UKf/fSjFP5QhRFrMEWPHquDl6DtzomehZdQ7ANQ+S5yKrF9MOHxcvAy
         q9Mlw6PoeRHL7L2AtqFepeBPXi8iPn5bNw8uqIFRBECI6ouZLVwkx0AKNx9FobXL4OP1
         R9u55+MfgLXqozjjE7SmqlfTbULcZFnpybDfu7DvXaQZ53oiwoNqksbkc0KluK8Xdgm0
         FRnNPhCRLGFsFkmVQN+L0rDJSGknAmeUXTBdTpBQDsGXh/Nj0g+vzlRqRsKZdgVBi/An
         luXw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=CNj2pCMxPlcH1fEKnenx/QqOVUgHVEB5Ekmf2YUbfVA=;
        b=mAOhH5l2j7l/QGWg8jFI5CzpgLClPBhR8TB8dUkvRF3LDzi/XzHaRNcN6YQzOYh+SE
         uX+vm8LpwsgngqJMqm8yKjKSt2QJym0961x2a7R2vivrs8E6QOPYEjxO7uFuWTAdSIlw
         COdxBFdwy4nf9YiwyXhMk3e1SthqpYMfrNq11Rs5kIVXqPBQQmUXhSMmIXXjGjSEbmD8
         tWbPPoBj9ClsHE6+Ux2hBKYgoLSDPaocv5dQrA8tQL4uAI3GrdBXpLwb3ZdAcnxbRfyT
         qjBBzDPps7wBYsCbJcB3aQyk47tg3S9lgGDF4Yc0kUWFjK809eVv87L+UP6mRwzX4ni4
         8HsQ==
X-Gm-Message-State: AGRZ1gKZSDsY+WG4GoByZllPOEDqupTkUFA5NOcquRh8O6Y/fgrkv0fM
        gzyc6icgnk4S3m/ZlZzNcCw=
X-Google-Smtp-Source: AJdET5fEvOkkSLADksyuO2iNpjbJro5W5LMaIeEI6lBrKNeqzThyX7wVcY5EfG+LIkVRBFsGAgoz+A==
X-Received: by 2002:a37:8d4:: with SMTP id 203mr5727983qki.338.1540839849730;
        Mon, 29 Oct 2018 12:04:09 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id c5-v6sm2714373qtj.55.2018.10.29.12.04.08
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 12:04:08 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v6 04/12] NFS NFSD: defining nl4_servers structure needed by both
Date:   Mon, 29 Oct 2018 15:03:49 -0400
Message-Id: <20181029190357.38439-6-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
References: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
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


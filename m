Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10B25C6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C68C3205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K2780E84"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C68C3205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726388AbeKBBtR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 21:49:17 -0400
Received: from mail-oi1-f194.google.com ([209.85.167.194]:37200 "EHLO
        mail-oi1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726375AbeKBBtQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 21:49:16 -0400
Received: by mail-oi1-f194.google.com with SMTP id w66-v6so12838270oiw.4;
        Thu, 01 Nov 2018 09:45:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=CNj2pCMxPlcH1fEKnenx/QqOVUgHVEB5Ekmf2YUbfVA=;
        b=K2780E84GyIin7wKGPVIzmorV99lwPhcc6X8CR40li/69a/Vj32gDdrqtWq4IIn/AK
         aXoGKTM8M7jQaS2oDqWEWMg2Ok33P0pYBOdTPad4Bkxy3ADJDnhWqNi3LIQ7JGNeBnr4
         npfWXatpDUCKUmk+IbyOAkRak9Gl+p9aOSM0MnbtnkwjfrBBmMkm+0rpk95/MwGlJy6M
         85CB7nTxGdSMKSfSNp5IknTgQ0KEmT23GbA65uBwGY5NSFnnbbqW+GYaFS7P7QmvPzWx
         ntFR+L4b48NvKQxUkepdJ/rgcw13j72KoBz8bgLd1GIbW47fvoryicX6jUcn/sh9pGGh
         AyZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=CNj2pCMxPlcH1fEKnenx/QqOVUgHVEB5Ekmf2YUbfVA=;
        b=JYme/3SvTsls23r7MfNoWEP8uK54Om1Okes31UQGdaoM2tzxum7C/mcpXglUVJC52t
         q39pk5nLFRLjKf6sMnJAmjFMdzj8M+qhkZS1LX6KoI/rN486eJ+ctCbCmSNNCQA8HJOO
         3nM9j9oZ6kHNwaUMGkGodyD74/Bo7rqILucENje7j8C5bL3edIsuJ1AP9jy5Vs1Ll0Zm
         ntGyHm5KpD0uT50RHOLQjzhcjKzVONA+L+8s4i2LdmSmyGz9jiw/fxcGt77Ca64XlnGG
         AN+oPISfaYtlgrzoqarG53y7qz6082xP2DEbbsl2pslohb4U8ssXEW0DONF24HrxgkD6
         5xmw==
X-Gm-Message-State: AGRZ1gJKSBlUsXJMePpbFlcw3cQdkt8sD3medNcuvVKg+0AzijrNQ10x
        yM+9HgQ7+uEv5qswF5+tGHOP4D9d
X-Google-Smtp-Source: AJdET5f4ej7T0B3ZL73gYGzXleAQdv/CYNREp3bZ35qvy6eE6Pz1si1TRMvC92lB6d0zpXSLSc3PKg==
X-Received: by 2002:a54:4188:: with SMTP id 8-v6mr5055357oiy.105.1541090731257;
        Thu, 01 Nov 2018 09:45:31 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r62-v6sm1834301oig.14.2018.11.01.09.45.29
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 09:45:30 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org
Subject: [PATCH v8 03/11] NFS NFSD: defining nl4_servers structure needed by both
Date:   Thu,  1 Nov 2018 12:45:15 -0400
Message-Id: <20181101164523.41812-4-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
References: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
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


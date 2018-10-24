Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B77A2ECDE44
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7A3A920832
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Fn9SkUq0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A3A920832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727454AbeJYE2R (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:17 -0400
Received: from mail-qt1-f193.google.com ([209.85.160.193]:37688 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726264AbeJYE2Q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:16 -0400
Received: by mail-qt1-f193.google.com with SMTP id d14-v6so7108521qto.4;
        Wed, 24 Oct 2018 12:58:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=MFrexHXO7yQY1QRrDlhjfVTvrBtGmp73ZTx4Rn7FdtQ=;
        b=Fn9SkUq0x+PAp1QclbMdemsP1+0K/6QnUnZnKMhGUilFAAXpM29jt2bLnBJ4bXyRc1
         u1NeI6UqYKrdfTtNF3H2WIHFTCjMiT2hFl+10d36vyOgmc7I1dgjEdd0jlUyIzre3ekR
         SDt1oFJwSGzfBXKrbFOzT8nBw+8RfyLSs8T/+J7gegPOiP0o0wPVnE0N0owNlwrp+z3o
         RTi+roXvJ/3Wml/ugCGQ7gAkAZWSySc3F9SqbkgJTfk5H5Zzb1f6uqsQh5F6AGuHUYpx
         1ORd2bYciFxEkuSCllHPt+Nk44QWmBbEUJLYNH/uYKRgLhOwYDR4/W5a/tF2F6CGV3pP
         QNQA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=MFrexHXO7yQY1QRrDlhjfVTvrBtGmp73ZTx4Rn7FdtQ=;
        b=s/zj45CUA+H3vqkGwRa2zct2lGT/A3RqioEQPYuh8l2+yh1+8xsrxPd+Tw9byYH98C
         6eBodFybe4kZTuGjXYWNbpGbznBJ73gf91R/Uz3FyVbn3mxBT5EvVyZfqljT95qW/Bf9
         /wbpC0gQsO8Ehr7AGnSmqtueYPmw+CSHqPPWWroXecQ9Dp23jWG//32ecY5zhBQR3bUU
         dJ01uK3vjN5lUcWuFNRrKJIvbGaR5TU0tZj33j3l8uprviCgaqv6XAlr3MLI95t8hbyw
         WjGC9q15bCaIVNfTPKhdRuZc5nx+zWocdVQksfYgh7dfjOYJ333XufgTEGkjjbVhyzSH
         i9bA==
X-Gm-Message-State: AGRZ1gLAXd3dyluxYQissCsc7pzbsQYd1R0G9xA9tCPP1W/mqtYHtp+b
        1MUuaGF3wcoAx24K8G5ZUkw=
X-Google-Smtp-Source: AJdET5c297/vyC6W+kCDq2UDOmGTVxadwWAag8mMO+kaIgTEmdONgKRFkzJh4tAp5iu6Njjn5QKhYg==
X-Received: by 2002:ac8:13c6:: with SMTP id i6-v6mr3922194qtj.357.1540411129666;
        Wed, 24 Oct 2018 12:58:49 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.48
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:49 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v2 06/13] NFS NFSD defining nl4_servers structure needed by both
Date:   Wed, 24 Oct 2018 15:58:30 -0400
Message-Id: <20181024195837.35532-8-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
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


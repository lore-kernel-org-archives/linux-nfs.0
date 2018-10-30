Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDE4FC2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 850E42082B
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CmCpHZMv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 850E42082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727948AbeJaFvf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:35 -0400
Received: from mail-qt1-f193.google.com ([209.85.160.193]:36225 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726420AbeJaFve (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:34 -0400
Received: by mail-qt1-f193.google.com with SMTP id u34-v6so15268944qth.3;
        Tue, 30 Oct 2018 13:56:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=CNj2pCMxPlcH1fEKnenx/QqOVUgHVEB5Ekmf2YUbfVA=;
        b=CmCpHZMvqcUFlYHrILN6glreEixyEE7rsqwWQ5a8L6bO78z2rDWTBcWozw0jZ27Yvq
         n87OWfKMDMTK0mmJS9sN/2mZWsvnJ4AW1qTvntoQurumS/dBvClcKDgXLcgSaqPI/on/
         /RXFJRC/bXb774rTKO10tg90+928AKm8z9gLQbcA43NNupH2HK67AcClsiZDSQWmBmyU
         Z8xvnRgBVAqZ0AuJuTkwd1hm6qSSpFpRtVmWUcCKRUag5vTG/c1VuiV01yr0AvliI3LF
         RSb4SGQJ3yWhDIwjSvc8k086Wdt1Cc5r+SOt+o4gzDSVzQzW68pHRF56E8THdZJxXscC
         JvqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=CNj2pCMxPlcH1fEKnenx/QqOVUgHVEB5Ekmf2YUbfVA=;
        b=qCO6rKmvyL8V7wb02APQqI1ccSDVullr288MmZzmP8I7hq3O7O56CGJDwHhjT+HW3R
         LXN2KqXHCgguurhpOzh9wm7Gu1tsXNA59zKOLZOR691AZLbEDVk4D0rIHXmhhawWX5AR
         +x/ljBSpzKHe74Gh/AaWcgCl9KOw/WpbZFBOm2oAhgeK5ie1Y4yvbOr2ZYtghPk3AC8L
         Pz9YaqI5sDZWA/wRB0tN6gi9wG2vUCxPtfEHf/O40ea4r7SjHUECjt/rA2SLNIAxfXy2
         f+ctzbF/k0nRuw1vm7SMKGjRLl9t61FpZpChyXe9ZyocsOjzzFm/P4tFFTGpn7hY4XjD
         i4DQ==
X-Gm-Message-State: AGRZ1gLFWXwIkpAHsRiRuF5Iuqk7pM1uxNSKrGvQiQuVc6vX1xJkZzaV
        dxf5ZETGjf3tuasxOeBYFKg=
X-Google-Smtp-Source: AJdET5ed6J8HiEDUtwbkDInscw7rrrNlKv1jDOXSjWxHlmqH4GWRSo+0RYbBCmf1nBOrrwOdAfVgmg==
X-Received: by 2002:ac8:2249:: with SMTP id p9-v6mr311107qtp.200.1540932990060;
        Tue, 30 Oct 2018 13:56:30 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.28
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:29 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v7 03/11] NFS NFSD: defining nl4_servers structure needed by both
Date:   Tue, 30 Oct 2018 16:56:06 -0400
Message-Id: <20181030205614.40754-5-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
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


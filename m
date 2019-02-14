Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB3E3C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 00:00:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 98A222070C
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 00:00:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mV5NxqfA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728454AbfBOAAS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 19:00:18 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:34726 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727348AbfBOAAR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2019 19:00:17 -0500
Received: by mail-it1-f194.google.com with SMTP id d125so3181432ith.1
        for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2019 16:00:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=HjpEhmudseqnxJciDUajDYGs64OStOmb5/Lvt8i/3Q4=;
        b=mV5NxqfAeBr5/bKVN5uEadNT8NIukNw5tFF7fsPI190AJ8g/lHRP0pNWyBboD++MF0
         RtKNATqj4ILPF4RWACsoM7HYxPl/mXNu8lIZtt3g/yGkBTBIPZYpl7lDlo3q8fzhvfKm
         somu5Jdcj287ovdUhW3vnU60Zgg5VEAGxwfW3cOuG3ry2xRTD5Yt8QHLS+871rKqNsBg
         S45KXC0hKC4kvQ7HoTPU285vubVjDTENKu9pKXarOMGe7qZRdICtTXafCFn+qum+6b8i
         8DteBhLWzqNm3K6/bDp/v0nz/RVaxoQ7iliE7kIEAaC1lH103ZTV/8Uj72dZlimmpVOJ
         qdbA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=HjpEhmudseqnxJciDUajDYGs64OStOmb5/Lvt8i/3Q4=;
        b=dMoxHXIPyHfHVbBvhGVJxJ7QOZOPVoYn8AsaFrJ5vOZd61GYvbtYW3y0NO+09Z6pBs
         WshHeNa35bKDrBgEbZqrzHV1pOuW0Apx50gt8nS1Xo+RI8uvXiJ+t9aTqkde0hehc3g+
         hB57X4OnE+7G+qeeQdIv8E6UTxDomvs9JVbCWsRobmc19ETdn3z6gVUsesEjGSxgLcUu
         bAoRIMy0x5gI4Gj3yuKL2g1dutsGTMphgd3WzDYKDZxNLdGkti6c83m50f+UZhY6hhfL
         6OQyQUHjMPVfKe3UQHpZMhAFq5+8Z3D79zdjB8BGKOcLpBpHwhTRuEjSvlBHvYTzu98Q
         wkRA==
X-Gm-Message-State: AHQUAua3NH57dv1sYukcS11801mjZ6LXSacqoHorhCEF4QGtpu9hgB7O
        ic+Ahp5u9+E3wGToEEl0lQ==
X-Google-Smtp-Source: AHgI3IbxhySKfEPveI17M0hfKV4Xd+U1d20HqxoYPkM3twcU9B1Zg/OUTiyBTPZj8USsjb8hanB9ow==
X-Received: by 2002:a24:ac02:: with SMTP id s2mr3556132ite.94.1550188816238;
        Thu, 14 Feb 2019 16:00:16 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l186sm1862840itl.22.2019.02.14.16.00.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 16:00:14 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] NFS: Fix I/O request leakages
Date:   Thu, 14 Feb 2019 18:59:06 -0500
Message-Id: <20190214235907.85519-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When we fail to add the request to the I/O queue, we currently leave it
to the caller to free the failed request. However since some of the
requests that fail are actually created by nfs_pageio_add_request()
itself, and are not passed back the caller, this leads to a leakage
issue, which can again cause page locks to leak.

This commit addresses the leakage by freeing the created requests on
error, using desc->pg_completion_ops->error_cleanup()

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Fixes: a7d42ddb30997 ("nfs: add mirroring support to pgio layer")
Cc: stable@vger.kernel.org # v4.0+
---

- v2: Ensure we don't release the original request in
      __nfs_pageio_add_request()

 fs/nfs/pagelist.c | 26 +++++++++++++++++++++-----
 1 file changed, 21 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e54d899c1848..301880a3ad8e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -988,6 +988,17 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 	}
 }
 
+static void
+nfs_pageio_cleanup_request(struct nfs_pageio_descriptor *desc,
+		struct nfs_page *req)
+{
+	LIST_HEAD(head);
+
+	nfs_list_remove_request(req);
+	nfs_list_add_request(req, &head);
+	desc->pg_completion_ops->error_cleanup(&head);
+}
+
 /**
  * nfs_pageio_add_request - Attempt to coalesce a request into a page list.
  * @desc: destination io descriptor
@@ -1025,10 +1036,8 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			nfs_page_group_unlock(req);
 			desc->pg_moreio = 1;
 			nfs_pageio_doio(desc);
-			if (desc->pg_error < 0)
-				return 0;
-			if (mirror->pg_recoalesce)
-				return 0;
+			if (desc->pg_error < 0 || mirror->pg_recoalesce)
+				goto out_cleanup_subreq;
 			/* retry add_request for this subreq */
 			nfs_page_group_lock(req);
 			continue;
@@ -1061,6 +1070,10 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	desc->pg_error = PTR_ERR(subreq);
 	nfs_page_group_unlock(req);
 	return 0;
+out_cleanup_subreq:
+	if (req != subreq)
+		nfs_pageio_cleanup_request(desc, subreq);
+	return 0;
 }
 
 static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
@@ -1168,11 +1181,14 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 		if (nfs_pgio_has_mirroring(desc))
 			desc->pg_mirror_idx = midx;
 		if (!nfs_pageio_add_request_mirror(desc, dupreq))
-			goto out_failed;
+			goto out_cleanup_subreq;
 	}
 
 	return 1;
 
+out_cleanup_subreq:
+	if (req != dupreq)
+		nfs_pageio_cleanup_request(desc, dupreq);
 out_failed:
 	nfs_pageio_error_cleanup(desc);
 	return 0;
-- 
2.20.1


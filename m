Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 718EDC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 21:55:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3CE5B21872
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 21:55:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VhpznEBX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392290AbfBMVzH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 16:55:07 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:52936 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388687AbfBMVzH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2019 16:55:07 -0500
Received: by mail-it1-f195.google.com with SMTP id r11so9747393itc.2
        for <linux-nfs@vger.kernel.org>; Wed, 13 Feb 2019 13:55:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=rb+wJldDmRdRFdVzR15kzmTKgtHcxu+6JLHaC8Z4OEE=;
        b=VhpznEBXgIQ7ORt1JRcS/Cc34uT6gtUMyujJilRCUQOEH562tDQAfnEFl6MwItJVKV
         bnWETXQwHpqPesQh6/71/akhEkoYofO7zE751Sor9CK4mExgfAyNR+rfIr4ZKusjbYeP
         N2f5doH3N7GeiKhs/sjZFdTrGdabM8rBzz1b5yu5l1ZXDD7x6wa6TdIUkawXarO9H32D
         xTUBFjKlfkFSz+PozDtX7VPHPZ4zhSYWGT1WBa8c1tlP4fF8nx7G/YTjlqKM4YCYl483
         UTApNnzUihfgZXh0CWO8cyGaWVa5ED05KmMSWXqEf055o0wAADFT4cWM9dYsDAS6rc99
         OQQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=rb+wJldDmRdRFdVzR15kzmTKgtHcxu+6JLHaC8Z4OEE=;
        b=Q6YYF92QsgUXfQcwh6RBGurf2VpeeGuT3G8qeAflCgJb1/dkcKhYw9BhHoVhY14ocx
         Ibnl6VqehkLsPPxLNHfv8iD2eviqXMQu5PTg/a/PZUDirEvXo596Lhi74b/If9SeWUXb
         pI8TnCH7gJ6VGuFifnPaA/Eru7pmbIq9Y3A2+FBPqz0fKq/spug1G9Y5uLhRT3u39W33
         wC1hyHLNxdBmtSptAd0nsjaIzjGi00eIEX+Uoh4X6lkXWDYMlNFsC5yKvELd5SI+n1HK
         KJJLiobjyfMloXNVzvu1KT2tfgsGCG6CAFhDby018rU8pi54nvF2cjGGvq+P0+jmM3+3
         xA/w==
X-Gm-Message-State: AHQUAuZfc2F3ng2FtBDCOkiNHNEBIGua3amAW732oW903aRjeaFj2Wme
        sZDLlf3m+ppp++c5wklmEw==
X-Google-Smtp-Source: AHgI3IYq9RUZuLvhyrTM/aNEG6y6LeIU6kAY3K0U58fLN29M2n0jxyuv6Iq8ToBikqmtZFvGcETMRw==
X-Received: by 2002:a24:35c3:: with SMTP id k186mr239031ita.5.1550094905771;
        Wed, 13 Feb 2019 13:55:05 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id y184sm322113ity.27.2019.02.13.13.55.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 13:55:04 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Fix I/O request leakages
Date:   Wed, 13 Feb 2019 16:53:56 -0500
Message-Id: <20190213215357.19696-1-trond.myklebust@hammerspace.com>
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
 fs/nfs/pagelist.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e54d899c1848..40b90f187eeb 100644
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
@@ -1061,6 +1070,9 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	desc->pg_error = PTR_ERR(subreq);
 	nfs_page_group_unlock(req);
 	return 0;
+out_cleanup_subreq:
+	nfs_pageio_cleanup_request(desc, subreq);
+	return 0;
 }
 
 static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
@@ -1168,11 +1180,14 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
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


Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDAB6C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9CBEC2184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VYAEVpgG"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730108AbfC2WCT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:19 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:37048 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730357AbfC2WCS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:18 -0400
Received: by mail-it1-f193.google.com with SMTP id u65so6272967itc.2
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jdgwFeJt3Z738l3o+CnVg/4n2MScy9svzu34YNhEasc=;
        b=VYAEVpgG0WaHQ04P8iwJ5C4liYKZ8TCBTQv5BfjbQDnv+7u5CuYt6m3kQnkCmWHpgD
         ebOzAvEzB7cAf7YuHfrr3k/0RuE4teaVoC5De5TYY654/2cTIORUDzh6JSv//0ggWnSV
         1WZsUu+EsEaTVVDPaz5AKyhiuCyn//h2jsmbNCH9Wp3kw8h65CE0TT1iBo1oNcI4YkAY
         a3XZQQd4HZOfFHo0ZqmckKpZt4WicyOG9q3zxaurUDFmHOOCAIjLGYUK/tNp1ohrPBSo
         vo8cr3i98WE+sSzuLrKix6SKo75/RYhBj5QZlfreqvJYf6+hom5n95NMydgMxZ8C/1aV
         aO0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=jdgwFeJt3Z738l3o+CnVg/4n2MScy9svzu34YNhEasc=;
        b=EswxIg26DpeEhNWvRUgBHK5LYOlLNoWQHYHWaQB7b/sBG/brB/j0PZIY82b79NyYy+
         G8Ges7vG81lqt3VcyeZbJXsihMeTVYTi2EjNzNGIZwZdufPOGvb11wMFVAwqITutWbl/
         Qs+ihnyfEn13mBH31CkcVhCilwCOEF9LqdO6JgTAHeSpv+qE0MGovRh1Df6+MFa1Wv+6
         ofr7qgcy8iGxDMyCLW/4U1SbfhgS4wMFJQPQ0IfJFqBGmJsxqevxcJAjUkAre+07qUfx
         RYI7siRmuoKQtaQRiNFfm6ET16RClRtwhwGjFTT5VqAyPpvojPPJpCHjJjkntnUyCWZq
         IBeA==
X-Gm-Message-State: APjAAAU/fasLpLGEL7NxxHME92faNu8d6DxXcB2V1GKXhybuJ1PM30gR
        wL5AdPO9ElwrtS9MxiQ9mnmwm3Q=
X-Google-Smtp-Source: APXvYqz+t8bUAu//HqmEBhb4WLEqAEdpriOm9/IUi8YEFD2AwJU9o2HjuAioVfoIwGX3cL/eOcW0Ww==
X-Received: by 2002:a24:2101:: with SMTP id e1mr6380345ita.151.1553896937169;
        Fri, 29 Mar 2019 15:02:17 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.16
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:16 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 25/28] pNFS: Add tracking to limit the number of pNFS retries
Date:   Fri, 29 Mar 2019 17:59:45 -0400
Message-Id: <20190329215948.107328-26-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-25-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
 <20190329215948.107328-10-trond.myklebust@hammerspace.com>
 <20190329215948.107328-11-trond.myklebust@hammerspace.com>
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
 <20190329215948.107328-14-trond.myklebust@hammerspace.com>
 <20190329215948.107328-15-trond.myklebust@hammerspace.com>
 <20190329215948.107328-16-trond.myklebust@hammerspace.com>
 <20190329215948.107328-17-trond.myklebust@hammerspace.com>
 <20190329215948.107328-18-trond.myklebust@hammerspace.com>
 <20190329215948.107328-19-trond.myklebust@hammerspace.com>
 <20190329215948.107328-20-trond.myklebust@hammerspace.com>
 <20190329215948.107328-21-trond.myklebust@hammerspace.com>
 <20190329215948.107328-22-trond.myklebust@hammerspace.com>
 <20190329215948.107328-23-trond.myklebust@hammerspace.com>
 <20190329215948.107328-24-trond.myklebust@hammerspace.com>
 <20190329215948.107328-25-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When the client is reading or writing using pNFS, and hits an error
on the DS, then it typically sends a LAYOUTERROR and/or LAYOUTRETURN
to the MDS, before redirtying the failed pages, and going for a new
round of reads/writebacks. The problem is that if the server has no
way to fix the DS, then we may need a way to interrupt this loop
after a set number of attempts have been made.
This patch adds an optional module parameter that allows the admin
to specify how many times to retry the read/writeback process before
failing with a fatal error.
The default behaviour is to retry forever.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/direct.c                        |  7 +++++++
 fs/nfs/flexfilelayout/flexfilelayout.c |  8 ++++++++
 fs/nfs/pagelist.c                      | 14 +++++++++++++-
 fs/nfs/write.c                         |  5 +++++
 include/linux/nfs_page.h               |  4 +++-
 5 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 2d301a1a73e2..2436bd92bc00 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -663,6 +663,8 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	}
 
 	list_for_each_entry_safe(req, tmp, &reqs, wb_list) {
+		/* Bump the transmission count */
+		req->wb_nio++;
 		if (!nfs_pageio_add_request(&desc, req)) {
 			nfs_list_move_request(req, &failed);
 			spin_lock(&cinfo.inode->i_lock);
@@ -703,6 +705,11 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
 		if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES) {
+			/*
+			 * Despite the reboot, the write was successful,
+			 * so reset wb_nio.
+			 */
+			req->wb_nio = 0;
 			/* Note the rewrite will go through mds */
 			nfs_mark_request_commit(req, NULL, &cinfo, 0);
 		} else
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 6673d4ff5a2a..9fdbcfd3e39d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -28,6 +28,8 @@
 #define FF_LAYOUT_POLL_RETRY_MAX     (15*HZ)
 #define FF_LAYOUTRETURN_MAXERR 20
 
+static unsigned short io_maxretrans;
+
 static void ff_layout_read_record_layoutstats_done(struct rpc_task *task,
 		struct nfs_pgio_header *hdr);
 static int ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
@@ -925,6 +927,7 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	pgm = &pgio->pg_mirrors[0];
 	pgm->pg_bsize = mirror->mirror_ds->ds_versions[0].rsize;
 
+	pgio->pg_maxretrans = io_maxretrans;
 	return;
 out_nolseg:
 	if (pgio->pg_error < 0)
@@ -992,6 +995,7 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 		pgm->pg_bsize = mirror->mirror_ds->ds_versions[0].wsize;
 	}
 
+	pgio->pg_maxretrans = io_maxretrans;
 	return;
 
 out_mds:
@@ -2515,3 +2519,7 @@ MODULE_DESCRIPTION("The NFSv4 flexfile layout driver");
 
 module_init(nfs4flexfilelayout_init);
 module_exit(nfs4flexfilelayout_exit);
+
+module_param(io_maxretrans, ushort, 0644);
+MODULE_PARM_DESC(io_maxretrans, "The  number of times the NFSv4.1 client "
+			"retries an I/O request before returning an error. ");
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b8301c40dd78..4a31284f411e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -16,8 +16,8 @@
 #include <linux/nfs.h>
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
-#include <linux/nfs_page.h>
 #include <linux/nfs_fs.h>
+#include <linux/nfs_page.h>
 #include <linux/nfs_mount.h>
 #include <linux/export.h>
 
@@ -327,6 +327,7 @@ __nfs_create_request(struct nfs_lock_context *l_ctx, struct page *page,
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
 	kref_init(&req->wb_kref);
+	req->wb_nio = 0;
 	return req;
 }
 
@@ -370,6 +371,7 @@ nfs_create_subreq(struct nfs_page *req, struct nfs_page *last,
 		nfs_lock_request(ret);
 		ret->wb_index = req->wb_index;
 		nfs_page_group_init(ret, last);
+		ret->wb_nio = req->wb_nio;
 	}
 	return ret;
 }
@@ -724,6 +726,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_mirrors_dynamic = NULL;
 	desc->pg_mirrors = desc->pg_mirrors_static;
 	nfs_pageio_mirror_init(&desc->pg_mirrors[0], bsize);
+	desc->pg_maxretrans = 0;
 }
 
 /**
@@ -983,6 +986,15 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 			return 0;
 		mirror->pg_base = req->wb_pgbase;
 	}
+
+	if (desc->pg_maxretrans && req->wb_nio > desc->pg_maxretrans) {
+		if (NFS_SERVER(desc->pg_inode)->flags & NFS_MOUNT_SOFTERR)
+			desc->pg_error = -ETIMEDOUT;
+		else
+			desc->pg_error = -EIO;
+		return 0;
+	}
+
 	if (!nfs_can_coalesce_requests(prev, req, desc))
 		return 0;
 	nfs_list_move_request(req, &mirror->pg_list);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0712d886ff08..908b166d635d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1009,6 +1009,8 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 			goto remove_req;
 		}
 		if (nfs_write_need_commit(hdr)) {
+			/* Reset wb_nio, since the write was successful. */
+			req->wb_nio = 0;
 			memcpy(&req->wb_verf, &hdr->verf.verifier, sizeof(req->wb_verf));
 			nfs_mark_request_commit(req, hdr->lseg, &cinfo,
 				hdr->pgio_mirror_idx);
@@ -1142,6 +1144,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		req->wb_bytes = end - req->wb_offset;
 	else
 		req->wb_bytes = rqend - req->wb_offset;
+	req->wb_nio = 0;
 	return req;
 out_flushme:
 	/*
@@ -1416,6 +1419,8 @@ static void nfs_initiate_write(struct nfs_pgio_header *hdr,
  */
 static void nfs_redirty_request(struct nfs_page *req)
 {
+	/* Bump the transmission count */
+	req->wb_nio++;
 	nfs_mark_request_dirty(req);
 	set_bit(NFS_CONTEXT_RESEND_WRITES, &req->wb_context->flags);
 	nfs_end_page_writeback(req);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index b7d0f15615c2..8b36800d342d 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -53,6 +53,7 @@ struct nfs_page {
 	struct nfs_write_verifier	wb_verf;	/* Commit cookie */
 	struct nfs_page		*wb_this_page;  /* list of reqs for this page */
 	struct nfs_page		*wb_head;       /* head pointer for req list */
+	unsigned short		wb_nio;		/* Number of I/O attempts */
 };
 
 struct nfs_pageio_descriptor;
@@ -87,7 +88,6 @@ struct nfs_pgio_mirror {
 };
 
 struct nfs_pageio_descriptor {
-	unsigned char		pg_moreio : 1;
 	struct inode		*pg_inode;
 	const struct nfs_pageio_ops *pg_ops;
 	const struct nfs_rw_ops *pg_rw_ops;
@@ -105,6 +105,8 @@ struct nfs_pageio_descriptor {
 	struct nfs_pgio_mirror	pg_mirrors_static[1];
 	struct nfs_pgio_mirror	*pg_mirrors_dynamic;
 	u32			pg_mirror_idx;	/* current mirror */
+	unsigned short		pg_maxretrans;
+	unsigned char		pg_moreio : 1;
 };
 
 /* arbitrarily selected limit to number of mirrors */
-- 
2.20.1


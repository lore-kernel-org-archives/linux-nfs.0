Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B79BCC10F03
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 841192084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ODMrNr+v"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726007AbfCAT1A (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:00 -0500
Received: from mail-yw1-f65.google.com ([209.85.161.65]:41021 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725905AbfCAT1A (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:00 -0500
Received: by mail-yw1-f65.google.com with SMTP id q128so14917217ywg.8
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:26:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=75ucBNCJFBy5BSZL+9Kwyk96Qx/3bmCyKZzdN3oSbO4=;
        b=ODMrNr+vVQFjaxp40icWZkpaN/rirtQIYiGSN9Dg90UMbJLAYlwzTR75EThu9BnqqU
         fmdJTbDoMZofOOu/a57C9M0sTNYd9ZYa1+J/MPhR6lK+RpSraRH1vo+4LAl6dKNiIJMI
         OVB/oGQ6KS67gd3KayrG8C7U1PvP1HeF+pE2yeR8c0ObA8LKfZCx4uK4p+hMTEMwHF+Z
         gLRB/k/zt4pRs4Vxq4OthnQTS3C7neASTRNMJk3QlNHDncR1DT+hM/jTSbxY17MP6GDx
         QIpzmFqu5MZhzdFP2oasufkQSFm1BswJynI6abOvdvAhI4C1uW3ZMcWLgzs2jtER/p/9
         dxRw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=75ucBNCJFBy5BSZL+9Kwyk96Qx/3bmCyKZzdN3oSbO4=;
        b=FsY/iDwHHlyRxUA+4HcEnEXDH6NhAIAPEjatNawJb0d5ImKPy8lYViPY+y22HnY1AY
         O1RBWUEHziQrayOMMJR1cZ3Zh6FSJDo2Bvp+Uf51DIy1XpRhIPusPO6xucqzu8EvPgK9
         RBqEM7PDlhdxR/5shNqVI0gwUOnGfipzFpWTieMR54+/S7qtv1wOXxLdiHysK3a+rJ/a
         icZM10v5Z4RM31vlnhFfUcnutFKSskuN6MWw6DTwC1Z4MuxwXd1eiIMj3CdwdPGgXdIp
         /axQcPE8pmFnxrpFy0bVgk3Fnkn28UNfZg29fY2/kj/eFrH0TaDaP/+7IBDFkguBajtJ
         YiTA==
X-Gm-Message-State: APjAAAXyMH5ghKSY3aU47XiTi2TMobkazbINMyxRQr/Bw5MAKN/aUS5/
        lnFMw37fsVBT2jyhUPPgcQflqf8=
X-Google-Smtp-Source: APXvYqwNaJ44/vYYMVZImm8dZO7o/0wWDozNqgIV0PCAzw+h5SrV3zGTf5hzIRG5vhQmtHNrVs5moQ==
X-Received: by 2002:a25:4e8a:: with SMTP id c132mr5500874ybb.458.1551468418418;
        Fri, 01 Mar 2019 11:26:58 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.26.57
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:26:57 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 06/19] NFS/flexfiles: Send LAYOUTERROR when failing over mirrored reads
Date:   Fri,  1 Mar 2019 14:24:42 -0500
Message-Id: <20190301192455.104943-7-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-6-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
 <20190301192455.104943-5-trond.myklebust@hammerspace.com>
 <20190301192455.104943-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When a read to the preferred mirror returns an error, the flexfiles
driver records the error in the inode list and currently marks the
layout for return before failing over the attempted read to the next
mirror.
What we actually want to do is fire off a LAYOUTERROR to notify the
MDS that there is an issue with the preferred mirror, then we fail
over. Only once we've failed to read from all mirrors should we
return the layout.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 53 ++++++++++++++++++++---
 fs/nfs/flexfilelayout/flexfilelayout.h    |  1 +
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  2 +-
 3 files changed, 50 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index a8e9bdd978e7..5ba30084f248 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1252,7 +1252,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 		if (ff_layout_choose_best_ds_for_read(hdr->lseg,
 					hdr->pgio_mirror_idx + 1,
 					&hdr->pgio_mirror_idx))
-			goto out_eagain;
+			goto out_layouterror;
 		set_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
 		return task->tk_status;
 	case -NFS4ERR_RESET_TO_MDS:
@@ -1263,6 +1263,8 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	}
 
 	return 0;
+out_layouterror:
+	ff_layout_send_layouterror(hdr->lseg);
 out_eagain:
 	rpc_restart_call_prepare(task);
 	return -EAGAIN;
@@ -1412,9 +1414,10 @@ static void ff_layout_read_release(void *data)
 	struct nfs_pgio_header *hdr = data;
 
 	ff_layout_read_record_layoutstats_done(&hdr->task, hdr);
-	if (test_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags))
+	if (test_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags)) {
+		ff_layout_send_layouterror(hdr->lseg);
 		pnfs_read_resend_pnfs(hdr);
-	else if (test_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags))
+	} else if (test_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags))
 		ff_layout_reset_read(hdr);
 	pnfs_generic_rw_release(data);
 }
@@ -1586,9 +1589,10 @@ static void ff_layout_write_release(void *data)
 	struct nfs_pgio_header *hdr = data;
 
 	ff_layout_write_record_layoutstats_done(&hdr->task, hdr);
-	if (test_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags))
+	if (test_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags)) {
+		ff_layout_send_layouterror(hdr->lseg);
 		ff_layout_reset_write(hdr, true);
-	else if (test_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags))
+	} else if (test_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags))
 		ff_layout_reset_write(hdr, false);
 	pnfs_generic_rw_release(data);
 }
@@ -2119,6 +2123,45 @@ ff_layout_prepare_layoutreturn(struct nfs4_layoutreturn_args *args)
 	return -ENOMEM;
 }
 
+void
+ff_layout_send_layouterror(struct pnfs_layout_segment *lseg)
+{
+	struct pnfs_layout_hdr *lo = lseg->pls_layout;
+	struct nfs42_layout_error *errors;
+	LIST_HEAD(head);
+
+	if (!nfs_server_capable(lo->plh_inode, NFS_CAP_LAYOUTERROR))
+		return;
+	ff_layout_fetch_ds_ioerr(lo, &lseg->pls_range, &head, -1);
+	if (list_empty(&head))
+		return;
+
+	errors = kmalloc_array(NFS42_LAYOUTERROR_MAX,
+			sizeof(*errors), GFP_NOFS);
+	if (errors != NULL) {
+		const struct nfs4_ff_layout_ds_err *pos;
+		size_t n = 0;
+
+		list_for_each_entry(pos, &head, list) {
+			errors[n].offset = pos->offset;
+			errors[n].length = pos->length;
+			nfs4_stateid_copy(&errors[n].stateid, &pos->stateid);
+			errors[n].errors[0].dev_id = pos->deviceid;
+			errors[n].errors[0].status = pos->status;
+			errors[n].errors[0].opnum = pos->opnum;
+			n++;
+			if (!list_is_last(&pos->list, &head) &&
+			    n < NFS42_LAYOUTERROR_MAX)
+				continue;
+			if (nfs42_proc_layouterror(lseg, errors, n) < 0)
+				break;
+			n = 0;
+		}
+		kfree(errors);
+	}
+	ff_layout_free_ds_ioerr(&head);
+}
+
 static int
 ff_layout_ntop4(const struct sockaddr *sap, char *buf, const size_t buflen)
 {
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 8a2d5d630af9..31a62820a5c6 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -213,6 +213,7 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 			     struct nfs4_ff_layout_mirror *mirror, u64 offset,
 			     u64 length, int status, enum nfs_opnum4 opnum,
 			     gfp_t gfp_flags);
+void ff_layout_send_layouterror(struct pnfs_layout_segment *lseg);
 int ff_layout_encode_ds_ioerr(struct xdr_stream *xdr, const struct list_head *head);
 void ff_layout_free_ds_ioerr(struct list_head *head);
 unsigned int ff_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index ca7a6203b3cb..c174f23afc6d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -326,7 +326,6 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 	spin_lock(&flo->generic_hdr.plh_inode->i_lock);
 	ff_layout_add_ds_error_locked(flo, dserr);
 	spin_unlock(&flo->generic_hdr.plh_inode->i_lock);
-
 	return 0;
 }
 
@@ -458,6 +457,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 				 mirror, lseg->pls_range.offset,
 				 lseg->pls_range.length, NFS4ERR_NXIO,
 				 OP_ILLEGAL, GFP_NOIO);
+	ff_layout_send_layouterror(lseg);
 	if (fail_return || !ff_layout_has_available_ds(lseg))
 		pnfs_error_mark_layout_for_return(ino, lseg);
 	ds = NULL;
-- 
2.20.1


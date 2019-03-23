Return-Path: <SRS0=9F0h=R2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9B81C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 16:06:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6B76C20879
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 16:06:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kjSkKyrO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727457AbfCWQGt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 23 Mar 2019 12:06:49 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:36455 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727372AbfCWQGt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Mar 2019 12:06:49 -0400
Received: by mail-it1-f196.google.com with SMTP id h9so7940752itl.1
        for <linux-nfs@vger.kernel.org>; Sat, 23 Mar 2019 09:06:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=qQqwycziG6B+bSmp/KTPC+TXgExeaBqaS9wUvVR2lio=;
        b=kjSkKyrOyVVdHo3rDxxmhFagykVjTGLkiQxbr+i6KGRQyhMx2kutvL2VRNlGsrfoJB
         E0H8PF3VhRIs8B5IxSKNRlFuX3y/t8RUXRx951oICjV39BmZp0zXOr641PmVMFK3PHjw
         OP1ienYVa7M2ysCRjCkbw40e1RmwYGLSr+jcZa7zAQdyLgcXCQ/9TaOIl2Da4mu0Xugu
         PzK4244xNwKWyMKgAkZU9TlNfwUGAqieywlnOZ57s7t2r2lTQXkX8VioONX3xfVfSpe9
         5x7mn+PwTlib88Lvz0lQTjeFR9BM0Wrd0xSsd8Gdh9hS3gdJib+bsNPByhomtJYCTs5S
         bLow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=qQqwycziG6B+bSmp/KTPC+TXgExeaBqaS9wUvVR2lio=;
        b=sqX8SK4XU+vsCUepPKb/utu44Wb27jFNz8C92GsO3tCyvlXOBqfQIVmVhOkrx8fSIb
         0yX++XsBU6bvfg09Cux/0w7NQypoxqFNZcvL3nGOK6tQ/H2VEz3YDcThCgHKL3pq+yzx
         UwxnU93blCv++ahFvy/BI6Ltji3Bsueej9PjNIdFIMvbCNAmwztccw8oL5dO3cLCj7Uj
         xfIw5RV78nkRElJ9sxJz5hBk/95Bg7jHLzI6TIKJuGiO+opPiNEqyXA9Z1xGTsm8/n7E
         yBYTs/cUgvHWOP+Wyn/5Sqpvi3hDQEG+/klHRsoau/FFBwmb1PawSFhNH9UrhK2d7+Ca
         Es4Q==
X-Gm-Message-State: APjAAAWg2nMt4BtlXv/lOKm+XgmQzDOYsN4+VekalgoLmORebrj+1O44
        lKXdvW2UA+IKVXUG9+LyUVnb1Ic=
X-Google-Smtp-Source: APXvYqzeKAksU6l6EIFJ+ZwmLvnmvg2hSCPH/Kos8m+Z2otJh4+es5Ig2VJikqJOF2/IDchditHSKw==
X-Received: by 2002:a24:eb0e:: with SMTP id h14mr2471085itj.100.1553357208285;
        Sat, 23 Mar 2019 09:06:48 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id z22sm4540230ioc.68.2019.03.23.09.06.47
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 23 Mar 2019 09:06:47 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: Fix layoutstats handling during read failovers
Date:   Sat, 23 Mar 2019 12:03:21 -0400
Message-Id: <20190323160321.23340-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

During a read failover, we may end up changing the value of
the pgio_mirror_idx, so make sure that we record the layout
stats before that update.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index f9264e1922a2..6673d4ff5a2a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1289,6 +1289,7 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 static int ff_layout_read_done_cb(struct rpc_task *task,
 				struct nfs_pgio_header *hdr)
 {
+	int new_idx = hdr->pgio_mirror_idx;
 	int err;
 
 	trace_nfs4_pnfs_read(hdr, task->tk_status);
@@ -1307,7 +1308,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	case -NFS4ERR_RESET_TO_PNFS:
 		if (ff_layout_choose_best_ds_for_read(hdr->lseg,
 					hdr->pgio_mirror_idx + 1,
-					&hdr->pgio_mirror_idx))
+					&new_idx))
 			goto out_layouterror;
 		set_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
 		return task->tk_status;
@@ -1320,7 +1321,9 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 
 	return 0;
 out_layouterror:
+	ff_layout_read_record_layoutstats_done(task, hdr);
 	ff_layout_send_layouterror(hdr->lseg);
+	hdr->pgio_mirror_idx = new_idx;
 out_eagain:
 	rpc_restart_call_prepare(task);
 	return -EAGAIN;
-- 
2.20.1


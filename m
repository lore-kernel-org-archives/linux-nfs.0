Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 643B3C4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 325BF2084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FAVC6vMJ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726096AbfCAT1J (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:09 -0500
Received: from mail-yw1-f67.google.com ([209.85.161.67]:44049 "EHLO
        mail-yw1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726042AbfCAT1J (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:09 -0500
Received: by mail-yw1-f67.google.com with SMTP id x21so14913500ywx.11
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Cn/abcJfxwSkjRAp/v7zc26eWtb57oX2PSsFig6Yu1s=;
        b=FAVC6vMJrRxCjgC6LqS3k0Kpd3PbmJfZsWlIwxfH4cnkpZnyDKhnpAOrfo9gfB/pqc
         Xor1Vmmhr1lpif66US0vYVBDSQqb0oeIVpIx1HVpH4wblPPTaGeZ7UGkIGFn+3nUcApg
         1NnFt6RIIWRbISqfHZWh+/bDvFtoxq6kyWMtWazhp86Lt/OxxaZ6ShOXXIvsG0iz1ide
         YWkG7soNoiHl60ZOKeV/LmKzfAqJLcq7JfRofbLKuiGki6XMM9O6ZyIWIVk2p1QWuq+j
         QjGLArED3v2ga3gKdANLLCSvjNJU+6XXnnh11FvKlvoCvXa5P1FowPpQ2fzMRFM/IYp8
         qu1w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Cn/abcJfxwSkjRAp/v7zc26eWtb57oX2PSsFig6Yu1s=;
        b=Ra8y5tYyyuT9oBMvKwVSW99NQIEx6pWmb/7cIFR4SoZDoLtWYYfnp5Cu3Qcejs6MOW
         29ioIguAyXkKb8a78VfJOIAarHvUbws6Z5FYPxYuklQdrNUx+W8x1wzSN6TifqwJOcGN
         uoTL4ttYK882NVJmHFyOvr6pxkLhUFJGYB2dxwErWSVMIX08tQtRLXC1m5tFF2YiPT0h
         FaB+AxWEHEx5FKRtvGnsMGTfsWr6Fi2yaiD8hGrYFRdqG+WgUwh8DqxaG/4t8YpSOH1B
         irFpys4QsJdQg/ySB5stWvvOesSLgRuZY+A28O9nlLftTffILQMhVS95U4oBmX3opgCK
         Ov+w==
X-Gm-Message-State: APjAAAXsv8H0l/niN77sSP2mcyapdoxtJI2ijSny6cWUpwOkVf551Jmw
        b6dcbUKk4qwOQTAC+LaED7CC9wA=
X-Google-Smtp-Source: APXvYqwVn9KOpQ33wmjowb7tva+QcaWB/PcaqjH06IRaToKJfIjtKwnhCw4C0nGyTwjLysRQLVYssQ==
X-Received: by 2002:a25:874f:: with SMTP id e15mr5507097ybn.416.1551468427601;
        Fri, 01 Mar 2019 11:27:07 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.06
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:06 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 16/19] NFS/flexfile: Simplify nfs4_ff_layout_ds_version()
Date:   Fri,  1 Mar 2019 14:24:52 -0500
Message-Id: <20190301192455.104943-17-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-16-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
 <20190301192455.104943-5-trond.myklebust@hammerspace.com>
 <20190301192455.104943-6-trond.myklebust@hammerspace.com>
 <20190301192455.104943-7-trond.myklebust@hammerspace.com>
 <20190301192455.104943-8-trond.myklebust@hammerspace.com>
 <20190301192455.104943-9-trond.myklebust@hammerspace.com>
 <20190301192455.104943-10-trond.myklebust@hammerspace.com>
 <20190301192455.104943-11-trond.myklebust@hammerspace.com>
 <20190301192455.104943-12-trond.myklebust@hammerspace.com>
 <20190301192455.104943-13-trond.myklebust@hammerspace.com>
 <20190301192455.104943-14-trond.myklebust@hammerspace.com>
 <20190301192455.104943-15-trond.myklebust@hammerspace.com>
 <20190301192455.104943-16-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Pass in a pointer to the mirror rather than forcing another
array access.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 6 +++---
 fs/nfs/flexfilelayout/flexfilelayout.h | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 57776de619b5..94515856b357 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1787,7 +1787,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	if (!ds_cred)
 		goto out_failed;
 
-	vers = nfs4_ff_layout_ds_version(lseg, idx);
+	vers = nfs4_ff_layout_ds_version(mirror);
 
 	dprintk("%s USE DS: %s cl_count %d vers %d\n", __func__,
 		ds->ds_remotestr, refcount_read(&ds->ds_clp->cl_count), vers);
@@ -1852,7 +1852,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	if (!ds_cred)
 		goto out_failed;
 
-	vers = nfs4_ff_layout_ds_version(lseg, idx);
+	vers = nfs4_ff_layout_ds_version(mirror);
 
 	dprintk("%s ino %lu sync %d req %zu@%llu DS: %s cl_count %d vers %d\n",
 		__func__, hdr->inode->i_ino, sync, (size_t) hdr->args.count,
@@ -1937,7 +1937,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	if (!ds_cred)
 		goto out_err;
 
-	vers = nfs4_ff_layout_ds_version(lseg, idx);
+	vers = nfs4_ff_layout_ds_version(mirror);
 
 	dprintk("%s ino %lu, how %d cl_count %d vers %d\n", __func__,
 		data->inode->i_ino, how, refcount_read(&ds->ds_clp->cl_count),
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index e0b2c3deae5a..99cfe2e8f32a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -181,9 +181,9 @@ ff_layout_no_read_on_rw(struct pnfs_layout_segment *lseg)
 }
 
 static inline int
-nfs4_ff_layout_ds_version(struct pnfs_layout_segment *lseg, u32 ds_idx)
+nfs4_ff_layout_ds_version(const struct nfs4_ff_layout_mirror *mirror)
 {
-	return FF_LAYOUT_COMP(lseg, ds_idx)->mirror_ds->ds_versions[0].version;
+	return mirror->mirror_ds->ds_versions[0].version;
 }
 
 struct nfs4_ff_layout_ds *
-- 
2.20.1


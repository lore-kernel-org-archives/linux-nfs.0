Return-Path: <SRS0=UHwe=23=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2340C33C8C
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jan 2020 18:42:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 92589208C4
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jan 2020 18:42:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W4xGHND0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726723AbgAFSmv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Jan 2020 13:42:51 -0500
Received: from mail-yw1-f67.google.com ([209.85.161.67]:40302 "EHLO
        mail-yw1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726612AbgAFSmu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2020 13:42:50 -0500
Received: by mail-yw1-f67.google.com with SMTP id i126so22282143ywe.7
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2020 10:42:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vACpPc0PMx+n43w6tqWR0yHmw949Y64vBySvDL6VgHY=;
        b=W4xGHND0YxPgCe+Y/DO5xJlY5ycb3sRBWIXqiYnJiStrArhJqVqw5TheeSj7D3tdgm
         G239WfP7oeOxuSMeZSEqcVZ/sQNUTCPMnE4SRdgTW8mV4ujChUQRLaRNeIenIyWQYv0N
         j4H3M11OUlPbY0v636WdmAltsblrbqT0PQ5fotBomIc9d8DNvPxuazrdUPAIpI2191Wk
         1DHCGYA2uPIPLCfeZFobaj35GK38ogCOt9tX7tocWY8B4a/TbTtsW7cOf4ui0x5vgFMn
         CltKvNZbL/c8Esmz1njzf1YJGU+n71Eq4M7Mjh7VQPusxMTz9YAkFaqo5ha1FL31cdEq
         nMXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=vACpPc0PMx+n43w6tqWR0yHmw949Y64vBySvDL6VgHY=;
        b=aZX4cIPjoyIP9r8zd7Kc2t8pgdy5UFSBYj8sHjc3Zi6mEELlajSQk3+xWoFvgiB4G1
         SKAOgJjJggEOwkjThgyI20KTJwDE/FOFvnCNq9qJah0nAQK/HUH2oNXaOOEU0LtzFcio
         OTsWdXucN+OvSM5g9ZY9T5bsGaZmR8Q8XeGthyR+bSPSGwtkF9WqLzea+/MX2o1H918t
         KrKQiVU+ki3m7bTMBybcmXxN8T9MYrTKd6gpjGQiDYIAki9FUwUsa2BAdAJW1ucYSKIK
         367Bo4WLIUah7smMcoV0MXh3kbh2Hk6yn0cJT8g2a4/jlkvY3ofjuPTuAMwRPAIo9WFa
         F27A==
X-Gm-Message-State: APjAAAWY0VZzRg1x6dmJ8q/O7aqQIp6jMJidiGVujR3wOC3iPEJQAG3f
        OYxBUQw3geT2yAPcSB8v5g==
X-Google-Smtp-Source: APXvYqzwwE5xnTRs8cB7Lea1o5ozQ2+ZwY+Ou3ujlBCY2wN6cxIyXEiRGo6OSGixsi1DQhbtxrtAAQ==
X-Received: by 2002:a81:1b88:: with SMTP id b130mr79231322ywb.514.1578336169630;
        Mon, 06 Jan 2020 10:42:49 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id u136sm28223497ywf.101.2020.01.06.10.42.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 06 Jan 2020 10:42:48 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] nfsd: Fix stable writes
Date:   Mon,  6 Jan 2020 13:40:30 -0500
Message-Id: <20200106184037.563557-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.24.1
In-Reply-To: <20200106184037.563557-2-trond.myklebust@hammerspace.com>
References: <20200106184037.563557-1-trond.myklebust@hammerspace.com>
 <20200106184037.563557-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Strictly speaking, a stable write error needs to reflect the
write + the commit of that write (and only that write). To
ensure that we don't pick up the write errors from other
writebacks, add a rw_semaphore to provide exclusion.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/filecache.c |  1 +
 fs/nfsd/filecache.h |  1 +
 fs/nfsd/vfs.c       | 18 ++++++++++++++++--
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index f275c11c4e28..2fadf080ac42 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -195,6 +195,7 @@ nfsd_file_alloc(struct inode *inode, unsigned int may, unsigned int hashval,
 				__set_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
 		}
 		nf->nf_mark = NULL;
+		init_rwsem(&nf->nf_rwsem);
 		trace_nfsd_file_alloc(nf);
 	}
 	return nf;
diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
index 79a7d6808d97..986c325a54bd 100644
--- a/fs/nfsd/filecache.h
+++ b/fs/nfsd/filecache.h
@@ -46,6 +46,7 @@ struct nfsd_file {
 	atomic_t		nf_ref;
 	unsigned char		nf_may;
 	struct nfsd_file_mark	*nf_mark;
+	struct rw_semaphore	nf_rwsem;
 };
 
 int nfsd_file_cache_init(void);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 69cbdb62b262..218b8293c633 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -982,7 +982,18 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfsd_file *nf,
 		flags |= RWF_SYNC;
 
 	iov_iter_kvec(&iter, WRITE, vec, vlen, *cnt);
-	host_err = vfs_iter_write(file, &iter, &pos, flags);
+	if (flags & RWF_SYNC) {
+		down_write(&nf->nf_rwsem);
+		host_err = vfs_iter_write(file, &iter, &pos, flags);
+		if (host_err < 0)
+			nfsd_reset_boot_verifier(net_generic(SVC_NET(rqstp),
+						 nfsd_net_id));
+		up_write(&nf->nf_rwsem);
+	} else {
+		down_read(&nf->nf_rwsem);
+		host_err = vfs_iter_write(file, &iter, &pos, flags);
+		up_read(&nf->nf_rwsem);
+	}
 	if (host_err < 0)
 		goto out_nfserr;
 	*cnt = host_err;
@@ -1097,8 +1108,10 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (err)
 		goto out;
 	if (EX_ISSYNC(fhp->fh_export)) {
-		int err2 = vfs_fsync_range(nf->nf_file, offset, end, 0);
+		int err2;
 
+		down_write(&nf->nf_rwsem);
+		err2 = vfs_fsync_range(nf->nf_file, offset, end, 0);
 		switch (err2) {
 		case 0:
 			break;
@@ -1110,6 +1123,7 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			nfsd_reset_boot_verifier(net_generic(nf->nf_net,
 						 nfsd_net_id));
 		}
+		up_write(&nf->nf_rwsem);
 	}
 
 	nfsd_file_put(nf);
-- 
2.24.1


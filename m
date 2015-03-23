Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36076 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbbCWOx5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 10:53:57 -0400
Received: by ykcn8 with SMTP id n8so72914740ykc.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2015 07:53:57 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] nfsd: remove bogus setting of status in nfsd4_process_open2
Date: Mon, 23 Mar 2015 10:53:43 -0400
Message-Id: <1427122424-8078-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

status is always reset after this (and it doesn't make much sense there
anyway).

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cf29d1a698b3..a66e297dc01c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4049,7 +4049,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		status = nfserr_bad_stateid;
 		if (nfsd4_is_deleg_cur(open))
 			goto out;
-		status = nfserr_jukebox;
 	}
 
 	/*
-- 
2.1.0


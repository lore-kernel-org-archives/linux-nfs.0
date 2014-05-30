Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:61787 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498AbaE3NJw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 09:09:52 -0400
Received: by mail-qg0-f44.google.com with SMTP id i50so5227761qgf.31
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 06:09:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 5/9] nfsd: remove unneeded zeroing of fields in nfsd4_proc_compound
Date: Fri, 30 May 2014 09:09:29 -0400
Message-Id: <1401455373-18207-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The memset of resp in svc_process_common should ensure that these are
already zeroed by the time they get here.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4proc.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a1e16103a0bf..9e7846e19ea6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1292,11 +1292,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	xdr_reserve_space(&resp->xdr, 8 + args->taglen);
 	resp->taglen = args->taglen;
 	resp->tag = args->tag;
-	resp->opcnt = 0;
 	resp->rqstp = rqstp;
 	cstate->minorversion = args->minorversion;
-	cstate->replay_owner = NULL;
-	cstate->session = NULL;
 	fh_init(current_fh, NFS4_FHSIZE);
 	fh_init(save_fh, NFS4_FHSIZE);
 	/*
-- 
1.9.3


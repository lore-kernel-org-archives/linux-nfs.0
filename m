Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:51785 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbaDRSpH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:07 -0400
Received: by mail-ig0-f180.google.com with SMTP id c1so938851igq.13
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:06 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 01/70] NFSd: Ensure we clear the cstate->slot in nfsd4_proc_compound
Date: Fri, 18 Apr 2014 14:43:55 -0400
Message-Id: <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise, we may end up triggering all those nfsd4_has_session()
tests.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d543222babf3..8eabbfb25441 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1293,6 +1293,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	cstate->minorversion = args->minorversion;
 	cstate->replay_owner = NULL;
 	cstate->session = NULL;
+	cstate->slot = NULL;
 	fh_init(current_fh, NFS4_FHSIZE);
 	fh_init(save_fh, NFS4_FHSIZE);
 	/*
-- 
1.9.0


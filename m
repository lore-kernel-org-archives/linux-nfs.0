Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42406 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758066Ab0HLHF7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Aug 2010 03:05:59 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 12 Aug 2010 17:04:07 +1000
Subject: [PATCH 4/6] nfsd: disable deferral for NFSv4
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100812070407.11459.2929.stgit@localhost.localdomain>
In-Reply-To: <20100812065722.11459.18978.stgit@localhost.localdomain>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Now that a slight delay in getting a reply to an upcall doesn't
require deferring of requests, request deferral for all NFSv4
requests - the concept doesn't really fit with the v4 model.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 59ec449..fca3621 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1031,8 +1031,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	resp->cstate.session = NULL;
 	fh_init(&resp->cstate.current_fh, NFS4_FHSIZE);
 	fh_init(&resp->cstate.save_fh, NFS4_FHSIZE);
-	/* Use the deferral mechanism only for NFSv4.0 compounds */
-	rqstp->rq_usedeferral = (args->minorversion == 0);
+	/* Don't use the deferral mechanism NFSv4. */
+	rqstp->rq_usedeferral = 0;
 
 	/*
 	 * According to RFC3010, this takes precedence over all other errors.



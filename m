From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 037/100] nfsd4: fix bad seqid on lock request incompatible with open mode
Date: Fri, 25 Jan 2008 18:16:17 -0500
Message-ID: <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>,
	Steven Wilton <steven.wilton@team.eftel.com.au>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47408 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932077AbYAYXRm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:42 -0500
In-Reply-To: <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The failure to return a stateowner from nfs4_preprocess_seqid_op() means
in the case where a lock request is of a type incompatible with an open
(due to, e.g., an application attempting a write lock on a file open for
read), means that fs/nfsd/nfs4xdr.c:ENCODE_SEQID_OP_TAIL() never bumps
the seqid as it should.  The client, attempting to close the file
afterwards, then gets an (incorrect) bad sequence id error.  Worse, this
prevents the open file from ever being closed, so we leak state.

Thanks to Benny Halevy and Trond Myklebust for analysis, and to Steven
Wilton for the report and extensive data-gathering.

Cc: Benny Halevy <bhalevy@panasas.com>
Cc: Steven Wilton <steven.wilton@team.eftel.com.au>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 409fa35..9320b7f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2093,8 +2093,10 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *statei
 		goto check_replay;
 	}
 
+	*stpp = stp;
+	*sopp = sop = stp->st_stateowner;
+
 	if (lock) {
-		struct nfs4_stateowner *sop = stp->st_stateowner;
 		clientid_t *lockclid = &lock->v.new.clientid;
 		struct nfs4_client *clp = sop->so_client;
 		int lkflg = 0;
@@ -2124,9 +2126,6 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *statei
 		return nfserr_bad_stateid;
 	}
 
-	*stpp = stp;
-	*sopp = sop = stp->st_stateowner;
-
 	/*
 	*  We now validate the seqid and stateid generation numbers.
 	*  For the moment, we ignore the possibility of 
-- 
1.5.4.rc2.60.gb2e62


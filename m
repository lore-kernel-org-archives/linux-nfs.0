Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60885 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756355Ab1HSRYR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 13:24:17 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1QuSno-0000JY-Ur
	for linux-nfs@vger.kernel.org; Fri, 19 Aug 2011 13:24:16 -0400
Date: Fri, 19 Aug 2011 13:24:16 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: fix seqid_mutating_error
Message-ID: <20110819172416.GA1112@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Yipes--noticed while doing some unrelated v4 state work.  I'll probably
send this along soonish.

--b.

commit 8eea0f78ed3f3238e238c8ca76e5c7a5c1e7b5f5
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Aug 10 19:16:22 2011 -0400

    nfsd4: fix seqid_mutating_error
    
    The set of errors here does *not* agree with the set of errors specified
    in the rfc!
    
    While we're there, turn this macros into a function, for the usual
    reasons, and move it to the one place where it's actually used.
    
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c8bf405..f810996 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1623,6 +1623,18 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 								\
 	save = resp->p;
 
+static bool seqid_mutating_err(__be32 err)
+{
+	/* rfc 3530 section 8.1.5: */
+	return	err != nfserr_stale_clientid &&
+		err != nfserr_stale_stateid &&
+		err != nfserr_bad_stateid &&
+		err != nfserr_bad_seqid &&
+		err != nfserr_bad_xdr &&
+		err != nfserr_resource &&
+		err != nfserr_nofilehandle;
+}
+
 /*
  * Routine for encoding the result of a "seqid-mutating" NFSv4 operation.  This
  * is where sequence id's are incremented, and the replay cache is filled.
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 4eefaf1..5cfebe5 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -447,12 +447,6 @@ struct nfs4_stateid {
 #define WR_STATE	        0x00000020
 #define CLOSE_STATE             0x00000040
 
-#define seqid_mutating_err(err)                       \
-	(((err) != nfserr_stale_clientid) &&    \
-	((err) != nfserr_bad_seqid) &&          \
-	((err) != nfserr_stale_stateid) &&      \
-	((err) != nfserr_bad_stateid))
-
 struct nfsd4_compound_state;
 
 extern __be32 nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,

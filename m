Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51740 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752188Ab1F3SrG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2011 14:47:06 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1QcMGW-00052k-OT
	for linux-nfs@vger.kernel.org; Thu, 30 Jun 2011 14:47:04 -0400
Date: Thu, 30 Jun 2011 14:47:04 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: allow secinfo to bypass gss checks
Message-ID: <20110630184704.GD18713@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Also planning to queue this up for 3.1....  Objections?

commit ea53eb9a87848610f1a2465881d8ef6ab6c62c59
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Jun 29 18:33:11 2011 -0400

    nfsd: allow secinfo to bypass gss checks
    
    PUTFH+SECINFO should succeed and return a security list even when using
    an authentication flavor not permitted on the given filehandle.
    
    There's the risk of a small information leak here: as part of the
    SECINFO, we have to do a lookup.  If that lookup fails, we return the
    error from that lookup instead of a secinfo list.  That allows an
    unprivileged user to answer the question "does a file named $x exist in
    directory $d" by guessing a filehandle for $d and then sending a secinfo
    request for $x and seeing whether or not they get NFS4ERR_NOENT.
    
    To avoid that, we return secinfo for the parent in the NOENT case.
    
    Reported-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 96b6929..4f9c90b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -762,19 +762,34 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 err;
 
 	fh_init(&resfh, NFS4_FHSIZE);
-	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR, NFSD_MAY_EXEC);
+	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
+					NFSD_MAY_EXEC|NFSD_MAY_BYPASS_GSS);
 	if (err)
 		return err;
+	/*
+	 * XXX: arguably we should do this with elevated privileges, to
+	 * ensure consistent results regardless of the cred used by the
+	 * client:
+	 */
 	err = nfsd_lookup_dentry(rqstp, &cstate->current_fh,
 				    secinfo->si_name, secinfo->si_namelen,
 				    &exp, &dentry);
 	if (err)
 		return err;
 	if (dentry->d_inode == NULL) {
+		/*
+		 * An nfserr_noent return would tell the rpc caller
+		 * (who may be unprivileged) that a file by that name
+		 * does not exist in this directory.  That may be
+		 * information we don't want to give out.  So return
+		 * secinfo list for the parent in that case instead of
+		 * failing here.
+		 */
 		exp_put(exp);
-		err = nfserr_noent;
-	} else
-		secinfo->si_exp = exp;
+		exp = cstate->current_fh.fh_export;
+		exp_get(exp);
+	}
+	secinfo->si_exp = exp;
 	dput(dentry);
 	if (cstate->minorversion)
 		/* See rfc 5661 section 2.6.3.1.1.8 */

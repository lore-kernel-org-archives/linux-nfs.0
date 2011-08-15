Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40509 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091Ab1HOWso (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 18:48:44 -0400
Date: Mon, 15 Aug 2011 18:48:43 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] nfsd: clean up nfsd_mode_check()
Message-ID: <20110815224843.GA1624@fieldses.org>
References: <20110815222859.GD32181@fieldses.org>
 <1313447432-1537-5-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1313447432-1537-5-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Also noticed while auditing these error returns.  There's all kinds of
weird crap in here.

--b.

commit fe0a6f4711dba408fb771a402876db33ffe219bf
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Aug 15 18:39:32 2011 -0400

    nfsd4: it's OK to return nfserr_symlink
    
    The nfsd4 code has a bunch of special exceptions for error returns which
    map nfserr_symlink to other errors.
    
    In fact, the spec makes it clear that nfserr_symlink is to be preferred
    over less specific errors where possible.
    
    The patch that introduced it back in 2.6.4 is "kNFSd: correct symlink
    related error returns.", which claims that these special exceptions are
    represent an NFSv4 break from v2/v3 tradition--when in fact the symlink
    error was introduced with v4.
    
    I suspect what happened was pynfs tests were written that were overly
    faithful to the (known-incomplete) rfc3530 error return lists, and then
    code was fixed up mindlessly to make the tests pass.
    
    Delete these unnecessary exceptions.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9bf0a66..3b159ab 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -473,11 +473,8 @@ nfsd4_commit(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	*p++ = nfssvc_boot.tv_sec;
 	*p++ = nfssvc_boot.tv_usec;
 
-	status = nfsd_commit(rqstp, &cstate->current_fh, commit->co_offset,
+	return nfsd_commit(rqstp, &cstate->current_fh, commit->co_offset,
 			     commit->co_count);
-	if (status == nfserr_symlink)
-		status = nfserr_inval;
-	return status;
 }
 
 static __be32
@@ -492,8 +489,6 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	status = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
 			   NFSD_MAY_CREATE);
-	if (status == nfserr_symlink)
-		status = nfserr_notdir;
 	if (status)
 		return status;
 
@@ -719,8 +714,6 @@ nfsd4_remove(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_grace;
 	status = nfsd_unlink(rqstp, &cstate->current_fh, 0,
 			     remove->rm_name, remove->rm_namelen);
-	if (status == nfserr_symlink)
-		return nfserr_notdir;
 	if (!status) {
 		fh_unlock(&cstate->current_fh);
 		set_change_info(&remove->rm_cinfo, &cstate->current_fh);
@@ -751,8 +744,6 @@ nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
                   (S_ISDIR(cstate->save_fh.fh_dentry->d_inode->i_mode) &&
                    S_ISDIR(cstate->current_fh.fh_dentry->d_inode->i_mode)))
 		status = nfserr_exist;
-	else if (status == nfserr_symlink)
-		status = nfserr_notdir;
 
 	if (!status) {
 		set_change_info(&rename->rn_sinfo, &cstate->current_fh);
@@ -892,8 +883,6 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	write->wr_bytes_written = cnt;
 
-	if (status == nfserr_symlink)
-		status = nfserr_inval;
 	return status;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3787ec1..aa0a36e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4179,12 +4179,8 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!nfsd4_has_session(cstate) && STALE_CLIENTID(&lockt->lt_clientid))
 		goto out;
 
-	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0))) {
-		dprintk("NFSD: nfsd4_lockt: fh_verify() failed!\n");
-		if (status == nfserr_symlink)
-			status = nfserr_inval;
+	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
 		goto out;
-	}
 
 	inode = cstate->current_fh.fh_dentry->d_inode;
 	locks_init_lock(&file_lock);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 42ef8ff..2834ee2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2766,8 +2766,6 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 			read->rd_offset, resp->rqstp->rq_vec, read->rd_vlen,
 			&maxcount);
 
-	if (nfserr == nfserr_symlink)
-		nfserr = nfserr_inval;
 	if (nfserr)
 		return nfserr;
 	eof = (read->rd_offset + maxcount >=
@@ -2893,8 +2891,6 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	    readdir->common.err == nfserr_toosmall &&
 	    readdir->buffer == page) 
 		nfserr = nfserr_toosmall;
-	if (nfserr == nfserr_symlink)
-		nfserr = nfserr_notdir;
 	if (nfserr)
 		goto err_no_verf;
 

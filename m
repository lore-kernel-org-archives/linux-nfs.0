Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53652 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754268Ab2LGWuh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 17:50:37 -0500
Date: Fri, 7 Dec 2012 17:50:36 -0500
From: "J.Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] - avoid permission checks on EXCLUSIVE_CREATE replay
Message-ID: <20121207225036.GA4078@fieldses.org>
References: <20100422101042.226f71d6@notabene.brown>
 <20100422162533.GH5926@fieldses.org>
 <20100423071631.27ff3a5a@notabene.brown>
 <20100422211801.GF10302@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100422211801.GF10302@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 22, 2010 at 05:18:01PM -0400, J.Bruce Fields wrote:
> On Fri, Apr 23, 2010 at 07:16:31AM +1000, Neil Brown wrote:
> > On Thu, 22 Apr 2010 12:25:33 -0400

Always fun to reply on 2-year-old threads:

> > "J.Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Thu, Apr 22, 2010 at 10:10:42AM +1000, Neil Brown wrote:
> > > > 
> > > > With NFSv4, if we create a file then open it we explicit avoid checking the
> > > > permissions on the file during the open because the fact that we created it
> > > > ensures we should be allow to open it (the create and the open should appear
> > > > to be a single operation).
> > > > 
> > > > However if the reply to an EXCLUSIVE create gets lots and the client resends
> > > > the create, the current code will perform the permission check - because it
> > > > doesn't realise that it did the open already..
> > > > 
> > > > This patch should fix this.
> > > 
> > > Thanks, but: hm, does this leave a loophole for a clever attacker?
> > > They'll still have to get past the initial
> > > 
> > > 	fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE)
> > > 
> > > but that just checks the parent directory; if the existing file is
> > > actually owned by someone else, do we allow an open that we shouldn't?
> > > 
> > > Maybe when "created" is set we should keep the permission check but add
> > > NFSD_ALLOW_OWNER_OVERRIDE?
> > > 
> > 
> > I think that is possibly a good idea.  However......
> > 
> > commit 81ac95c5569d7a60ab5db6c1ccec56c12b3ebcb5
> > Author: J. Bruce Fields <bfields@fieldses.org>
> > Date:   Wed Nov 8 17:44:40 2006 -0800
> > 
> >     [PATCH] nfsd4: fix open-create permissions
> >     
> >     In the case where an open creates the file, we shouldn't be rechecking
> >     permissions to open the file; the open succeeds regardless of what the new
> >     file's mode bits say.
> >     
> >     This patch fixes the problem, but only by introducing yet another parameter
> >     to nfsd_create_v3.  This is ugly.  This will be fixed by later patches.
> >     
> > 
> > I wouldn't want to get in the way of these 'later patches' that might be
> > going to remove the 'created' flag from nfsd_create_v3 :-)
> 
> Har.  I was optimistic.
> 
> That code *is* really hairy.  I'll take another look.

Well, it remains as ugly as ever, but pynfs just reminded me that I'd
forgotten that the original bug still needed fixing!

Version I plan to merge follows.

commit 1895f5075c59f6a7b5e4c3a59ffe108e881f69d4
Author: Neil Brown <neilb@suse.de>
Date:   Fri Dec 7 15:40:55 2012 -0500

    nfsd: avoid permission checks on EXCLUSIVE_CREATE replay
    
    With NFSv4, if we create a file then open it we explicit avoid checking
    the permissions on the file during the open because the fact that we
    created it ensures we should be allow to open it (the create and the
    open should appear to be a single operation).
    
    However if the reply to an EXCLUSIVE create gets lots and the client
    resends the create, the current code will perform the permission check -
    because it doesn't realise that it did the open already..
    
    This patch should fix this.
    
    Note that I haven't actually seen this cause a problem.  I was just
    looking at the code trying to figure out a different EXCLUSIVE open
    related issue, and this looked wrong.
    
    Cc: stable@kernel.org
    Signed-off-by: NeilBrown <neilb@suse.de>
    [bfields: use OWNER_OVERRIDE and update for 4.1]
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 85a6915..beaa99f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -195,6 +195,7 @@ static __be32
 do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
 	struct svc_fh *resfh;
+	int accmode;
 	__be32 status;
 
 	resfh = kmalloc(sizeof(struct svc_fh), GFP_KERNEL);
@@ -254,9 +255,10 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 	/* set reply cache */
 	fh_copy_shallow(&open->op_openowner->oo_owner.so_replay.rp_openfh,
 			&resfh->fh_handle);
-	if (!open->op_created)
-		status = do_open_permission(rqstp, resfh, open,
-					    NFSD_MAY_NOP);
+	accmode = NFSD_MAY_NOP;
+	if (open->op_created)
+		accmode |= NFSD_MAY_OWNER_OVERRIDE;
+	status = do_open_permission(rqstp, resfh, open, accmode);
 	set_change_info(&open->op_cinfo, current_fh);
 	fh_dup2(current_fh, resfh);
 out:
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b584205..0ef9b6b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1471,13 +1471,19 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		case NFS3_CREATE_EXCLUSIVE:
 			if (   dchild->d_inode->i_mtime.tv_sec == v_mtime
 			    && dchild->d_inode->i_atime.tv_sec == v_atime
-			    && dchild->d_inode->i_size  == 0 )
+			    && dchild->d_inode->i_size  == 0 ) {
+				if (created)
+					*created = 1;
 				break;
+			}
 		case NFS4_CREATE_EXCLUSIVE4_1:
 			if (   dchild->d_inode->i_mtime.tv_sec == v_mtime
 			    && dchild->d_inode->i_atime.tv_sec == v_atime
-			    && dchild->d_inode->i_size  == 0 )
+			    && dchild->d_inode->i_size  == 0 ) {
+				if (created)
+					*created = 1;
 				goto set_attr;
+			}
 			 /* fallthru */
 		case NFS3_CREATE_GUARDED:
 			err = nfserr_exist;

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34123 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758050Ab2DIW65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 18:58:57 -0400
Date: Mon, 9 Apr 2012 18:58:53 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Orion Poplawski <orion@cora.nwra.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] open(O_CREAT) returns EEXISTS on symbolic link created
 on another system until stat()ed
Message-ID: <20120409225853.GG10508@fieldses.org>
References: <1333052170.10318.6.camel@lade.trondhjem.org>
 <1333053750.10318.15.camel@lade.trondhjem.org>
 <20120329205035.GB21493@fieldses.org>
 <1333054622.10318.19.camel@lade.trondhjem.org>
 <20120329210838.GC21493@fieldses.org>
 <20120329211713.GD21493@fieldses.org>
 <4F7DC9DC.6090802@cora.nwra.com>
 <20120405165311.GA11707@fieldses.org>
 <4F7DFDD7.30005@cora.nwra.com>
 <20120409223221.GD10508@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120409223221.GD10508@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 09, 2012 at 06:32:21PM -0400, Bruce Fields wrote:
> On Thu, Apr 05, 2012 at 02:17:27PM -0600, Orion Poplawski wrote:
> > On 04/05/2012 10:53 AM, Bruce Fields wrote:
> > >On Thu, Apr 05, 2012 at 10:35:40AM -0600, Orion Poplawski wrote:
> > >>On 03/29/2012 03:17 PM, Dr James Bruce Fields wrote:
> > >>>On Thu, Mar 29, 2012 at 05:08:38PM -0400, Dr James Bruce Fields wrote:
> > >>>>Anyway, something like the following (untested) should change v3 to
> > >>>>return nfs_ok in this case, and v4 to return the same errors it would on
> > >>>>a non-create open.
> > >>>
> > >>>Looking at the history, I think the v3 behavior has been there from the
> > >>>start.  I wonder why we've never gotten a bug report?
> > >>>
> > >>>Looking at wireshark.... I guess the client always does a lookup first,
> > >>>so we never hit this case (unless someone replaces the file by a
> > >>>non-regular-file between a lookup and a create?)
> > >>>
> > >>>--b.
> > >>
> > >>So, is this all set to eventually make it into the mainline kernel?
> > >>Or is there still something I can do to help move it along?
> > >
> > >If you could confirm whether the patch in
> > >
> > >	http://www.spinics.net/lists/linux-nfs/msg28840.html
> > >
> > >fixes your problem, that would help.
> > >
> > >--b.
> > 
> > I applied it to 2.6.32-220.7.1.el6.x86_64 and it appears to have
> > fixed the issue.  Can't be sure yet if it broke anything else
> > though...
> 
> Great, thanks.  I'm applying as follows.

Whoops, forgot to append the patch.--b.

commit 02f661e5012665a3994e454a3f2602843ef65d59
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Apr 9 18:06:49 2012 -0400

    nfsd: don't fail unchecked creates of non-special files
    
    Allow a v3 unchecked open of a non-regular file succeed as if it were a
    lookup; typically a client in such a case will want to fall back on a
    local open, so succeeding and giving it the filehandle is more useful
    than failing with nfserr_exist, which makes it appear that nothing at
    all exists by that name.
    
    Similarly for v4, on an open-create, return the same errors we would on
    an attempt to open a non-regular file, instead of returning
    nfserr_exist.
    
    This fixes a problem found doing a v4 open of a symlink with
    O_RDONLY|O_CREAT, which resulted in the current client returning EEXIST.
    
    Thanks also to Trond for analysis.
    
    Cc: stable@kernel.org
    Reported-by: Orion Poplawski <orion@cora.nwra.com>
    Tested-by: Orion Poplawski <orion@cora.nwra.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2ed14df..8256efd 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -235,17 +235,17 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 		 */
 		if (open->op_createmode == NFS4_CREATE_EXCLUSIVE && status == 0)
 			open->op_bmval[1] = (FATTR4_WORD1_TIME_ACCESS |
-						FATTR4_WORD1_TIME_MODIFY);
+							FATTR4_WORD1_TIME_MODIFY);
 	} else {
 		status = nfsd_lookup(rqstp, current_fh,
 				     open->op_fname.data, open->op_fname.len, resfh);
 		fh_unlock(current_fh);
-		if (status)
-			goto out;
-		status = nfsd_check_obj_isreg(resfh);
 	}
 	if (status)
 		goto out;
+	status = nfsd_check_obj_isreg(resfh);
+	if (status)
+		goto out;
 
 	if (is_create_with_attrs(open) && open->op_acl != NULL)
 		do_set_nfs4_acl(rqstp, resfh, open->op_acl, open->op_bmval);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 296d671..5686661 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1458,7 +1458,7 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		switch (createmode) {
 		case NFS3_CREATE_UNCHECKED:
 			if (! S_ISREG(dchild->d_inode->i_mode))
-				err = nfserr_exist;
+				goto out;
 			else if (truncp) {
 				/* in nfsv4, we need to treat this case a little
 				 * differently.  we don't want to truncate the

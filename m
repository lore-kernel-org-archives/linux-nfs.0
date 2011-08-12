Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752902Ab1HLOch (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Aug 2011 10:32:37 -0400
Date: Fri, 12 Aug 2011 10:32:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Casey Bodley <cbodley@citi.umich.edu>
Cc: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        Malcolm Locke <malc@wholemeal.co.nz>
Subject: Re: Grace period NEVER ends
Message-ID: <20110812143228.GD16960@pad.fieldses.org>
References: <4E44790A.8000106@panasas.com>
 <4E447EEB.501@panasas.com>
 <4E4481F0.2050806@panasas.com>
 <20110812021556.GD9761@pad.fieldses.org>
 <CAMeBU_28VPCtExvU1gr3oTbLLyqp=qFwFjxehoea64Xqi=_ncQ@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMeBU_28VPCtExvU1gr3oTbLLyqp=qFwFjxehoea64Xqi=_ncQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 12, 2011 at 10:08:03AM -0400, Casey Bodley wrote:
> On Thu, Aug 11, 2011 at 10:15 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Thu, Aug 11, 2011 at 06:29:20PM -0700, Boaz Harrosh wrote:
> >> With this patch I'm back to the previous behavior. That is
> >> wait your grace period then continue.
> >
> > Is it true for some reason that the client never sends RECLAIM_COMPLETE?
> 
> I tested this yesterday with the windows client and saw the same
> never-ending grace period on OPEN.  We do send RECLAIM_COMPLETE, and
> it completes successfully.  Other operations like CREATE and REMOVE
> succeed as well.

Argh.  Does this help?

Unfortunately, this doesn't explain Malcolm Locke's problem, as it's 4.1
specific.

--b.

commit d43b4d070a24edcbe5f5e9ffcf7a33bbeccdd47d
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Aug 12 10:27:18 2011 -0400

    nfsd4: fix failure to end nfsd4 grace period
    
    Even if we fail to write a recovery record to stable storage, we should
    still mark the client as having acquired its first state.  Otherwise we
    leave 4.1 clients with indefinite ERR_GRACE returns.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 29d77f6..4c7537d 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -156,10 +156,9 @@ out_put:
 	dput(dentry);
 out_unlock:
 	mutex_unlock(&dir->d_inode->i_mutex);
-	if (status == 0) {
-		clp->cl_firststate = 1;
+	if (status == 0)
 		vfs_fsync(rec_file, 0);
-	}
+	clp->cl_firststate = 1;
 	nfs4_reset_creds(original_cred);
 	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
 	return status;

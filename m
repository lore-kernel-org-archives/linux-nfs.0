From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsd oops 2.6.7-rc1
Date: Sat, 29 May 2004 13:24:29 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <16568.621.199870.484447@cse.unsw.edu.au>
References: <20040529023550.GB2370@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262873AbUE2DYu@vger.kernel.org>
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <wli@holomorphy.com>) (for <akpm@osdl.org>)
	(for <linux-kernel@vger.kernel.org>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Sat, 29 May 2004 13:24:37 +1000
To: William Lee Irwin III <wli@holomorphy.com>, akpm@osdl.org
In-Reply-To: message from William Lee Irwin III on Friday May 28
List-ID: <nfs.lists.sourceforge.net>

On Friday May 28, wli@holomorphy.com wrote:
> While idle, the following oops happened. On virgin 2.6.7-rc1.
> 

Ok, I think I've found it.  There is a missing dget.  See below/.
NeilBrown

=====================================================
Another missing dget

The recentish change to fh_compose not consuming a reference
to the passed dentries missed this needed dget.

Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-05-29 13:21:19.000000000 +1000
+++ ./fs/nfsd/vfs.c	2004-05-29 13:21:36.000000000 +1000
@@ -899,7 +899,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
 			goto out;
 	} else {
 		/* called from nfsd_proc_create */
-		dchild = resfhp->fh_dentry;
+		dchild = dget(resfhp->fh_dentry);
 		if (!fhp->fh_locked) {
 			/* not actually possible */
 			printk(KERN_ERR

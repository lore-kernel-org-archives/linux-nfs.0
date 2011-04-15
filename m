Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49322 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472Ab1DOWgX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Apr 2011 18:36:23 -0400
Date: Fri, 15 Apr 2011 18:36:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Gerhard Heift <ml-nfs-linux-20110412-ef47@gheift.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsdv4 leaks file descriptors
Message-ID: <20110415223621.GB12254@fieldses.org>
References: <20110412140148.GA17242@gheift>
 <20110413211211.GA25189@fieldses.org>
 <20110414054844.GF17242@gheift>
 <20110414191005.GB1721@fieldses.org>
 <20110415132025.GA6126@gheift>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110415132025.GA6126@gheift>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Apr 15, 2011 at 03:20:30PM +0200, Gerhard Heift wrote:
> On Thu, Apr 14, 2011 at 03:10:06PM -0400, J. Bruce Fields wrote:
> > On Thu, Apr 14, 2011 at 07:48:45AM +0200, Gerhard Heift wrote:
> > > On Wed, Apr 13, 2011 at 05:12:11PM -0400, J. Bruce Fields wrote:
> > > > On Tue, Apr 12, 2011 at 04:01:50PM +0200, Gerhard Heift wrote:
> > > > > Hello,
> > > > > 
> > > > > I have a linux kernel (2.6.38.2, armv5tel) running which exports a
> > > > > directory with following options:
> > > > 
> > > > Should be fixed in more recent stable kernel; let me know if not.
> > > 
> > > An even more recent stable than 2.6.38.2? I just compiled 2.6.39-rc3 and
> > > there the leak happens too.
> > 
> > Ugh.  OK, investigating.
> 
> It took me a bit of time, but I located the commit which introduced this
> behavior: acfdf5c383b38f7f4dddae41b97c97f1ae058f49

Doh--probably we just need this (lightly tested).

Thanks for tracking this down.

--b.

commit 21cd8aaf5efb086361cf12f9245c14a3b19fbafd
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Apr 15 18:08:26 2011 -0400

    nfsd4: fix struct file leak on delegation
    
    Introduced by acfdf5c383b38f7f4dddae41b97c97f1ae058f49.
    
    Reported-by: Gerhard Heift <ml-nfs-linux-20110412-ef47@gheift.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index aa309aa..c79a983 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -258,6 +258,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 	if (atomic_dec_and_test(&fp->fi_delegees)) {
 		vfs_setlease(fp->fi_deleg_file, F_UNLCK, &fp->fi_lease);
 		fp->fi_lease = NULL;
+		fput(fp->fi_deleg_file);
 		fp->fi_deleg_file = NULL;
 	}
 }

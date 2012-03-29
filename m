Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35780 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759344Ab2C2N7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Mar 2012 09:59:54 -0400
Date: Thu, 29 Mar 2012 09:59:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, jlayton@redhat.com,
        bfields@redhat.com, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org, linux-next@vger.kernel.org
Subject: Re: linux-next: breakage on undefined reference to
 `nfsd4_cld_block'
Message-ID: <20120329135949.GG16938@fieldses.org>
References: <CAP=VYLr9CL33ZbEVUhVNXsKOCcDWmwmP268jggzWJEBaMa_W0w@mail.gmail.com>
 <20120329142455.dbad3778ced27db683d06a6a@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120329142455.dbad3778ced27db683d06a6a@canb.auug.org.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 29, 2012 at 02:24:55PM +1100, Stephen Rothwell wrote:
> [cc of nfsd tree contact added]

The nfsd tree should have a fix now.  Thanks for the report.--b.

> 
> On Wed, 28 Mar 2012 20:31:36 -0400 Paul Gortmaker <paul.gortmaker@windriver.com> wrote:
> >
> > Hi all,
> > 
> > The linux-next tree got about ten new failures today, spanning all arch.
> > They all shared this in common, it seems.
> > 
> > ERROR: "nfsd4_cld_block" [fs/nfsd/nfsd.ko] undefined!
> > make[2]: *** [__modpost] Error 1
> > 
> > I chose alpha (since it was the 1st I saw alphabetically) and did a bisect,
> > and it came up with the below commit.  I've also included the bisect log.
> > 
> > Can someone please take a look at this?  Too late to fix for the Thursday
> > build, but Friday might be the last for 3.4 content and it would be nice to
> > have all these builds green again in that one.
> > 
> > Thanks,
> > Paul.
> > 
> > --------------
> > commit 813fd320c16691eac508fe350b4ee7362c6c4a56
> > Author: Jeff Layton <jlayton@redhat.com>
> > Date:   Wed Mar 21 09:52:08 2012 -0400
> > 
> >     nfsd: add notifier to handle mount/unmount of rpc_pipefs sb
> > 
> >     In the event that rpc_pipefs isn't mounted when nfsd starts, we
> >     must register a notifier to handle creating the dentry once it
> >     is mounted, and to remove the dentry on unmount.
> > 
> >     Signed-off-by: Jeff Layton <jlayton@redhat.com>
> >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > -------------------
> > 
> > git bisect start
> > # good: [c16fa4f2ad19908a47c63d8fa436a1178438c7e7] Linux 3.3
> > git bisect good c16fa4f2ad19908a47c63d8fa436a1178438c7e7
> > # bad: [7734592ef4a5d14bba15cf2df7fcac8c39d6bdb4] Add linux-next
> > specific files for 20120328
> > git bisect bad 7734592ef4a5d14bba15cf2df7fcac8c39d6bdb4
> > # good: [50953e0640b3473dcb409d5d0d938c2742c93b0d] Merge branch 'poll'
> > into staging/for_v3.4
> > git bisect good 50953e0640b3473dcb409d5d0d938c2742c93b0d
> > # bad: [ecc717668be52fe7b3b29e922b96700067767f05] Merge
> > remote-tracking branch 'l2-mtd/master'
> > git bisect bad ecc717668be52fe7b3b29e922b96700067767f05
> > # good: [d0f6867abfb505b191e31a87dbcdeed65241243a] Merge
> > remote-tracking branch 'arm/for-next'
> > git bisect good d0f6867abfb505b191e31a87dbcdeed65241243a
> > # bad: [2dddaf865e0c13448518abbabd0ad462a7a2d3dd] Merge
> > remote-tracking branch 'kbuild/for-next'
> > git bisect bad 2dddaf865e0c13448518abbabd0ad462a7a2d3dd
> > # bad: [7be8f9ff0749f5d8a0a508b071c206cb68decf04] Merge
> > remote-tracking branch 'nfsd/nfsd-next'
> > git bisect bad 7be8f9ff0749f5d8a0a508b071c206cb68decf04
> > # good: [5537f6f1d690270d388987d543de2cc1e7be40e6] Merge
> > remote-tracking branch 'ceph/master'
> > git bisect good 5537f6f1d690270d388987d543de2cc1e7be40e6
> > # good: [9d547c35799a4ddd235f1565cec2fff6c9263504] vfs: remove unused
> > superblock helpers
> > git bisect good 9d547c35799a4ddd235f1565cec2fff6c9263504
> > # bad: [cc27e0d407021a278d08c1952f5af4ab38c49eda] nfsd: don't allow
> > legacy client tracker init for anything but init_net
> > git bisect bad cc27e0d407021a278d08c1952f5af4ab38c49eda
> > # good: [1255a8f36cb16a02540bdad91c0bc0971b9fb429] nfsd4: don't set
> > cl_firststate on first reclaim in 4.1 case
> > git bisect good 1255a8f36cb16a02540bdad91c0bc0971b9fb429
> > # good: [62b9510cb373d5722fdaba71d961d8f695acfcd5] nfsd: merge cookie
> > collision fixes from ext4 tree
> > git bisect good 62b9510cb373d5722fdaba71d961d8f695acfcd5
> > # good: [2a4317c55438d8589a015d42912454ede12031f0] nfsd: add
> > nfsd4_client_tracking_ops struct and a way to set it
> > git bisect good 2a4317c55438d8589a015d42912454ede12031f0
> > # good: [0ab628d856a63d63b47307b09851d1e955c706ac] nfsd: add a header
> > describing upcall to nfsdcld
> > git bisect good 0ab628d856a63d63b47307b09851d1e955c706ac
> > # bad: [813fd320c16691eac508fe350b4ee7362c6c4a56] nfsd: add notifier
> > to handle mount/unmount of rpc_pipefs sb
> > git bisect bad 813fd320c16691eac508fe350b4ee7362c6c4a56
> > # good: [f3f8014862d813cca81a597c83bd1dbf0fb2b8f6] nfsd: add the
> > infrastructure to handle the cld upcall
> > git bisect good f3f8014862d813cca81a597c83bd1dbf0fb2b8f6
> 
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au



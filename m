Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:57646 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402Ab1EKXHr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2011 19:07:47 -0400
Date: Wed, 11 May 2011 18:07:39 -0500
From: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Peng Huang <shawn.p.huang@gmail.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs: check a crash in nfs_lookup_revalidate
Message-ID: <20110511230739.GB9776@boyd.l.tihix.com>
References: <1305147805-5756-1-git-send-email-shawn.p.huang@gmail.com>
 <1305148125.21868.2.camel@lade.trondhjem.org>
 <20110511221750.GA9776@boyd.l.tihix.com>
 <1305153237.26971.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1305153237.26971.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed May 11, 2011 at 06:33:57PM -0400, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Wed, 2011-05-11 at 17:17 -0500, Tyler Hicks wrote:
> > On Wed May 11, 2011 at 05:08:45PM -0400, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > > On Wed, 2011-05-11 at 17:03 -0400, Peng Huang wrote:
> > > > lookup_one_len() may call nfs_loopup_revalidate() with nd == NULL
> > > > indirectly, that causes the kernel crash.
> > > > 
> > > > RIP: 0010:[<ffffffffa0ba3b41>]  [<ffffffffa0ba3b41>]
> > > > nfs_lookup_revalidate+0x21/0x4a0 [nfs]
> > > > RSP: 0018:ffff88018f00fae8  EFLAGS: 00010286
> > > > 
> > > > Call Trace:
> > > >  [<ffffffff81164a17>] do_revalidate+0x17/0x60
> > > >  [<ffffffff81164e9b>] __lookup_hash+0xcb/0x140
> > > >  [<ffffffff811653c4>] lookup_one_len+0x94/0xe0
> > > >  [<ffffffff81241ef1>] ecryptfs_lookup+0x91/0x1d0
> > > >  [<ffffffff81164d85>] d_alloc_and_lookup+0x45/0x90
> > > >  [<ffffffff8116f7b5>] ? d_lookup+0x35/0x60
> > > >  [<ffffffff811669b2>] do_lookup+0x192/0x2d0
> > > >  [<ffffffff811763be>] ? vfsmount_lock_local_unlock+0x1e/0x30
> > > >  [<ffffffff8126d09c>] ? security_inode_permission+0x1c/0x30
> > > >  [<ffffffff81167d67>] link_path_walk+0x597/0xae0
> > > >  [<ffffffff8117638e>] ? vfsmount_lock_local_lock+0x1e/0x30
> > > >  [<ffffffff81165905>] ? path_init_rcu+0xa5/0x210
> > > >  [<ffffffff8116858b>] do_path_lookup+0x5b/0x140
> > > >  [<ffffffff811692f7>] user_path_at+0x57/0xa0
> > > >  [<ffffffff8159fd08>] ? do_page_fault+0x1e8/0x4e0
> > > >  [<ffffffff8115eb86>] vfs_fstatat+0x46/0x80
> > > >  [<ffffffff8116b990>] ? filldir+0x0/0xe0
> > > >  [<ffffffff8115ec2e>] vfs_lstat+0x1e/0x20
> > > >  [<ffffffff8115ec54>] sys_newlstat+0x24/0x50
> > > >  [<ffffffff8159c995>] ? page_fault+0x25/0x30
> > > >  [<ffffffff8100bfc2>] system_call_fastpath+0x16/0x1b
> > > > 
> > > > Signed-off-by: Peng Huang <shawn.p.huang@gmail.com>
> > > > ---
> > > >  fs/nfs/dir.c |    2 +-
> > > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > > 
> > > > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > > > index 2c3eb33..9452aa5 100644
> > > > --- a/fs/nfs/dir.c
> > > > +++ b/fs/nfs/dir.c
> > > > @@ -1028,7 +1028,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
> > > >  	struct nfs_fattr *fattr = NULL;
> > > >  	int error;
> > > >  
> > > > -	if (nd->flags & LOOKUP_RCU)
> > > > +	if (nd != NULL && nd->flags & LOOKUP_RCU)
> > > >  		return -ECHILD;
> > > >  
> > > >  	parent = dget_parent(dentry);
> > > 
> > > That's exactly what Tyler Hicks proposed last week and which was NACKed.
> > > We simply won't support layered filesystems that don't do intents.
> > 
> > But you _did_ support it up until
> > 34286d66 "fs: rcu-walk aware d_revalidate method"
> > 
> > I see why you wouldn't want NULL nameidata in the NFSv4 specific
> > functions, but don't quite understand the opposition against it in NFSv3
> > (nfs_lookup_revalidate). The one-liner above would allow users to begin
> > using eCryptfs on top of NFSv3 clients immediately, with no side effects
> > to NFS.
> 
> Because even on NFSv3 it breaks exclusive creates.

I somehow missed that bit of code in nfs_lookup(). Thanks for the
pointer.

I'll start getting the eCryptfs lookup code straightened out.

Tyler

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

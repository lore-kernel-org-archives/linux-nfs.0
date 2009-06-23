From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 5/5] NFS: Correct the NFS mount path when following a
 referral
Date: Tue, 23 Jun 2009 17:15:49 -0400
Message-ID: <1245791749.5133.12.camel@heimdal.trondhjem.org>
References: <20090622190913.27923.31665.stgit@heimdal.trondhjem.org>
	 <20090622190914.27923.84173.stgit@heimdal.trondhjem.org>
	 <20090623204202.GA25969@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49586 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757732AbZFWVP6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jun 2009 17:15:58 -0400
In-Reply-To: <20090623204202.GA25969@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-06-23 at 15:42 -0500, Serge E. Hallyn wrote:
> Quoting Trond Myklebust (Trond.Myklebust@netapp.com):
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> > 
> >  fs/nfs/super.c |   24 ++++++++++++++++++++++++
> >  1 files changed, 24 insertions(+), 0 deletions(-)
> > 
> > 
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index 8da7e59..daecbad 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -2548,6 +2548,27 @@ static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
> >  	return root_mnt;
> >  }
> > 
> > +static void nfs_fix_devname(const struct path *path, struct vfsmount *mnt)
> > +{
> > +	char *page = (char *) __get_free_page(GFP_KERNEL);
> > +	char *devname, *tmp;
> > +
> > +	if (page == NULL)
> > +		return;
> > +	devname = nfs_path(path->mnt->mnt_devname,
> > +			path->mnt->mnt_root, path->dentry,
> > +			page, PAGE_SIZE);
> > +	if (devname == NULL)
> > +		goto out_freepage;
> > +	tmp = kstrdup(devname, GFP_KERNEL);
> > +	if (tmp == NULL)
> > +		goto out_freepage;
> > +	kfree(mnt->mnt_devname);
> > +	mnt->mnt_devname = tmp;
> 
> (looking through patch 3 a bit) is this expected to be safe because all
> callers will send in a mnt which was privately mounted as nfs root_mnt through
> vfs_kern_mount?  So that at this point noone else can have a ref to
> mnt?
> 
> If that isn't the intent, then this seems problematic...  (If it is, it
> seems worth commenting both so that every reader doesn't feel compelled
> to verify, and so that no new callers will naively violate that
> expectation)

The call to nfs_fix_devname() is only applied to the 'mnt_target'
vfsmount, which is the one that was passed down directly from
do_kern_mount() to the ->get_sb() method. It is entirely unreferenced by
any other process since we haven't yet called 'do_add_mount()' to
publish it.

Cheers
  Trond

> thanks,
> -serge
> 
> > +out_freepage:
> > +	free_page((unsigned long)page);
> > +}
> > +
> >  static int nfs_follow_remote_path(struct vfsmount *root_mnt,
> >  		const char *export_path, struct vfsmount *mnt_target)
> >  {
> > @@ -2574,6 +2595,9 @@ static int nfs_follow_remote_path(struct vfsmount *root_mnt,
> >  	mnt_target->mnt_sb = s;
> >  	mnt_target->mnt_root = dget(nd.path.dentry);
> > 
> > +	/* Correct the device pathname */
> > +	nfs_fix_devname(&nd.path, mnt_target);
> > +
> >  	path_put(&nd.path);
> >  	down_write(&s->s_umount);
> >  	return 0;
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

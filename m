Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57842 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729188AbeHAW0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Aug 2018 18:26:11 -0400
Date: Wed, 1 Aug 2018 20:38:35 +0000
From: Mark Fasheh <mfasheh@suse.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] locks: map correct ino/dev pairs when exporting to
 userspace
Message-ID: <20180801203835.GE20761@wotan.suse.de>
Reply-To: Mark Fasheh <mfasheh@suse.de>
References: <20180731211045.5671-1-mfasheh@suse.de>
 <20180731211045.5671-5-mfasheh@suse.de>
 <b5b90ff75a222ce3ace37dbd625916ae9aaa9830.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <b5b90ff75a222ce3ace37dbd625916ae9aaa9830.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

On Wed, Aug 01, 2018 at 07:03:54AM -0400, Jeff Layton wrote:
> On Tue, 2018-07-31 at 14:10 -0700, Mark Fasheh wrote:
> > /proc/locks does not always print the correct inode number/device pair.
> > Update lock_get_status() to use vfs_map_unique_ino_dev() to get the real,
> > unique values for userspace.
> > 
> > Signed-off-by: Mark Fasheh <mfasheh@suse.de>
> > ---
> >  fs/locks.c | 12 +++++++++---
> >  1 file changed, 9 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/locks.c b/fs/locks.c
> > index db7b6917d9c5..3a012df87fd8 100644
> > --- a/fs/locks.c
> > +++ b/fs/locks.c
> > @@ -2621,6 +2621,7 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
> >  			    loff_t id, char *pfx)
> >  {
> >  	struct inode *inode = NULL;
> > +	struct dentry *dentry;
> >  	unsigned int fl_pid;
> >  	struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
> >  
> > @@ -2633,8 +2634,10 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
> >  	if (fl_pid == 0)
> >  		return;
> >  
> > -	if (fl->fl_file != NULL)
> > +	if (fl->fl_file != NULL) {
> >  		inode = locks_inode(fl->fl_file);
> > +		dentry = file_dentry(fl->fl_file);
> > +	}
> >  
> >  	seq_printf(f, "%lld:%s ", id, pfx);
> >  	if (IS_POSIX(fl)) {
> > @@ -2681,10 +2684,13 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
> >  			       : (fl->fl_type == F_WRLCK) ? "WRITE" : "READ ");
> >  	}
> >  	if (inode) {
> > +		__u64 ino;
> > +		dev_t dev;
> > +
> > +		vfs_map_unique_ino_dev(dentry, &ino, &dev);
> 
> This code is under a spinlock (blocked_locks_lock or ctx->flc_lock). I
> don't think it'll be ok to call ->getattr while holding a spinlock.

Hmm, indeed it does call under spinlock. I'll hve to rethink how to approach
this in fs/locks.c

Thanks,
	--Mark

From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [PATCH 1/10] lockd: add new export operation for nfsv4/lockd locking
Date: Thu, 14 Dec 2006 21:52:47 -0800
Message-ID: <OF4F7B249B.97254BD9-ON88257245.001ECB2E-88257245.00201311@us.ibm.com>
References: <20061214230442.GB5147@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20061214230442.GB5147@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Lets see if we use export operations or vfs calls. If we do exports we can 
even add another call just for cancel or maybe we can add a new vfs call.
Marc. 

"J. Bruce Fields" <bfields@fieldses.org> wrote on 12/14/2006 03:04:42 PM:

> By the way, one other issue I think we'll need to resolve:
> 
> On Wed, Dec 06, 2006 at 12:34:11AM -0500, J. Bruce Fields wrote:
> > +/**
> > + * vfs_cancel_lock - file byte range unblock lock
> > + * @filp: The file to apply the unblock to
> > + * @fl: The lock to be unblocked
> > + *
> > + * FL_CANCELED is used to cancel blocked requests
> > + */
> > +int vfs_cancel_lock(struct file *filp, struct file_lock *fl)
> > +{
> > +   int status;
> > +   struct super_block *sb;
> > +
> > +   fl->fl_flags |= FL_CANCEL;
> > +   sb = filp->f_dentry->d_inode->i_sb;
> > +   if (sb->s_export_op && sb->s_export_op->lock)
> > +      status = sb->s_export_op->lock(filp, F_SETLK, fl);
> > +   else
> > +      status = posix_unblock_lock(filp, fl);
> > +   fl->fl_flags &= ~FL_CANCEL;
> > +   return status;
> > +}
> 
> So we're passing cancel requests to the filesystem by setting an
> FL_CANCEL flag in fl_flags and then calling the lock operation.  I think
> Trond has said he'd rather keep fl_flags for permanent characteristics
> of the lock in question, rather than as a channel for passing arguments
> to lock operations.  Also, the GFS patch isn't checking FL_CANCEL, so
> that's a bug.
> 
> --b.


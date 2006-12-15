From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/10] lockd: add new export operation for
	nfsv4/lockd locking
Date: Fri, 15 Dec 2006 07:40:32 +0000
Message-ID: <20061215074032.GB31821@infradead.org>
References: <11653832602203-git-send-email-bfields@fieldses.org>
	<8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
	<20061214230442.GB5147@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gv7gR-0007Qu-Do
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 23:40:43 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gv7gR-0007Pk-M0
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 23:40:45 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061214230442.GB5147@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Dec 14, 2006 at 06:04:42PM -0500, J. Bruce Fields wrote:
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
> > +	int status;
> > +	struct super_block *sb;
> > +
> > +	fl->fl_flags |= FL_CANCEL;
> > +	sb = filp->f_dentry->d_inode->i_sb;
> > +	if (sb->s_export_op && sb->s_export_op->lock)
> > +		status = sb->s_export_op->lock(filp, F_SETLK, fl);
> > +	else
> > +		status = posix_unblock_lock(filp, fl);
> > +	fl->fl_flags &= ~FL_CANCEL;
> > +	return status;
> > +}
> 
> So we're passing cancel requests to the filesystem by setting an
> FL_CANCEL flag in fl_flags and then calling the lock operation.  I think
> Trond has said he'd rather keep fl_flags for permanent characteristics
> of the lock in question, rather than as a channel for passing arguments
> to lock operations.  Also, the GFS patch isn't checking FL_CANCEL, so
> that's a bug.

This should be a separate operation.  Either a new command for
->lock or a completely new operation.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

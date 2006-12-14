From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/10] lockd: add new export operation for
	nfsv4/lockd locking
Date: Thu, 14 Dec 2006 18:04:42 -0500
Message-ID: <20061214230442.GB5147@fieldses.org>
References: <11653832602203-git-send-email-bfields@fieldses.org>
	<8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Guzd8-00017v-AU
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 15:04:46 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Guzd9-0003V0-HR
	for nfs@lists.sourceforge.net; Thu, 14 Dec 2006 15:04:47 -0800
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
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

By the way, one other issue I think we'll need to resolve:

On Wed, Dec 06, 2006 at 12:34:11AM -0500, J. Bruce Fields wrote:
> +/**
> + * vfs_cancel_lock - file byte range unblock lock
> + * @filp: The file to apply the unblock to
> + * @fl: The lock to be unblocked
> + *
> + * FL_CANCELED is used to cancel blocked requests
> + */
> +int vfs_cancel_lock(struct file *filp, struct file_lock *fl)
> +{
> +	int status;
> +	struct super_block *sb;
> +
> +	fl->fl_flags |= FL_CANCEL;
> +	sb = filp->f_dentry->d_inode->i_sb;
> +	if (sb->s_export_op && sb->s_export_op->lock)
> +		status = sb->s_export_op->lock(filp, F_SETLK, fl);
> +	else
> +		status = posix_unblock_lock(filp, fl);
> +	fl->fl_flags &= ~FL_CANCEL;
> +	return status;
> +}

So we're passing cancel requests to the filesystem by setting an
FL_CANCEL flag in fl_flags and then calling the lock operation.  I think
Trond has said he'd rather keep fl_flags for permanent characteristics
of the lock in question, rather than as a channel for passing arguments
to lock operations.  Also, the GFS patch isn't checking FL_CANCEL, so
that's a bug.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] mmap corruption
Date: Sun, 6 Apr 2003 14:30:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16016.7633.982870.860147@charged.uio.no>
References: <3E8DDB13.9020009@RedHat.com>
	<shsistt7wip.fsf@charged.uio.no>
	<20030405164741.GA6450@RedHat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1929Hr-0006TF-00
	for <nfs@lists.sourceforge.net>; Sun, 06 Apr 2003 05:30:15 -0700
To: SteveD@RedHat.com
In-Reply-To: <20030405164741.GA6450@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Steve Dickson <SteveD@RedHat.com> writes:

     > 	filemap_fdatasync(inode->i_mapping);
     > 	error = nfs_wb_all(inode);
     > 	filemap_fdatawait(inode->i_mapping);
     > 	if (error)
     > 		goto out;

     > 	/*
     > * Every time either npages or ncommit had a value and the file
     > 	   size is
     > * immediately changed (with in a microsecond or two) by another
     > * truncation, followed by a mmap read, the file would be
     > 	   corrupted.
     > 	 */
     > 	if (NFS_I(inode)->npages || NFS_I(inode)->ncommit ||
     > 	NFS_I(inode)->ndirty) {
     > 		printk("nfs_notify_change: fid %Ld npages %d ncommit
     > 		%d ndirty %d\n", NFS_FILEID(inode),
     > 		NFS_I(inode)->npages, ncommit, NFS_I(inode)->ndirty);
     > 	}
     > }

My point is that nfs_wb_all() is supposed to ensure that
NFS_I(inode)->ncommit, and/or NFS_I(inode)->ndirty are both
zero. i.e. you can have pending reads (in which case
NFS_I(inode)->npages != 0), but *no* pending writes.

Was this the case?

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

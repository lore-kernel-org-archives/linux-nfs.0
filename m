From: Matthias Andree <ma@dt.e-technik.uni-dortmund.de>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine
 for directories on NFS mounts
Date: Thu, 11 Jul 2002 12:52:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <m3lm8ibkp6.fsf@merlin.emma.line.org>
References: <200207091549.15913.trond.myklebust@fys.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from krusty.dt.e-technik.uni-dortmund.de ([129.217.163.1] helo=mail.dt.e-technik.uni-dortmund.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SbYx-0001Bi-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 03:52:44 -0700
Received: from m2a2.myip.org (localhost [127.0.0.1])
	by mail.dt.e-technik.uni-dortmund.de (Postfix) with ESMTP id E1226A3831
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 12:52:39 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <200207091549.15913.trond.myklebust@fys.uio.no> (Trond
 Myklebust's message of "Tue, 9 Jul 2002 15:49:15 +0200")
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> Hi,
>
>    There was a bug reported on the 'exim' user list a couple of months ago: 
> the Linux NFS client reports -EINVAL if you try to fsync() a directory.
>
>    The correct response would be to return a dummy '0' for success, since all 
> NFS operations that change the directory are supposed to be performed 
> synchronously on the server anyway...
> +/*
> + * All directory operations under NFS are synchronous, so fsync()
> + * is a dummy operation.
> + */
> +int nfs_fsync_dir(struct file *filp, struct dentry *dentry, int datasync)
> +{
> +	return 0;
> +}
> +

What if the NFS stuff is not mounted with sync or explicitly mounted
async? Will an nfsd still do synchronous writes to directories?

-- 
Matthias Andree


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
PC Mods, Computing goodies, cases & more
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

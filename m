From: raven@themaw.net
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Wed, 4 Feb 2004 22:24:14 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0402042209030.26014@raven.themaw.net>
References: <40209B6D.56ED461E@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
   Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoNwj-0008LN-Bd
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 06:24:05 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AoNwi-0005lr-MR
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 06:24:04 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <40209B6D.56ED461E@melbourne.sgi.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Excelent work Greg.

On Wed, 4 Feb 2004, Greg Banks wrote:

> G'day,
> 
> This patch fixes a bug where the forced killing of pending asynchronous
> unlink rpc_tasks during unmount leaks inode reference counts for the
> parent of the silly-renamed file and all its ancestor directories,
> resulting in the message 
> 
> VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...
> 
> and a few seconds later an oops with a stack trace ending in
> prune_dcache -> nfs_dentry_iput -> iput.
> 
> This is probably also the bug discussed last September on the autofs
> mailing list.  The patch posted by Olaf Hering then has no effect
> at all, but it did put me on the right track (thanks Olaf).

This message has occasionally been seen for a very log time when using 
autofs but I've never seen an oops follow it???

Until now I have assumed that it is a bug in the daemon code caused by not 
removing a directory(s) before the umount. I've caught several bugs in 
the cleanup code but can't seem to find what else might causing it.

About the only thing that I'm sure of is that this happens at umount time 
in autofs, and with my latest code, only when there is a accompanying 
directory removal.

Do you guys think this might really be the same problem?

This is very hard to trigger so testing is difficult.
 
Ian



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

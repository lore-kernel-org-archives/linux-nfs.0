From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Wed, 4 Feb 2004 11:42:25 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040204104225.GI20323@suse.de>
References: <40209B6D.56ED461E@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoKZ1-0001B5-LF
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 02:47:23 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AoKZ1-0004PA-99
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 02:47:23 -0800
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

Hi Greg,

On Wed, Feb 04, 2004 at 06:12:45PM +1100, Greg Banks wrote:
> This patch fixes a bug where the forced killing of pending asynchronous
> unlink rpc_tasks during unmount leaks inode reference counts for the
> parent of the silly-renamed file and all its ancestor directories,
> resulting in the message 
> 
> VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...

Finally! This bug was driving me nuts. I wasn't even able to reproduce
this under lab conditions :-/

> The first part makes sure that dput() will unhash and kill dentries
> and their parents if called while the unmount is underway.
> 
> The second part moves the dput() call from the tk_exit callback of
> the async unlink rpc_task to the tk_release callback so that it
> will be called if the rpc_task is killed by rpc_killall_tasks()
> instead of completing normally.

Yes, that looks as if this could fix the problem.

Thanks again,
Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

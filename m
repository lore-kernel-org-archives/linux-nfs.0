From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Wed, 4 Feb 2004 13:09:52 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040204120952.GA1980@suse.de>
References: <40209B6D.56ED461E@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoLt2-0002D7-Cl
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 04:12:08 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AoLt1-00035x-0T
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 04:12:07 -0800
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

I've been looking at your analysis a little closer, and am
trying to understand how the bug was triggered. Here's what
I think happened:

 -	the unlink code keeps a reference to the dentry of
 	the parent directory, but not to the vfsmount
 -	this allows the umount to proceed, because there
 	don't seem to be any more references to the mount
 -	rpc_shutdown_client calls rpc_killall_tasks, which
 	terminates the async unlink task.
 -	rpciod is woken up and schedules the async task,
 	calling __rpc_execute
 -	__rpc_execute notices the task is dead (no tk_action),
 	leaves the loop and invokes task->tk_exit == nfs_async_unlink_done
 -	nfs_async_unlink_done calls dput() on the parent dentry,
 	but the dentry is not unhashed.

Now looking at kill_super(), the sequence of calls there looks
like this:

	shrink_dcache_parent(root);
	...
	sop->put_super(sb);
	...
	if (invalidate_inodes(sb)) {
		printk(KERN_ERR "VFS: Busy inodes after unmount. "
			"Self-destruct in 5 seconds.  Have a nice day...\n");
	}

So the real problem is that the dentry isn't unhashed. The other
part of the patch isn't required because the tk_exit() function
is called always, even when rpc_killall_tasks triggers the demise
of an async task.

Do you agree with this analysis?

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

From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Thu, 05 Feb 2004 09:41:32 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4021751C.B888A15C@melbourne.sgi.com>
References: <40209B6D.56ED461E@melbourne.sgi.com> <20040204120952.GA1980@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
   Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoViX-0004ne-MO
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 14:41:57 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoViX-0005u5-Ee
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 14:41:57 -0800
To: Olaf Kirch <okir@suse.de>
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

Olaf Kirch wrote:
> 
> Hi Greg,
> 
> I've been looking at your analysis a little closer, and am
> trying to understand how the bug was triggered. Here's what
> I think happened:
> 
>  -      the unlink code keeps a reference to the dentry of
>         the parent directory, but not to the vfsmount

Yes.

>  -      this allows the umount to proceed, because there
>         don't seem to be any more references to the mount

Yes.

BTW (not directly related to this bug) I found by experiment that I
could umount an NFS mount when there were open file descriptors for
unlinked files in the mount, and even keep writing.  All the NFS
and RPC structures stay alive until the last file descriptor closes,
thanks to the magic of refcounts.  All this despite the vfsmount
reference taken in struct file, which I thought was supposed to
prevent umount.

>  -      rpc_shutdown_client calls rpc_killall_tasks, which
>         terminates the async unlink task.

Yes.

>  -      rpciod is woken up and schedules the async task,
>         calling __rpc_execute

Yes.

>  -      __rpc_execute notices the task is dead (no tk_action),
>         leaves the loop and invokes task->tk_exit == nfs_async_unlink_done

No.  In a crash dump taken after the umount has completed, the dir dentry has
1 leaked d_count for every async unlink present at umount, even though the
async unlink tasks have been cleaned up.  This indicates that task->tk_exit
is not being called but task->tk_release is, so the dput is not happening.

The change in unlink.c moves the dput so that it happens in task->tk_release.
After the change, the dir dentry d_count is decremented to zero reliably
(I walked data structures before during and after umount in the debugger).

It's not entirely clear to me how __rpc_execute can do that, but the evidence
is that it does so.

>  -      nfs_async_unlink_done calls dput() on the parent dentry,
>         but the dentry is not unhashed.




> 
> Now looking at kill_super(), the sequence of calls there looks
> like this:
> 
>         shrink_dcache_parent(root);
>         ...
>         sop->put_super(sb);
>         ...
>         if (invalidate_inodes(sb)) {
>                 printk(KERN_ERR "VFS: Busy inodes after unmount. "
>                         "Self-destruct in 5 seconds.  Have a nice day...\n");
>         }
> 
> So the real problem is that the dentry isn't unhashed.

Yes, this was precisely the problem I encountered when I had the unlink.c
change but not the dir.c change.

> The other
> part of the patch isn't required because the tk_exit() function
> is called always, even when rpc_killall_tasks triggers the demise
> of an async task.

Surprisingly, it isn't.

> Do you agree with this analysis?

Almost.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

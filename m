From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Fri, 06 Feb 2004 16:50:44 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40232B34.2AB2307A@melbourne.sgi.com>
References: <40209B6D.56ED461E@melbourne.sgi.com> <20040204120952.GA1980@suse.de> <4021751C.B888A15C@melbourne.sgi.com> <20040205161515.GA21344@suse.de> <4022C248.D4FF17CD@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoytI-0005wv-1S
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:51:00 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AoytH-0008BQ-6j
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:50:59 -0800
To: Olaf Kirch <okir@suse.de>, Trond Myklebust <trond.myklebust@fys.uio.no>,
   Linux NFS Mailing List <nfs@lists.sourceforge.net>
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

Greg Banks wrote:
> 
> Olaf Kirch wrote:
> >
> > > >  -      __rpc_execute notices the task is dead (no tk_action),
> > > >         leaves the loop and invokes task->tk_exit == nfs_async_unlink_done
> > >
> > > No.  In a crash dump taken after the umount has completed, the dir dentry has
> > > 1 leaked d_count for every async unlink present at umount, even though the
> > > async unlink tasks have been cleaned up.  This indicates that task->tk_exit
> > > is not being called but task->tk_release is, so the dput is not happening.
> >
> > But then prune_dcache shouldn't touch these dentries at all, because their
> > refcount is still 1. They would be leaked, but there would be no crash.
> 
> That makes sense.  I'll go back and recheck my forensics.

I've checked the crash dumps again, and they don't actually have any evidence
either way.  So I ran an experiment.

Feb  6 16:15:37 3X:budgie root: fmeh.sh: /tmp/fmeh-mounts/00007.d UDELAY=500
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_done
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_release
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_done
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_release
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_done
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_release
Feb  6 16:15:38 3X:budgie root: fmeh.sh: /tmp/fmeh-mounts/00008.d UDELAY=500
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_done
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_release
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_done
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_release
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_done
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_release
Feb  6 16:15:38 3X:budgie root: fmeh.sh: /tmp/fmeh-mounts/00009.d UDELAY=500
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_done
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_release
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_done
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_release
Feb  6 16:15:38 4A:budgie kernel: nfs_async_unlink_done

There's some more matched done/release pairs which didn't make it
to syslog by the time the kernel hit my BUG() in invalidate_list.

So I was wrong, and the unlink.c part of the patch is worthless.
Well caught, Olaf.

Here's the latest version of the proposed patch.





This patch fixes a bug where the forced killing of pending asynchronous
unlink rpc_tasks during unmount leaks inode reference counts for the
parent of the silly-renamed file and all its ancestor directories,
resulting in the message 

VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...

and a few seconds later an oops with a stack trace ending in
prune_dcache -> nfs_dentry_iput -> iput.

Patch against 2.4.25-rc1, also applies to 2.6.2-rc2 (with an offset).

===========================================================================
linux/linux/fs/nfs/dir.c
===========================================================================

--- /usr/tmp/TmpDir.27555-0/linux/linux/fs/nfs/dir.c_1.32	Wed Feb  4 17:57:23 2004
+++ linux/linux/fs/nfs/dir.c	Wed Feb  4 17:52:20 2004
@@ -551,6 +551,11 @@ static int nfs_dentry_delete(struct dent
 		/* Unhash it, so that ->d_iput() would be called */
 		return 1;
 	}
+	if (!(dentry->d_sb->s_flags & MS_ACTIVE)) {
+		/* Unhash it, so that ancestors of killed async unlink
+		 * files will be cleaned up during umount */
+		return 1;
+	}
 	return 0;
 
 }




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

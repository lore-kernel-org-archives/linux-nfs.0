From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Thu, 5 Feb 2004 17:15:15 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040205161515.GA21344@suse.de>
References: <40209B6D.56ED461E@melbourne.sgi.com> <20040204120952.GA1980@suse.de> <4021751C.B888A15C@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aom9y-0004Ci-PM
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 08:15:22 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Aom9y-0004oj-Bi
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 08:15:22 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <4021751C.B888A15C@melbourne.sgi.com>
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

On Thu, Feb 05, 2004 at 09:41:32AM +1100, Greg Banks wrote:
> BTW (not directly related to this bug) I found by experiment that I
> could umount an NFS mount when there were open file descriptors for
> unlinked files in the mount, and even keep writing.  All the NFS
> and RPC structures stay alive until the last file descriptor closes,
> thanks to the magic of refcounts.  All this despite the vfsmount
> reference taken in struct file, which I thought was supposed to
> prevent umount.

Then something else must be wrong big time.

> >  -      __rpc_execute notices the task is dead (no tk_action),
> >         leaves the loop and invokes task->tk_exit == nfs_async_unlink_done
> 
> No.  In a crash dump taken after the umount has completed, the dir dentry has
> 1 leaked d_count for every async unlink present at umount, even though the
> async unlink tasks have been cleaned up.  This indicates that task->tk_exit
> is not being called but task->tk_release is, so the dput is not happening.

But then prune_dcache shouldn't touch these dentries at all, because their
refcount is still 1. They would be leaked, but there would be no crash.

> It's not entirely clear to me how __rpc_execute can do that, but the evidence
> is that it does so.

Very strange... maybe we have a refcounting problem elsewhere, and the
refcount was 2 before calling tk_exit? But somehow I doubt this... I
think we'd see far more massive problems in this case.

Would you share your test case?

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

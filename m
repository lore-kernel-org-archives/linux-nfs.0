From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: posix record locking?
Date: 25 Nov 2003 19:50:23 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsoev0uf5c.fsf@charged.uio.no>
References: <3FC2781E.4010107@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AOnt3-0004vm-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Nov 2003 16:50:33 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AOnt3-0002CO-53
	for nfs@lists.sourceforge.net; Tue, 25 Nov 2003 16:50:33 -0800
To: moiz_kohari@yahoo.com
In-Reply-To: <3FC2781E.4010107@yahoo.com>
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

>>>>> " " == moiz kohari <moiz_kohari@yahoo.com> writes:

     > Hi, I am looking at posix record locking with nfs and I have a
     > couple of questions:


     > 1. The fcntl_setlk() calls nfs_lock() (towards the end of fcntl_setlk
     >    by calling filp->f_op->lock), fcntl_setlk() then calls
     >    posix_lock_file() (where all the vfs magic happens for file
     >    locks).  If nfs_lock() returns successful (server has
     >    granted the lock) but the subsequent posix_lock_file() fails
     >    (due to deadlock, conflict or low memory), we never go back
     >    to the server to clean up this lock.  Is this a problem or
     >    am I missing something?


Low memory is a problem, but how are you going to solve that (RPC
calls require memory too)?

As for the rest: why would the VFS tell us we're
deadlocked/conflicting if the server says we aren't? That would
clearly be a bug.

     > 2. nfs_lock() calls nlmclnt_proc() after we pick up the kernel lock
     >    (lock_kernel()).  The nlmclnt_proc() goes on to call:

     >     nlmclnt_lock() nlmclnt_call() rpc...

     > Is this OK?  Are we going over the wire while holding the
     > kernel lock?

Yes. The BKL is unique as far as spinlocks go in that it allows this
sort of thing.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

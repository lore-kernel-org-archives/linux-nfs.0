From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [patch] flock/fcntl bug
Date: Thu, 16 Dec 2004 10:52:53 -0800
Message-ID: <OFECF97ADD.AD77F838-ON88256F6C.0062E165-88256F6C.0067B807@us.ibm.com>
References: <1103168644.11148.48.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cf0n8-0001iP-Px
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 10:55:58 -0800
Received: from e4.ny.us.ibm.com ([32.97.182.144])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cf0n6-00032p-68
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 10:55:57 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBGItk50008336
	for <nfs@lists.sourceforge.net>; Thu, 16 Dec 2004 13:55:46 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBGItkXa270766
	for <nfs@lists.sourceforge.net>; Thu, 16 Dec 2004 13:55:46 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBGItkHL026387
	for <nfs@lists.sourceforge.net>; Thu, 16 Dec 2004 13:55:46 -0500
In-Reply-To: <1103168644.11148.48.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
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

Trond Myklebust wrote on 12/15/2004 07:44:04 PM:

> on den 15.12.2004 Klokka 18:16 (-0800) skreiv Marc Eshel:

> > I will be glad to. Please add my patch 'locking for cluster filesystem'
so
> > other users can experiment with their favorite file system and give
some
> > feed back. My patch is getting too big and it is a pain to retrofit it
to
> > constantly changing code. It will than be easier to build small patches
for
> > the specific problem that will arise.

> I still have issues with it.

> - You cannot mix NLM errors and VFS errors in the same variable. They
> belong to completely different types.
>
I added a new NLM error nlm_lck_deferred that will never go back to the
client, but just tell the svc dispatcher to defer the request. If this is
also not appropriate then please give me a specific alternative.

> - Why is vfs_test_and_lock_file() calling vfs_test_lock()? Why can't
> vfs_lock_file() just return the conflicting file for you? Means you
> do everything in one atomic call down to the filesystem instead of
> (at least) two calls and possibly more...
>
I can change vfs_lock_file to return the conflicting lock but it will still
require two calls to the filesystem. Are you suggesting to change the VFS
lock interface down to the filesystem to combine F_SETLK and F_GETLK ?

> - Why is posix_unblock_lock() suddenly calling filesystem routines via
> vfs_lock_file()?
>
This call might not be necessary, I will remove it and do some more
testing.

> - Why is posix_block_lock() suddenly doing deadlock checking etc
> without any of the callers actually looking at the return value?
>
This was part of an older patch not related so I will remove the call.

> - vfs_test_and_lock_file() appears to return EAGAIN if the user already
> holds the lock (posix_locks_same() is true). Isn't that a bug?
>
If posix_locks_same() is true than vfs_test_lock will return 0 which will
be the return code from vfs_test_and_lock_file(). So no, I don't see a bug.

> - You cannot use memcpy() in order to copy locks.
I will change it to locks_copy_lock() if still required after the change
below.

> - Why is "conflock" being allocated by kmalloc() inside
> vfs_test_lock() instead of by the caller? You could avoid the whole
> ugly FL_FREE hack. The way it all ends up getting called in
> nlmsvc_delete_block() looks very suspicious: it looks to me as if
> posix_unblock_lock() is freeing your lock before you've even started.
>
I was trying to save the allocation call when it is not required, but will
change it to do the allocation by the caller.

Marc.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

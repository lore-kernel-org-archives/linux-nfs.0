From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch] flock/fcntl bug
Date: Wed, 15 Dec 2004 22:44:04 -0500
Message-ID: <1103168644.11148.48.camel@lade.trondhjem.org>
References: <OFDB90A431.EDCAD4C3-ON88256F6C.000B5989-88256F6C.000C8438@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CemZM-0006Jd-8G
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 19:44:48 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CemZL-0003ms-Bu
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 19:44:48 -0800
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OFDB90A431.EDCAD4C3-ON88256F6C.000B5989-88256F6C.000C8438@us.ibm.com>
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

on den 15.12.2004 Klokka 18:16 (-0800) skreiv Marc Eshel:

> I will be glad to. Please add my patch 'locking for cluster filesystem' so
> other users can experiment with their favorite file system and give some
> feed back. My patch is getting too big and it is a pain to retrofit it to
> constantly changing code. It will than be easier to build small patches for
> the specific problem that will arise.

I still have issues with it.

 - You cannot mix NLM errors and VFS errors in the same variable. They
   belong to completely different types.

 - Why is vfs_test_and_lock_file() calling vfs_test_lock()? Why can't
   vfs_lock_file() just return the conflicting file for you? Means you
   do everything in one atomic call down to the filesystem instead of
   (at least) two calls and possibly more...

 - Why is posix_unblock_lock() suddenly calling filesystem routines via
   vfs_lock_file()?

 - Why is posix_block_lock() suddenly doing deadlock checking etc
   without any of the callers actually looking at the return value?

 - vfs_test_and_lock_file() appears to return EAGAIN if the user already
   holds the lock (posix_locks_same() is true). Isn't that a bug?

 - You cannot use memcpy() in order to copy locks.

 - Why is "conflock" being allocated by kmalloc() inside
   vfs_test_lock() instead of by the caller? You could avoid the whole
   ugly FL_FREE hack. The way it all ends up getting called in
   nlmsvc_delete_block() looks very suspicious: it looks to me as if
   posix_unblock_lock() is freeing your lock before you've even started.

Cheers,
  Trond

 - 
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC/PATCH - RESEND] NFS file locking for clustered file systems
Date: Wed, 22 Sep 2004 20:23:14 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0409212112240.20518@localhost.localdomain>
References: <20040921161443.C7F521BB8C@citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no, okir@suse.de, nfs@lists.sourceforge.net,
        nfsv4@linux-nfs.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAKDU-0002tO-PD
	for nfs@lists.sourceforge.net; Wed, 22 Sep 2004 20:24:20 -0700
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CAKDU-0004mr-9B
	for nfs@lists.sourceforge.net; Wed, 22 Sep 2004 20:24:20 -0700
To: "William A.(Andy) Adamson" <andros@citi.umich.edu>
In-Reply-To: <20040921161443.C7F521BB8C@citi.umich.edu>
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

On Tue, 21 Sep 2004, William A.(Andy) Adamson wrote:

> hello sridhar
>
> trond and i were discussing these proposed changes - version 4 nfsd needs a
> way to communicate with the underlying clustered/parallel file system for
> share/deny access, byte-range locking, and delegations, and file handle
> construction.

Great. It is good news that you have started discussing on a much broader
set of nfsv4 requirements for clustered filesystems.

>
> trond suggested (trond, speak up if i misunderstood you!) that since only the
> server lockd, and nfsd need these operations, extending the struct
> export_operations might be a better place to put this new functionality
> instead of changing the existing f_op->lock behaviour.

Actually we are only adding an optional behaviour that can return a new
return value -EINPROGRESS. But if you think that it is much cleaner to add
a new operation to export_operations that is also fine.

>
> it would be great if vfs_lock_file(), and therefore __posix_lock_file() had a
> conflicting lock parameter set only upon discovery of a conflicting lock in
> order to get rid of a race in lockd and nfsd.
>
> svclock.c: nlmsvc_lock()
>
>         if (!(conflock = posix_test_lock(file->f_file, &lock->fl))) {
>                 error = posix_lock_file(file->f_file, &lock->fl);
>
> in the above code, a conflicting lock could be inserted in between the calls
> to posix_test_lock and posix_lock_file. v4 nfsd has similar code. adding the
> conflicting lock parameter to vfs/posix_lock_file means the call to
> posix_test_lock could be removed.

I guess you are referring to the race resulting in lockd() being blocked in
the call to posix_lock_file() if someone else takes the lock between
posix_test_lock() and posix_lock_file().

In our patch the above segment becomes
         if (!(conflock = posix_test_lock(file->f_file, &lock->fl))) {
                 error = vfs_lock_file(file->f_file, &lock->fl, wait);

Here vfs_lock_file() will return immediately with EINPROGRESS if the
underlying filesystem supports asynchronous locking mechanism avoiding the
blocking of lockd. But i agree that lockd can block in this situation when
f_op->lock is NULL.

The advantage of having the 2 calls is that if the lock is held locally,
posix_test_lock() which is much cheaper returns a conflock and we can
avoid the call to the filesystem.

>
> i'm a bit confused about the use of posix_locks_same. vfs_test_lock() will
> return -ENOLCK with no conf lock set when posix_locks_same() returns 1. yet in
> nlmsvc_testlock() which calls vfs_test_lock, this error is not propagated -
> nlm_granted is returned.

This is the case where the lock requester is already holding the lock and
posix_locks_same() is used to avoid a call to the filesystem.
It is little confusing that we are returning -ENOLCK. I think we can get rid of
the if condition and simply return 0.

>
> i do like the direction of these patches, i'll spend some more time looking at
> them from the v4 nfsd byte-range locking perspective...

Thanks for the review and i look forward to your further comments on how we
should proceed further.

-Sridhar


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC/PATCH - RESEND] NFS file locking for clustered file systems
Date: Mon, 27 Sep 2004 11:45:42 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0409271110560.21478@localhost.localdomain>
References: <20040924133737.134D51BB06@citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no, okir@suse.de, nfs@lists.sourceforge.net,
        nfsv4@linux-nfs.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CC0WH-0004Yy-J7
	for nfs@lists.sourceforge.net; Mon, 27 Sep 2004 11:46:41 -0700
Received: from e3.ny.us.ibm.com ([32.97.182.103])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CC0WG-00087b-SP
	for nfs@lists.sourceforge.net; Mon, 27 Sep 2004 11:46:41 -0700
To: "William A.(Andy) Adamson" <andros@citi.umich.edu>
In-Reply-To: <20040924133737.134D51BB06@citi.umich.edu>
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

Andy,

Please see my comments inline.

Thanks
Sridhar

On Fri, 24 Sep 2004, William A.(Andy) Adamson wrote:

> hello sridhar
>
> sri@us.ibm.com said:
> > I guess you are referring to the race resulting in lockd() being
> > blocked in the call to posix_lock_file() if someone else takes the
> > lock between posix_test_lock() and posix_lock_file().
>
> > In our patch the above segment becomes
> >          if (!(conflock = posix_test_lock(file->f_file, &lock->fl))) {
> >                  error = vfs_lock_file(file->f_file, &lock->fl, wait);
>
> > Here vfs_lock_file() will return immediately with EINPROGRESS if the
> > underlying filesystem supports asynchronous locking mechanism avoiding
> > the blocking of lockd. But i agree that lockd can block in this
> > situation when f_op->lock is NULL.
>
> > The advantage of having the 2 calls is that if the lock is held
> > locally, posix_test_lock() which is much cheaper returns a conflock
> > and we can avoid the call to the filesystem.
>
> hmm. the call to posix_test_lock() does not check to see if the underlying
> file system has granted a conflicting lock.
>
>
>         client A           client B
>            |                 |
>            |                 |
> 	lockd A            lockd B
>         cluster fs         clusterfs
>                  \           /
>                   shared disk
>
> say client A and client B ask for a lock on file foo with range R1 - the
> requests conflict, and lockd A gets the request just before lockd B. on lockd
> A, posix_test_lock() reports no conflict, and lockd A proceeds to call
> vfs_lock_file and gets the lock. meanwhile, lockd B calls posix_test_lock()
> which incorrectly reports no conflict. lockd B calls vfs_lock_file which calls
> into the file system and fails with a conflict.

you seem to be referring to a non-blocking(F_SETLK) lock. If it was a blocking
(F_SETLKW) lock, lockd B will return NLM_BLOCKED to the client and
asynchronously waits for the callback from the filesystem to get the lock.

I don't see any problem in either cases with this patch. Just to be clear,
i will try to describe how the 2 situations are handled.

F_SETLK(non-blocking)
---------------------
When lockd B calls vfs_lock_file which calls into the filesystem, it returns
EINPROGRESS. lockd B creates a block with B_DEFERRED flag, inserts the block
into the nlm_blocked list with 7secs timeout and sets up the pointers to
defer the request.
- If the lock becomes available within 7secs(lockd A releases the lock),
nlmsvc_vfs_callback is invoked by filesystem B.  This callback routine finds
the corresponding block in the nlm_blocked list, sets b_granted and B_GOT_LOCK
flags, moves it to the head of the list and wakes up lockd B.  lockd B calls
nlmsvc_retry_blocked, which in turn calls revisit of deferred request
resulting in the call to nlmsvc_lock. nlmsvc_lock finds the deferred block
with B_GOT_LOCK flag and sends NLM_GRANTED to the client.
- If the lock is not available within 7secs, lockd B calls
nlmsvc_retry_blocked, finds the deferred block, sets B_TOO_LATE flag and calls
revisit of deferred request resulting in the call to nlmsvc_lock. nlmsvc_lock
finds the deferred block with B_TOO_LATE flag and sends NLM_LCK_DENIED to the
client.

F_SETLKW(blocking)
------------------
When lockd B calls vfs_lock_file which calls into the filesystem, it returns
EINPROGRESS. lockd B creates a block with B_DEFERRED|B_WAIT flags, inserts
it into the nlm_blocked list and returns NLM_BLOCKED to the client. Once the
lock is available(lockd A releases the lock), the filesystem B will invoke
nlmsvc_vfs_lock_callback().  This callback routine finds the
corresponding block in the nlm_blocked list, sets b_granted flag and moves it
to the head of the list and wakes up lockd B.  lockd B calls
nlmsvc_retry_blocked, which in turn calls nlmsvc_grant_blocked resulting in
GRANTED_MSG to be sent to the client.

>
> so even though posix_test_lock is cheaper, it is wrong. you have to ask the
> underlying file system, or refresh the in-memory inode->i_flock list (which is
> done by asking the underlying file system....)
>
> futhermore, unlike lockd, version 4 nfsd needs to return the conflicting lock.
> in the current situation, nfsd needs to call test_lock when set_lock fails
> with a conflict: and the conflicting lock could be released in the mean
> time....

In case of v4 nfsd, the problem seems to be that posix_lock_file() doesn't
return the conflicting lock if the lock is not available for a non-blocking
request. I think this can be easily fixed by changing the posix_lock_file()
and __posix_lock_file() interfaces to return the conflicting lock in a
**conflock paramter.

With this interface, i think we can avoid posix_test_lock() all together
in nfsd4_lock(). We can simply do
	status = posix_lock_file(filp, &file_lock, &conflock)
	...
	switch(-status) {
	....
	case (EAGAIN):
		status = nfserr_denied;
		nfs4_set_lock_denied(conflock, &lock->lk_denied);
		break;
	...

In case of a filesystem providing f_op->lock operation, the conflicting lock
will be returned via the callback(ex:nlmsvc_vfs_lock_callback in our patch
for lockd) and we don't have to change the VFS lock interface.

>
> so i would rather see a vfs_lock_and_test().
>
> -->Andy
>
>


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

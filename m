From: "William A.(Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: [RFC/PATCH - RESEND] NFS file locking for clustered file systems
Date: Fri, 24 Sep 2004 09:37:37 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040924133737.134D51BB06@citi.umich.edu>
References: <Pine.LNX.4.58.0409212112240.20518@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "William A.(Andy) Adamson" <andros@citi.umich.edu>,
	trond.myklebust@fys.uio.no, okir@suse.de, nfs@lists.sourceforge.net,
	nfsv4@linux-nfs.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAqGa-0002Pb-HV
	for nfs@lists.sourceforge.net; Fri, 24 Sep 2004 06:37:40 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CAqGZ-00066n-2Z
	for nfs@lists.sourceforge.net; Fri, 24 Sep 2004 06:37:40 -0700
To: Sridhar Samudrala <sri@us.ibm.com>
In-reply-to: Your message of "Wed, 22 Sep 2004 20:23:14 PDT."
             <Pine.LNX.4.58.0409212112240.20518@localhost.localdomain>
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

hello sridhar

sri@us.ibm.com said:
> I guess you are referring to the race resulting in lockd() being
> blocked in the call to posix_lock_file() if someone else takes the
> lock between posix_test_lock() and posix_lock_file().

> In our patch the above segment becomes
>          if (!(conflock = posix_test_lock(file->f_file, &lock->fl))) {
>                  error = vfs_lock_file(file->f_file, &lock->fl, wait);

> Here vfs_lock_file() will return immediately with EINPROGRESS if the
> underlying filesystem supports asynchronous locking mechanism avoiding
> the blocking of lockd. But i agree that lockd can block in this
> situation when f_op->lock is NULL.

> The advantage of having the 2 calls is that if the lock is held
> locally, posix_test_lock() which is much cheaper returns a conflock
> and we can avoid the call to the filesystem. 

hmm. the call to posix_test_lock() does not check to see if the underlying 
file system has granted a conflicting lock.


        client A           client B
           |                 |
           |                 |
	lockd A            lockd B
        cluster fs         clusterfs
                 \           /
                  shared disk

say client A and client B ask for a lock on file foo with range R1 - the 
requests conflict, and lockd A gets the request just before lockd B. on lockd 
A, posix_test_lock() reports no conflict, and lockd A proceeds to call 
vfs_lock_file and gets the lock. meanwhile, lockd B calls posix_test_lock() 
which incorrectly reports no conflict. lockd B calls vfs_lock_file which calls 
into the file system and fails with a conflict.

so even though posix_test_lock is cheaper, it is wrong. you have to ask the 
underlying file system, or refresh the in-memory inode->i_flock list (which is 
done by asking the underlying file system....)

futhermore, unlike lockd, version 4 nfsd needs to return the conflicting lock. 
in the current situation, nfsd needs to call test_lock when set_lock fails 
with a conflict: and the conflicting lock could be released in the mean 
time....

so i would rather see a vfs_lock_and_test().

-->Andy



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36888 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753126AbeDRPyk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 18 Apr 2018 11:54:40 -0400
Date: Wed, 18 Apr 2018 11:54:39 -0400
To: "Antonio M." <quactinoids@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: pynfs blocking lock test
Message-ID: <20180418155439.GA9897@fieldses.org>
References: <CAABTemTHvp+2rthSZNPgZBzfVvumy53bLuKS7wLEcuFopUpVig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAABTemTHvp+2rthSZNPgZBzfVvumy53bLuKS7wLEcuFopUpVig@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2018 at 07:32:42PM +0530, Antonio M. wrote:
> It looks like "testLongPoll" in st_lock.py is trying to test whether
> lock is not granted to others before client lease expires.
> 
> However, I don't understand that the following part of the code where
> lockowner3 is trying to grab a lock is also part of the same Client
> and sends LOCK with the same ClientID.
> ...
>         if badpoll:
>             # Third owner tries to butt in and steal lock
>             res3 = c.lock_file("owner3", fh3, stateid3,
>                                type=WRITEW_LT, lockowner="lockowner3_LOCK22")
> ...
> 
> So, after performing the LOCK operation (even though it was denied),
> lease on client will be renewed.
> And thus, lease will never expire. Only when the loop completes, LOCK
> will be unlocked by the first owner.

Without looking in detail at that code, I think what it's trying to test
for is the optional fair-locking behavior described here:

	https://tools.ietf.org/html/rfc7530#section-9.4

	Two new lock types are added, READW and WRITEW, and are used to
	indicate to the server that the client is requesting a blocking
	lock.  The server should maintain an ordered list of pending
	blocking locks.  When the conflicting lock is released, the
	server may wait the lease period for the first waiting client to
	re-request the lock.  After the lease period expires, the next
	waiting client request is allowed the lock.  Clients are
	required to poll at an interval sufficiently small that it is
	likely to acquire the lock in a timely manner.  The server is
	not required to maintain a list of pending blocked locks, as it
	is not used to provide correct operation but only to increase
	fairness.

So it's not expecting the server to remove the client entirely due to
lease expiry, it's just expecting the server to give up waiting for
another attempt to acquire that particular lock.

(Really I think the test should be using different clients instead of
just different lockowners.  Though if we modify it to use different
clients we will need to make sure it renews the leases on all of them
regularly, since it's the queuing of blocked locks we're trying to test,
not lease expiry.)

> Also, the test does not consider that if NFS server is implementing
> delayed return of DENIAL for conflicting locks.
> 
> Does this test assume certain NFS server implementation ? Also, what
> if the lease is anyway going to be renewed for failed operation since
> client id would be matching and that is good enough to renew lease.

If I remember right, those tests were written years ago to test some
linux server code that never got merged.

There's a reason those tests aren't run by default.  I'll happily take
patches if you thin the tests can be made more useful.  Removing them
entirely might also be OK if you think they're not salvageable.

--b.

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57268 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988Ab3FXTbx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Jun 2013 15:31:53 -0400
Date: Mon, 24 Jun 2013 15:31:53 -0400
To: Nadav Shemer <nadav@tonian.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: LAYOUTGET and NFS4ERR_DELAY: a few questions
Message-ID: <20130624193153.GC23596@fieldses.org>
References: <CADnca3voFCr1xbwNcHEq-YCip2ghBrH3Ni2XARfcW6pdLw1K-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CADnca3voFCr1xbwNcHEq-YCip2ghBrH3Ni2XARfcW6pdLw1K-A@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 23, 2013 at 04:27:52PM +0300, Nadav Shemer wrote:
> Background: I'm working on a pnfs-exported filesystem implementation
> (using objects-based storage)
> In my ->layout_get() implementation, I use mutex_trylock() and return
> NFS4ERR_DELAY in the contended case
> In a real-world test, I discovered the client always waits 15 seconds
> when receiving this error for LAYOUTGET.
> This occurs in nfs4_async_handle_error, which always wait for
> NFS4_POLL_RETRY_MAX when getting DELAY, GRACE or EKEYEXPIRED
> 
> This is in contrast to nfs4_handle_exception, which calls nfs4_delay.
> In this path, the wait begins at NFS4_POLL_RETRY_MIN (0.1 seconds) and
> increases two-fold each time up to RETRY_MAX.
> It is used by many nfs4_proc operations - the caller creates an
> nfs4_exception structure, and retries the operation until success (or
> permanent error).
> 
> when nfs4_async_handle_error is used, OTOH, the RPC task is restarted
> in the ->rpc_call_done callback and the sleeping is done with
> rpc_delay
> 
> nfs4_async_handle_error is used in:
> CLOSE, UNLINK, RENAME, READ, WRITE, COMMIT, DELEGRETURN, LOCKU,
> LAYOUTGET, LAYOUTRETURN and LAYOUTCOMMIT.
> A similar behavior (waiting RETRY_MAX) is also used in
> nfs4*_sequence_* functions (in which case it refers to the status of
> the SEQUENCE operation itself) and by RECLAIM_COMPLETE
> GET_LEASE_TIME also has such a code structure, but it always waits
> RETRY_MIN, not MAX
> 
> 
> The first question, raised in the beginning of this mail:
> Is it better to wait for the mutex in the NFSd thread (with the risk
> of blocking that nfsd thread)

nfsd threads block on mutexes all the time, and it's not necessarily a
problem--depends on exactly what it's blocking on.  You wouldn't want to
block waiting for the client to do something, as that might lead to
deadlock if the client can't make progress until the server responds to
some rpc.  If you're blocking waiting for a disk or some internal
cluster communication--it may be fine?

> or to return DELAY(with its 15s delay
> and risk of repeatedly landing on a contended mutex even if it is not
> kept locked the whole time)?
> Is there some other solution?
> 
> 
> The second question(s):
> Why are there several different implementations of the same
> restart/retry behaviors? why do some operations use one mechanism and
> others use another?
> Why isn't the exponential back-off mechanism used in these operations?

Here's a previous thread on the subject:

	http://comments.gmane.org/gmane.linux.nfs/56193

Attempting a summary: the constant delay is traditional behavior going
back to NFSv3, and the exponential backoff was added to handle DELAY
returns on OPEN due to delegation conflicts.

And it would likely be tough to justify another client change here
without a similar case where the spec clearly has the server returning
DELAY to something that needs to be retried quickly.

Not understanding your case, it doesn't sound like the result of any
real requirement but rather an implementation detail that you probably
want to fix in the server.

--b.

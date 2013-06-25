Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f45.google.com ([209.85.215.45]:45486 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146Ab3FYLvu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 07:51:50 -0400
Received: by mail-la0-f45.google.com with SMTP id fr10so11998865lab.18
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 04:51:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130624193153.GC23596@fieldses.org>
References: <CADnca3voFCr1xbwNcHEq-YCip2ghBrH3Ni2XARfcW6pdLw1K-A@mail.gmail.com>
	<20130624193153.GC23596@fieldses.org>
Date: Tue, 25 Jun 2013 14:51:48 +0300
Message-ID: <CADnca3vEfZZvWT_EfgBJ0AcmuUGXfVtGvasQqQQSAoQF7OLPJw@mail.gmail.com>
Subject: Re: LAYOUTGET and NFS4ERR_DELAY: a few questions
From: Nadav Shemer <nadav@tonian.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Lev <solo@tonian.com>,
        Idan Kedar <idank@tonian.com>, Benny Halevy <bhalevy@tonian.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 24, 2013 at 10:31 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Sun, Jun 23, 2013 at 04:27:52PM +0300, Nadav Shemer wrote:
>> Background: I'm working on a pnfs-exported filesystem implementation
>> (using objects-based storage)
>> In my ->layout_get() implementation, I use mutex_trylock() and return
>> NFS4ERR_DELAY in the contended case
>> In a real-world test, I discovered the client always waits 15 seconds
>> when receiving this error for LAYOUTGET.
>> This occurs in nfs4_async_handle_error, which always wait for
>> NFS4_POLL_RETRY_MAX when getting DELAY, GRACE or EKEYEXPIRED
>>
>> This is in contrast to nfs4_handle_exception, which calls nfs4_delay.
>> In this path, the wait begins at NFS4_POLL_RETRY_MIN (0.1 seconds) and
>> increases two-fold each time up to RETRY_MAX.
>> It is used by many nfs4_proc operations - the caller creates an
>> nfs4_exception structure, and retries the operation until success (or
>> permanent error).
>>
>> when nfs4_async_handle_error is used, OTOH, the RPC task is restarted
>> in the ->rpc_call_done callback and the sleeping is done with
>> rpc_delay
>>
>> nfs4_async_handle_error is used in:
>> CLOSE, UNLINK, RENAME, READ, WRITE, COMMIT, DELEGRETURN, LOCKU,
>> LAYOUTGET, LAYOUTRETURN and LAYOUTCOMMIT.
>> A similar behavior (waiting RETRY_MAX) is also used in
>> nfs4*_sequence_* functions (in which case it refers to the status of
>> the SEQUENCE operation itself) and by RECLAIM_COMPLETE
>> GET_LEASE_TIME also has such a code structure, but it always waits
>> RETRY_MIN, not MAX
>>
>>
>> The first question, raised in the beginning of this mail:
>> Is it better to wait for the mutex in the NFSd thread (with the risk
>> of blocking that nfsd thread)
>
> nfsd threads block on mutexes all the time, and it's not necessarily a
> problem--depends on exactly what it's blocking on.  You wouldn't want to
> block waiting for the client to do something, as that might lead to
> deadlock if the client can't make progress until the server responds to
> some rpc.  If you're blocking waiting for a disk or some internal
> cluster communication--it may be fine?
internal cluster communication - I may be blocking on a DS operation
(so the mutex is being held by another nfsd thread).
Does it make sense, then, to have a lot more nfsd threads than CPUs?
(if they spend their days waiting for other hosts)


>> or to return DELAY(with its 15s delay
>> and risk of repeatedly landing on a contended mutex even if it is not
>> kept locked the whole time)?
>> Is there some other solution?
>>
>>
>> The second question(s):
>> Why are there several different implementations of the same
>> restart/retry behaviors? why do some operations use one mechanism and
>> others use another?
>> Why isn't the exponential back-off mechanism used in these operations?
>
> Here's a previous thread on the subject:
>
>         http://comments.gmane.org/gmane.linux.nfs/56193
Thanks!

>
> Attempting a summary: the constant delay is traditional behavior going
> back to NFSv3, and the exponential backoff was added to handle DELAY
> returns on OPEN due to delegation conflicts.
>
> And it would likely be tough to justify another client change here
> without a similar case where the spec clearly has the server returning
> DELAY to something that needs to be retried quickly.
>
> Not understanding your case, it doesn't sound like the result of any
> real requirement but rather an implementation detail that you probably
> want to fix in the server.
Well, a LAYOUTGET may cause a conflicting layout to be recalled (f.e.
RAID in object storage - RFC 5664, 11.). Is that not similar to the
OPEN case?
This makes me ponder. If the server blocks while waiting for
conflicting layouts to be recalled, I think we can theoretically reach
a deadlock (if we take up all the nfsd threads or all the clients'
session slots): client A hold layout to file X, and requests layout to
file Y, while client B holds layout to file Y and requests layout to
file X.
To avoid this, we pretty much have to return DELAY for LAYOUTGET

>
> --b.

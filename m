Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa09-09.prod.phx3.secureserver.net ([173.201.193.238]:47054
	"EHLO p3plsmtpa09-09.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754750AbcC1WGR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2016 18:06:17 -0400
Subject: Re: Should NLM resends change the xid ??
To: Frank Filz <ffilzlnx@mindspring.com>, "'NeilBrown'" <neilb@suse.com>,
        "'Linux NFS mailing list'" <linux-nfs@vger.kernel.org>
References: <877fgnwkuv.fsf@notabene.neil.brown.name>
 <00a301d1890b$8b6ac190$a24044b0$@mindspring.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <56F9A923.2060700@talpey.com>
Date: Mon, 28 Mar 2016 17:58:59 -0400
MIME-Version: 1.0
In-Reply-To: <00a301d1890b$8b6ac190$a24044b0$@mindspring.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/28/2016 12:04 PM, Frank Filz wrote:
>> I've always thought that NLM was a less-than-perfect locking protocol, but
> I
>> recently discovered as aspect of it that is worse than I imagined.
>>
>> Suppose client-A holds a lock on some region of a file, and client-B makes
> a
>> non-blocking lock request for that region.
>> Now suppose as just before handling that request the lockd thread on the
>> server stalls - for example due to excessive memory pressure causing a
>> kmalloc to take 11 seconds (rare, but possible.  Such allocations never
> fail,
>> they just block until they can be served).
>>
>> During this 11 seconds (say, at the 5 second mark), client-A releases the
> lock -
>> the UNLOCK request to the server queues up behind the non-blocking LOCK
>> from client-B
>>
>> The default retry time for NLM in Linux is 10 seconds (even for TCP!) so
> NLM
>> on client-B resends the non-blocking LOCK request, and it queues up behind
>> the UNLOCK request.
>>
>> Now finally the lockd thread gets some memory/CPU time and starts
>> handling requests:
>>   LOCK from client-B  - DENIED
>>   UNLOCK from client-A - OK
>>   LOCK from client-B - OK
>>
>> Both replies to client-B have the same XID so client-B will believe
> whichever
>> one it gets first - DENIED.
>>
>> So now we have the situation where client-B doesn't think it holds a lock,
> but
>> the server thinks it does.  This is not good.
>>
>> I think this explains a locking problem that a customer is seeing.  The
>> application seems to busy-wait for the lock using non-blocking LOCK
>> requests.  Each LOCK request has a different 'svid' so I assume each comes
>> from a different process. If you busy-wait from the one process this
> problem
>> won't occur.
>>
>> Having a reply-cache on the server lockd might help, but such things
> easily fill
>> up and cannot provide a guarantee.
>>
>> Having a longer timeout on the client would probably help too.  At the
> very
>> least we should increase the maximum timeout beyond 20 seconds.
>> (assuming I reading the code correctly, the client resend timeout is based
> on
>> nlmsvc_timeout which is set from nlm_timeout which is restricted to the
>> range 3-20).
>>
>> Forcing the xid to change on every retransmit (for NLM) would ensure that
>> we only accept the last reply, which I think is safe.
>
> That sounds like a good solution to me. Since the requests are non-blocking,
> each request should be considered separate from the others.

I totally disagree. To issue a new XID contradicts the entire notion of
"retransmit". It will badly break any hope of idempotency.

To me, there are two issues here:
1) The client should not be retransmitting on an unbroken connection.
2) The server should have a reply cache.

If both of those were true, this problem would not occur.

That said, if client B were to *drop the connection* and then *reissue*
the lock with a new XID, there would be a chance of things working
as desired.

But this would still leave many existing NLM issues on the table. It's
a pipe dream that NLM (and NSM) will truly support correct locking
semantics in the face of transient errors.


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26023 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbcC3Pxv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Mar 2016 11:53:51 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Should NLM resends change the xid ??
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <871t6svkvo.fsf@notabene.neil.brown.name>
Date: Wed, 30 Mar 2016 11:53:44 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <47DC0362-0A4F-4304-817D-8504144390CF@oracle.com>
References: <877fgnwkuv.fsf@notabene.neil.brown.name> <9E0C02EA-2A3C-4B88-8557-B17D8864ED78@oracle.com> <877fgkvr3r.fsf@notabene.neil.brown.name> <1BABF7B1-0EFB-4208-8D53-59C3FA25C7FB@oracle.com> <871t6svkvo.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 29, 2016, at 9:02 PM, NeilBrown <neilb@suse.com> wrote:
> 
> On Wed, Mar 30 2016, Chuck Lever wrote:
> 
>>> On Mar 29, 2016, at 6:47 PM, NeilBrown <neilb@suse.com> wrote:
>>> 
>>> On Wed, Mar 30 2016, Chuck Lever wrote:
>>> 
>>>> Hi Neil-
>>>> 
>>>> Ramblings inline.
>>>> 
>>>> 
>>>>> On Mar 27, 2016, at 7:40 PM, NeilBrown <neilb@suse.com> wrote:
>>>>> 
>>>>> 
>>>>> I've always thought that NLM was a less-than-perfect locking protocol,
>>>>> but I recently discovered as aspect of it that is worse than I imagined.
>>>>> 
>>>>> Suppose client-A holds a lock on some region of a file, and client-B
>>>>> makes a non-blocking lock request for that region.
>>>>> Now suppose as just before handling that request the lockd thread
>>>>> on the server stalls - for example due to excessive memory pressure
>>>>> causing a kmalloc to take 11 seconds (rare, but possible.  Such
>>>>> allocations never fail, they just block until they can be served).
>>>>> 
>>>>> During this 11 seconds (say, at the 5 second mark), client-A releases
>>>>> the lock - the UNLOCK request to the server queues up behind the
>>>>> non-blocking LOCK from client-B
>>>>> 
>>>>> The default retry time for NLM in Linux is 10 seconds (even for TCP!) so
>>>>> NLM on client-B resends the non-blocking LOCK request, and it queues up
>>>>> behind the UNLOCK request.
>>>>> 
>>>>> Now finally the lockd thread gets some memory/CPU time and starts
>>>>> handling requests:
>>>>> LOCK from client-B  - DENIED
>>>>> UNLOCK from client-A - OK
>>>>> LOCK from client-B - OK
>>>>> 
>>>>> Both replies to client-B have the same XID so client-B will believe
>>>>> whichever one it gets first - DENIED.
>>>>> 
>>>>> So now we have the situation where client-B doesn't think it holds a
>>>>> lock, but the server thinks it does.  This is not good.
>>>>> 
>>>>> I think this explains a locking problem that a customer is seeing.  The
>>>>> application seems to busy-wait for the lock using non-blocking LOCK
>>>>> requests.  Each LOCK request has a different 'svid' so I assume each
>>>>> comes from a different process. If you busy-wait from the one process
>>>>> this problem won't occur.
>>>>> 
>>>>> Having a reply-cache on the server lockd might help, but such things
>>>>> easily fill up and cannot provide a guarantee.
>>>> 
>>>> What would happen if the client serialized non-blocking
>>>> lock operations for each inode? Or, if a non-blocking
>>>> lock request is outstanding on an inode when another
>>>> such request is made, can EAGAIN be returned to the
>>>> application?
>>> 
>>> I cannot quite see how this is relevant.
>>> I imagine one app on one client is using non-blocking requests to try to
>>> get a lock, and a different app on a different client holds, and then
>>> drops, the lock.
>>> I don't see how serialization on any one client will change that.
>> 
>> Each client and the server need to agree on the state of
>> a lock. If the client can send more than one non-blocking
>> request at the same time, it will surely be confused when
>> the requests or replies are misordered. IIUC this is
>> exactly what sequence IDs are for in NFSv4.
>> 
> 
> If a client sends two different non-blocking requests they will have
> different "svid" (aka client-side pid) values.  Providing the client
> gets replies to both requests it shouldn't be confused about the
> outcome.
> 
> Except... if two threads in the same process try non-blocking locks at
> the same time....  That is probably a recipe for confusion, but I don't
> think NLM makes it more confusing.

This is the case I'm concerned about.


> If the lock gets granted on the server, then it is quite possible that
> either or both threads will think that they got the lock (as a lock held
> by one thread does not conflict with a lock held by the other).  But at
> least one thread will think it owns it.
> If the lock doesn't get granted, neither threads will think they have it.
> 
>> 
>>>>> Having a longer timeout on the client would probably help too.  At the
>>>>> very least we should increase the maximum timeout beyond 20 seconds.
>>>>> (assuming I reading the code correctly, the client resend timeout is
>>>>> based on nlmsvc_timeout which is set from nlm_timeout which is
>>>>> restricted to the range 3-20).
>>>> 
>>>> A longer timeout means the client is slower to respond to
>>>> slow or lost replies (ie, adjusting the timeout is not
>>>> consequence free).
>>> 
>>> True.  But for NFS/TCP the default timeout is 60 seconds.
>>> For NLM/TCP the default is 10 seconds and a hard upper limit is 20
>>> seconds.
>>> This, at least, can be changed without fearing consequences.
>> 
>> The consequences are slower recovery from dropped requests.
> 
> Is NLM more likely to drop requests than NFS?

It's quite possible that NLM may use UDP even if
NFS is using TCP.

It's also possible that lockd has more GFP_KERNEL
allocations in normal request paths than typical
small NFS operations, making it more vulnerable
to memory exhaustion.


>>>> Making the RTT slightly longer than this particular server
>>>> needs to recharge its batteries seems like a very local
>>>> tuning adjustment.
>>> 
>>> This is exactly what I've ask out partner to experiment with.  No
>>> results yet.
>> 
>> It may indeed help this customer, but my point is this is
>> not a reason to make a change to the shrink-wrap defaults.
>> 
> 
> Even if those defaults are inconsistent? Treating NLM very differently
> From NFS?

NLM is all about managing in-memory state, while NFS has
to deal with the additional latency of permanent storage.

I would expect the two protocols to have different latency
distributions, and thus different timeout settings and
NLM would have a shorter timeout than NFS.


>>>>> Forcing the xid to change on every retransmit (for NLM) would ensure
>>>>> that we only accept the last reply, which I think is safe.
>>>> 
>>>> To make this work, then, you'd make client-side NLM
>>>> RPCs soft, and the upper layer (NLM) would handle
>>>> the retries. When a soft RPC times out, that would
>>>> "cancel" that XID and the client would ignore
>>>> subsequent replies for it.
>>> 
>>> Soft, with zero retransmits I assume.  The NLM client already assumes
>>> "hard" (it doesn't pay attention to the "soft" NFS option).  Moving that
>>> indefinite retry from sunrpc to lockd would probably be easy enough.
>>> 
>>> 
>>>> 
>>>> The problem is what happens when the server has
>>>> received and processed the original RPC, but the
>>>> reply itself is lost (say, because the TCP
>>>> connection closed due to a network partition).
>>>> 
>>>> Seems like there is similar capacity for the client
>>>> and server to disagree about the state of the lock.
>>> 
>>> I think that as long as the client sees the reply to the *last* request,
>>> they will end up agreeing.
>> 
>> Can you show how you proved this to be the case?
> 
> Ahhh... It's "proof" you want is it.  Where is that envelope....
> 
> I'm assuming that a single process will be single-threaded with respect
> to any given lock, so it can only race with other processes/clients.
> 
> If a process sends an arbitrary number of non-blocking LOCK requests,
> then either none of them will be granted, or one will be granted and the
> others will acknowledge that the lock is already in place.  There is no
> difference in the NLM response between "You have just been granted this
> lock" and "You already had this lock, why you ask again".  So the reply
> to the last request will indicate if the lock is held or not.

> For UNLOCK requests, the lock - if there was one - will be dropped on
> the first request processed so multiple consecutive UNLOCK requests will
> all return the same result, including particularly the last one.
> 
> For blocking LOCK requests the situation is much the same as non-blocking
> locks except that the lock is granted pre-emptively (as soon as
> something else unlocks it) and there is a GRANT callback.  Providing the
> client continues to make LOCK requests until it is granted (as you would
> expect), or makes an UNLOCK request repeatedly until that is acknowledged
> (as you would expect if the lock attempt is aborted), one of the above
> two cases applies.
> 
> Is that woffle enough of a proof?

Helpful, thanks!


>>> So if requests can be re-order you could have problems, but tcp protects
>>> us again that.
>> 
>> No, it doesn't. The server is free to put RPC replies
>> on a TCP socket in any order, and the TCP connection
>> can be lost at any time due to network partition.
> 
> Re-ordering of replies isn't a problem - providing they don't have the
> same 'xid' which is what I'm proposing.  The client can tell which reply
> matches which request and will only attend to the reply to the *last*
> request.

> Re-ordering *requests* can be a problem.  But the client will put them
> on the connection in the correct order.

"soft" is a convenient way to experiment with this
behavior, but it cannot be made reliable. A pending RPC
can time out on the client, but the server is still
processing it, and will run it to completion, even if
the client sends the same or a similar request again.
Request ordering is lost, and using a fresh XID can't
help.

I discovered a problem a long time ago with retransmits
re-ordering NFSv3 WRITE operations, which resulted in
data corruption. When disconnect is involved, the
client has to send the retransmitted requests in
exactly the same order they were originally sent.

That still doesn't guarantee correct ordering. It is well
known that requests can be processed out of order by the
server (precisely because of resource starvation!), and
that the server's replies can be put on the socket in any
order. As you say, normally that doesn't matter, but there
are times where it is critical.

The only way to guarantee request ordering in cases like
this is for the client to ensure that a reply is received
first, then a subsequent order-dependent request is sent.
The challenge is identifying all the order dependencies.


> If the client closes a TCP connection, opens a new one, and sends a
> request, can the server still process requests that arrived on the first
> connection after requests on the second?

Indeed it can.

The connection closes, but the server keeps processing
existing requests. When it comes time to put the replies
on the wire, the server realizes the original connection
is gone, and it drops the replies.

But the requests have taken effect. Fresh copies of
the same requests see different server state, and the
replies will possibly be different.

Same problem a premature "soft" timeout has.

All fixed by NFSv4 sessions, where there is a bounded
reply cache that can be reliably re-discovered after a
connection loss.


> I would hope that the "close connection" would wait for FIN+ACK from the
> server, after which the server would not read anything more??


--
Chuck Lever




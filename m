Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42357 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757050AbcC2OlL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2016 10:41:11 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Should NLM resends change the xid ??
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <877fgnwkuv.fsf@notabene.neil.brown.name>
Date: Tue, 29 Mar 2016 10:40:03 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9E0C02EA-2A3C-4B88-8557-B17D8864ED78@oracle.com>
References: <877fgnwkuv.fsf@notabene.neil.brown.name>
To: NeilBrown <neilb@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

Ramblings inline.


> On Mar 27, 2016, at 7:40 PM, NeilBrown <neilb@suse.com> wrote:
> 
> 
> I've always thought that NLM was a less-than-perfect locking protocol,
> but I recently discovered as aspect of it that is worse than I imagined.
> 
> Suppose client-A holds a lock on some region of a file, and client-B
> makes a non-blocking lock request for that region.
> Now suppose as just before handling that request the lockd thread
> on the server stalls - for example due to excessive memory pressure
> causing a kmalloc to take 11 seconds (rare, but possible.  Such
> allocations never fail, they just block until they can be served).
> 
> During this 11 seconds (say, at the 5 second mark), client-A releases
> the lock - the UNLOCK request to the server queues up behind the
> non-blocking LOCK from client-B
> 
> The default retry time for NLM in Linux is 10 seconds (even for TCP!) so
> NLM on client-B resends the non-blocking LOCK request, and it queues up
> behind the UNLOCK request.
> 
> Now finally the lockd thread gets some memory/CPU time and starts
> handling requests:
> LOCK from client-B  - DENIED
> UNLOCK from client-A - OK
> LOCK from client-B - OK
> 
> Both replies to client-B have the same XID so client-B will believe
> whichever one it gets first - DENIED.
> 
> So now we have the situation where client-B doesn't think it holds a
> lock, but the server thinks it does.  This is not good.
> 
> I think this explains a locking problem that a customer is seeing.  The
> application seems to busy-wait for the lock using non-blocking LOCK
> requests.  Each LOCK request has a different 'svid' so I assume each
> comes from a different process. If you busy-wait from the one process
> this problem won't occur.
> 
> Having a reply-cache on the server lockd might help, but such things
> easily fill up and cannot provide a guarantee.

What would happen if the client serialized non-blocking
lock operations for each inode? Or, if a non-blocking
lock request is outstanding on an inode when another
such request is made, can EAGAIN be returned to the
application?


> Having a longer timeout on the client would probably help too.  At the
> very least we should increase the maximum timeout beyond 20 seconds.
> (assuming I reading the code correctly, the client resend timeout is
> based on nlmsvc_timeout which is set from nlm_timeout which is
> restricted to the range 3-20).

A longer timeout means the client is slower to respond to
slow or lost replies (ie, adjusting the timeout is not
consequence free).

Making the RTT slightly longer than this particular server
needs to recharge its batteries seems like a very local
tuning adjustment.


> Forcing the xid to change on every retransmit (for NLM) would ensure
> that we only accept the last reply, which I think is safe.

To make this work, then, you'd make client-side NLM
RPCs soft, and the upper layer (NLM) would handle
the retries. When a soft RPC times out, that would
"cancel" that XID and the client would ignore
subsequent replies for it.

The problem is what happens when the server has
received and processed the original RPC, but the
reply itself is lost (say, because the TCP
connection closed due to a network partition).

Seems like there is similar capacity for the client
and server to disagree about the state of the lock.


--
Chuck Lever




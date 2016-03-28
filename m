Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:34720 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753863AbcC1QN4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2016 12:13:56 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'NeilBrown'" <neilb@suse.com>,
        "'Linux NFS mailing list'" <linux-nfs@vger.kernel.org>
References: <877fgnwkuv.fsf@notabene.neil.brown.name>
In-Reply-To: <877fgnwkuv.fsf@notabene.neil.brown.name>
Subject: RE: Should NLM resends change the xid ??
Date: Mon, 28 Mar 2016 09:04:43 -0700
Message-ID: <00a301d1890b$8b6ac190$a24044b0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I've always thought that NLM was a less-than-perfect locking protocol, but
I
> recently discovered as aspect of it that is worse than I imagined.
> 
> Suppose client-A holds a lock on some region of a file, and client-B makes
a
> non-blocking lock request for that region.
> Now suppose as just before handling that request the lockd thread on the
> server stalls - for example due to excessive memory pressure causing a
> kmalloc to take 11 seconds (rare, but possible.  Such allocations never
fail,
> they just block until they can be served).
> 
> During this 11 seconds (say, at the 5 second mark), client-A releases the
lock -
> the UNLOCK request to the server queues up behind the non-blocking LOCK
> from client-B
> 
> The default retry time for NLM in Linux is 10 seconds (even for TCP!) so
NLM
> on client-B resends the non-blocking LOCK request, and it queues up behind
> the UNLOCK request.
> 
> Now finally the lockd thread gets some memory/CPU time and starts
> handling requests:
>  LOCK from client-B  - DENIED
>  UNLOCK from client-A - OK
>  LOCK from client-B - OK
> 
> Both replies to client-B have the same XID so client-B will believe
whichever
> one it gets first - DENIED.
> 
> So now we have the situation where client-B doesn't think it holds a lock,
but
> the server thinks it does.  This is not good.
> 
> I think this explains a locking problem that a customer is seeing.  The
> application seems to busy-wait for the lock using non-blocking LOCK
> requests.  Each LOCK request has a different 'svid' so I assume each comes
> from a different process. If you busy-wait from the one process this
problem
> won't occur.
> 
> Having a reply-cache on the server lockd might help, but such things
easily fill
> up and cannot provide a guarantee.
> 
> Having a longer timeout on the client would probably help too.  At the
very
> least we should increase the maximum timeout beyond 20 seconds.
> (assuming I reading the code correctly, the client resend timeout is based
on
> nlmsvc_timeout which is set from nlm_timeout which is restricted to the
> range 3-20).
> 
> Forcing the xid to change on every retransmit (for NLM) would ensure that
> we only accept the last reply, which I think is safe.

That sounds like a good solution to me. Since the requests are non-blocking,
each request should be considered separate from the others.

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus


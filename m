From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [Fwd: Re: Linux 2.6.25-rc2]
Date: Tue, 19 Feb 2008 19:00:51 +1100
Message-ID: <47BA8CB3.4030703@melbourne.sgi.com>
References: <1203282165.2929.7.camel@heimdal.trondhjem.org>	 <20080218174509.GC32492@fieldses.org> <1203358682.24272.31.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:56259 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751887AbYBSH4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2008 02:56:21 -0500
In-Reply-To: <1203358682.24272.31.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Tucker wrote:
> Bruce:
>
> I'll take a look...
>
> Tom
>
> On Mon, 2008-02-18 at 12:45 -0500, J. Bruce Fields wrote:
>   
>> On Sun, Feb 17, 2008 at 04:02:45PM -0500, Trond Myklebust wrote:
>>     
>>> Hi Bruce,
>>>
>>> Here is a question for you.
>>>
>>>         Why does svc_close_all() get away with deleting xprt->xpt_ready
>>>         without holding the pool->sp_lock?
>>>       
>> >From a quick look--I think the intention is that the code that calls it
>> (in svc_destroy()) is only called after all other server threads have
>> exited, and that there can't be anyone else monkeying with that service
>> any more.  But I haven't verified that really carefully.
>>     
That's certainly the intention.  The serv->sv_nrthreads fields is used
as a refcount, which counts 1 for each nfsd thread and sometimes 1 to
guard some short-term manipulations.  This refcount should not drop to
zero until the last thread exits.  So by the time svc_close_all() is
called, no thread can be looking at a pool's sp_sockets list.  Each
xprt could still be racily added to that list from softirq mode data
ready handlers calling svc_xprt_enqueue(), but only until the xprt's
xpo_detach method is called (which removes any data ready callbacks).
At that point, no code should be modifying the xpt_ready field, and
it may or may not be used to link the xprt into some pool->sp_sockets
but we don't care because all the pools are about to be destroyed
anyway.

That's the way it's been working since 2.6.19, and I don't think any
of Tom's patches changed that.

I can think of a couple of things that could be wrong:

 * serv->sv_nrthreads is used in a few places, and there might
   be bugs in that which are getting that count wrong (when I left
   the code, all increments and decrements of that field went through
   svc_get() and svc_destroy(), but other changes have crept in).

 * Currently running data ready callbacks might be racing with xpo_detach.
   Moving that call inside the spin_lock_bh() critical section just
   after it might help.



>>>> For more on this problem see http://marc.info/?l=linux-kernel&m=120293042005445
>>>>         
>>> There's the Bugzilla entry for it at
>>>
>>>       
>
>
> http://bugzilla.kernel.org/show_bug.cgi?id=9973
>   

It's not clear from the bugzilla that NFS is at fault here.


-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.


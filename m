From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH] sunrpc: remove unnecessary svc_xprt_put
Date: Fri, 26 Feb 2010 20:38:25 -0600
Message-ID: <4B8885A1.500@opengridcomputing.com>
References: <19336.19524.469529.431210@notabene.brown>	<20100226225416.GF26598@fieldses.org>	<4B886A1A.7060106@opengridcomputing.com> <20100227123537.6289e326@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:39197 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759532Ab0B0CiZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Feb 2010 21:38:25 -0500
In-Reply-To: <20100227123537.6289e326-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> On Fri, 26 Feb 2010 18:40:58 -0600
> Tom Tucker <tom@opengridcomputing.com> wrote:
>
>   
>> J. Bruce Fields wrote:
>>     
>>> On Sat, Feb 27, 2010 at 09:33:40AM +1100, Neil Brown wrote:
>>>     
>>>       
>>>> [I found this while looking for the current refcount problem
>>>>  that triggers a warning in svc_recv.  This isn't that bug
>>>>  but is a different refcount bug - NB]
>>>>       
>>>>         
>>>     
>>>       
>> I seem to recall that we added that reference for  a reason. There was 
>> an issue with unmount while there were deferrals pending. That's why the 
>> reference was added.
>>
>> Tom
>>     
>
> What reference?
> What I (thought I) found was code that was dropping a reference which it
> didn't hold.  Are you saying that it is supposed to be holding a reference
> here, but isn't, or that it really is holding a reference here and I didn't
> see it?
>   

Here's the commit that I was thinking of... 
22945e4a1c7454c97f5d8aee1ef526c83fef3223

I think this change adds the bug that you are now fixing. It fixed one 
problem, but added another that you have now resolved.

What do you guys think?

Thanks,
Tom
> And just for completeness, my understanding of the refcounting here is:
>
> A counted references is held on an svc_xprt when:
>  - a 'struct rqst' refers to it through ->rq_xprt
>  - a 'cache_deferred_req' refers to it through ->xprt
>     This only happens while the req is waiting to be
>     revisited, and is in the hash table and on the lru.
>     Once the req gets revisited (svc_revisit) ->xprt
>     is set to NULL and the reference is dropped.
>  - XPT_DEAD is *not* set.  So the refcount is initialised
>    to '1' to reflect this, and this ref is dropped
>    when we set XPT_DEAD.
>  - there are a few transient references in svc_xprt.c
>    which very clearly have matched 'get' and 'put'.
>  - svc_find_xprt returns a counted reference.  This is
>    called once in lockd and once in nfsd, and both
>    calls drop the ref correctly.
>
> Whenever we drop a counted ref that was stored in a pointer, we set that
> pointer to NULL.
> So if there was a race where two threads both get a reference from a pointer
> and then drop that reference, you would expect that slightly different timing
> would cause one of those threads to get a NULL from the pointer, dereference
> it, and crash.  There are no important tests-for-NULL on either of the
> pointers in question, so that wouldn't be protecting us from a crash.  But
> we don't see that crash, so there cannot be a race there.
>
> So: The refcount cannot possibly be zero in svc_recv :-)
>
> I just noticed some slightly odd code later in svc_recv:
>
>  if (XPT_LISTENER && XPT_CLOSE) {
>      ...
>  } else if (XPT_CLOSE) {
>      ...
>      ->xpo_recvfrom()
>  }
>  if (XPT_CLOSE) {
>     ...
>     svc_delete_xprt()
>  }
>
>  So if XPT_CLOSE is set while xpo_recvfrom is being called, which I think
>  is possible, and if ->xpo_recvfrom returns non-zero, then we end up
>  processing a request on a dead socket, which doesn't sound like the right
>  thing to do.  I don't think it can cause the present problem, but
>  it looks wrong.  That last 'if' should just be an 'else'.
>  I guess that would effectively reverse b0401d7253, though - not that
>  that patch seems entirely right to me - if there is a problem I probably
>  would have fixed it differently, though I'm not sure how.
>  So maybe change "if (XPT_CLOSE)" to "if (len <= 0 && XPT_CLOSE)" ???
>
> NeilBrown
>   


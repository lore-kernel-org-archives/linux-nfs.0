From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 01/22] gss_krb5: introduce encryption type framework
Date: Tue, 16 Mar 2010 17:47:54 -0400
Message-ID: <4B9FFC8A.6070802@RedHat.com>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>	 <1268655627-18712-2-git-send-email-steved@redhat.com>	 <1268668733.2993.90.camel@localhost.localdomain>	 <4B9FEEE0.8040306@RedHat.com> <1268774075.3098.56.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54675 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036Ab0CPVsB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Mar 2010 17:48:01 -0400
In-Reply-To: <1268774075.3098.56.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/16/2010 05:14 PM, Trond Myklebust wrote:
> On Tue, 2010-03-16 at 16:49 -0400, Steve Dickson wrote: 
>>
>> On 03/15/2010 11:58 AM, Trond Myklebust wrote:
>>> On Mon, 2010-03-15 at 08:20 -0400, steved@redhat.com wrote: 
>>>> @@ -1317,15 +1317,21 @@ gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
>>>>  	inpages = snd_buf->pages + first;
>>>>  	snd_buf->pages = rqstp->rq_enc_pages;
>>>>  	snd_buf->page_base -= first << PAGE_CACHE_SHIFT;
>>>> -	/* Give the tail its own page, in case we need extra space in the
>>>> -	 * head when wrapping: */
>>>> +	/*
>>>> +	 * Give the tail its own page, in case we need extra space in the
>>>> +	 * head when wrapping:
>>>> +	 *
>>>> +	 * call_allocate() allocates twice the slack space required
>>>> +	 * by the authentication flavor to rq_callsize.
>>>> +	 * For GSS, slack is GSS_CRED_SLACK.
>>>> +	 */
>>>
>>> I'm all for improving the comments in the code, but could we please make
>>> that a separate patch.
>> Really? I'm curious... what is not clear about the above diff
> 
> The comments are unrelated to the functionality changes of the patch,
> and are distracting when you are just trying to figure out those
> changes.
> Splitting out the comments (except those directly related to code that
> is being changed) therefore helps readability.
I guess.. but at the end of the day it all ends up in the
same place... 

The comments will be broken into a separate patch... 

> 
>>>> +
>>>> +	GSS_KRB5_SLACK_CHECK;
>>>           ^^^^^^^^^^^^^^^^^^^^^
>>>               Why is this a macro?
>> To hide the ugliness of the BUILD_BUG_ON() macro which I think
>> is a good thing... I would rather see that one line verse the 10
>> or so lines it hiding... 
> 
> I wouldn't.
> 
> I can accept putting that _sum_ into a macro, but expanding the
> BUILD_BUG_ON.
> 
> IOW:
> 
> #define GSS_KRB5_MAX_SLACK_NEEDED \
> 	GSS_KRB5_TOK_HDR_LEN      /* gss token header */         \
> 	+ GSS_KRB5_MAX_CKSUM_LEN  /* gss token checksum */       \
> 	+ GSS_KRB5_MAX_BLOCKSIZE  /* confounder */               \
> 	.... \
> 	)
> 
> and then inserting the following line above
> 
> BUILD_BUG_ON(GSS_KRB5_MAX_SLACK_NEEDED > RPC_MAX_AUTH_SIZE);
> 
> That makes it obvious what is being checked and why.

The above BUILD_BUG_ON() will be added... 


steved.


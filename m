Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34923 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaAGFHK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jan 2014 00:07:10 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so19104670pde.0
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2014 21:07:10 -0800 (PST)
Message-ID: <52CB8B79.6040907@gmail.com>
Date: Tue, 07 Jan 2014 13:07:05 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dr Fields James Bruce <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: fix a memory leak for tcp NFSv4.1 backchannel
References: <52CA7862.1020203@gmail.com> <20140106184926.GC31764@fieldses.org> <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com> <20140106225346.GB3342@fieldses.org> <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com>
In-Reply-To: <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/07/2014 07:28 AM, Trond Myklebust wrote:
> 
> On Jan 6, 2014, at 17:53, Dr Fields James Bruce <bfields@fieldses.org> wrote:
> 
>> On Mon, Jan 06, 2014 at 05:40:03PM -0500, Trond Myklebust wrote:
>>>
>>> On Jan 6, 2014, at 13:49, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>
>>>> On Mon, Jan 06, 2014 at 05:33:22PM +0800, Kinglong Mee wrote:
>>>>> xs_setup_bc_tcp may return an existing xprt with non-NULL servername.
>>>>> xprt_create_transport should not kstrdup servername for it.
>>>>> Otherwise, those memory for servername will be leaked.
>>>>
>>>> OK.  Applying to my tree if Trond has no objection.
>>>
>>> Actually. Why do we go through all this code at all if xs_setup_bc_tcp() returns args->bc_xprt->xpt_bc_xprt? I’m assuming that is the only case where xprt->servername != NULL, right?
>>>
>>> For instance, won’t calling INIT_WORK() be a source of problems?

I will have a check for INIT_WORK which I have missing here.

>>
>> Huh.  Looking at the history....  There used to be a
>>
>> 	if (test_and_set_bit(XPRT_INITIALIZED, &xprt->state))
>> 		/* ->setup returned a pre-initialized xprt: */
>> 		return xprt;
>>
>> here, but it got removed by 21de0a955f3af29fa1100d96f66e6adade89e77a
>> "SUNRPC: Clean up the slot table allocation", which looks otherwise
>> unrelated.  Was that just some kind of rebasing mistake, or was there a
>> reason for that?
> 
> I probably misunderstood that bc_xprt sends a fully initialized struct rpc_xprt.
> 
> The obvious question if that is the case, is why we are calling xprt_create_transport() at all? If .bc_xprt->xpt_bc_xprt contains a fully initialized struct rpc_xprt, then just have rpc_create() do the honors.
> Better yet, create a svc_create_backchannel_client() helper that calls rpc_new_client() with the correct parameters. I really don’t like those rpc_create_args hacks that introduce fields that are completely private to nfsd.

Maybe should redesign the xs_setup_bc_tcp, because I have meet a new bug.
the xprt for backchannel don't be freed at all, and those memory is leaked,
as,

--> free_conn 
 --> svc_xprt_put
   --> svc_xprt_free
     --> xprt_put
       --> xprt_destroy
         --> xprt->ops->destroy(xprt);
         --> bc_destory

but, bc_destroy is empty as, 

2541 /*
2542  * The xprt destroy routine. Again, because this connection is client
2543  * initiated, we do nothing
2544  */
2545 
2546 static void bc_destroy(struct rpc_xprt *xprt)
2547 {
2548 }

so, after that, the memory of xprt for back channel is leaked.

thanks,
Kinglong Mee


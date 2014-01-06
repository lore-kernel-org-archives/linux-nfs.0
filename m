Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35814 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757010AbaAFX2k convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2014 18:28:40 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so19408646ief.20
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2014 15:28:40 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] SUNRPC: fix a memory leak for tcp NFSv4.1 backchannel
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140106225346.GB3342@fieldses.org>
Date: Mon, 6 Jan 2014 18:28:38 -0500
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com>
References: <52CA7862.1020203@gmail.com> <20140106184926.GC31764@fieldses.org> <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com> <20140106225346.GB3342@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 6, 2014, at 17:53, Dr Fields James Bruce <bfields@fieldses.org> wrote:

> On Mon, Jan 06, 2014 at 05:40:03PM -0500, Trond Myklebust wrote:
>> 
>> On Jan 6, 2014, at 13:49, J. Bruce Fields <bfields@fieldses.org> wrote:
>> 
>>> On Mon, Jan 06, 2014 at 05:33:22PM +0800, Kinglong Mee wrote:
>>>> xs_setup_bc_tcp may return an existing xprt with non-NULL servername.
>>>> xprt_create_transport should not kstrdup servername for it.
>>>> Otherwise, those memory for servername will be leaked.
>>> 
>>> OK.  Applying to my tree if Trond has no objection.
>> 
>> Actually. Why do we go through all this code at all if xs_setup_bc_tcp() returns args->bc_xprt->xpt_bc_xprt? I’m assuming that is the only case where xprt->servername != NULL, right?
>> 
>> For instance, won’t calling INIT_WORK() be a source of problems?
> 
> Huh.  Looking at the history....  There used to be a
> 
> 	if (test_and_set_bit(XPRT_INITIALIZED, &xprt->state))
> 		/* ->setup returned a pre-initialized xprt: */
> 		return xprt;
> 
> here, but it got removed by 21de0a955f3af29fa1100d96f66e6adade89e77a
> "SUNRPC: Clean up the slot table allocation", which looks otherwise
> unrelated.  Was that just some kind of rebasing mistake, or was there a
> reason for that?

I probably misunderstood that bc_xprt sends a fully initialized struct rpc_xprt.

The obvious question if that is the case, is why we are calling xprt_create_transport() at all? If .bc_xprt->xpt_bc_xprt contains a fully initialized struct rpc_xprt, then just have rpc_create() do the honors.
Better yet, create a svc_create_backchannel_client() helper that calls rpc_new_client() with the correct parameters. I really don’t like those rpc_create_args hacks that introduce fields that are completely private to nfsd.

Trond
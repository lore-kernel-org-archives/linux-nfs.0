From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 001/100] nfsd4: probe callback channel only once
Date: Mon, 28 Jan 2008 16:39:55 -0500
Message-ID: <20080128213955.GN16785@fieldses.org>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu> <68314FDD-D9D1-4DAA-9BC1-423612F05907@oracle.com> <20080128184807.GE16785@fieldses.org> <BF917C75-075F-4C6E-AE55-A9DF0D781862@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51298 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981AbYA1Vj5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 16:39:57 -0500
In-Reply-To: <BF917C75-075F-4C6E-AE55-A9DF0D781862@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 04:14:47PM -0500, Chuck Lever wrote:
> Hi Bruce-
>
> On Jan 28, 2008, at 1:48 PM, J. Bruce Fields wrote:
>> On Mon, Jan 28, 2008 at 12:35:48PM -0500, Chuck Lever wrote:
>>> On Jan 25, 2008, at 6:15 PM, J. Bruce Fields wrote:
>>>> Our callback code doesn't actually handle concurrent attempts to  
>>>> probe
>>>> the callback channel.  Some rethinking of the locking may be  
>>>> required.
>>>> However, we can also just move the callback probing to this case.
>>>> Since
>>>> this is the only time a client is "confirmed" (and since that can  
>>>> only
>>>> happen once in the lifetime of a client), this ensures we only probe
>>>> once.
>>>
>>> Applying 001/100 without applying 002/100 will probably break
>>> bisectability.
>>
>> You lost me here.  Why?  I'm probably just missing something obvious.
>
>
> Because, even though the kernel compiles with just 001, it doesn't work 
> properly.

Why not?  Treat me like a tired person here ('cause that would be
accurate) and break it down really carefully....

> In fact, it may even Oops, if I read 002 right, since no RPC 
> client is available to do the probe?

An rpc client is created in nfsd4_probe_callback():

        /* Create RPC client */
        cb->cb_client = rpc_create(&args);
        if (IS_ERR(cb->cb_client)) {
                dprintk("NFSD: couldn't create callback client\n");
                goto out_err;
        }

        /* the task holds a reference to the nfs4_client struct */
        atomic_inc(&clp->cl_count);

        t = kthread_run(do_probe_callback, clp, "nfs4_cb_probe");

All #2 does is move that rpc_create() into the do_probe_callback() called in
the new thread.

--b.

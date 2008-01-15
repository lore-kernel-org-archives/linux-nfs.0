From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Comments on some of the work in NFS_ALL for 2.6.25
Date: Tue, 15 Jan 2008 12:42:35 -0500
Message-ID: <28AB1E12-A4AD-49D8-B89D-7F8F8FF0EA85@oracle.com>
References: <1F8E054F-E33A-4441-944F-84E64233436A@oracle.com> <1200352256.12449.20.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:39671 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbYAORoz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 12:44:55 -0500
In-Reply-To: <1200352256.12449.20.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Howdy Trond-

On Jan 14, 2008, at 6:10 PM, Trond Myklebust wrote:
> On Mon, 2008-01-14 at 17:47 -0500, Chuck Lever wrote:
>> Hi Trond-
>>
>> A couple of initial comments on the RPC client API cleanups in the
>> latest NFS_ALL.
>>
>> First, I'm a little uncomfortable with the new rpc_call_start()
>> function.  Seems like that's a detail for the RPC client to manage,
>> not the ULPs (nor the developers of ULPs who want to use the RPC
>> client).  I think it would be cleaner (and less error prone) if the
>> RPC client set up tk_action entirely automatically rather than
>> requiring ULPs to know when to invoke rpc_call_start().
>
> You cannot avoid that. There are plenty of NFSv4 prepare_task()
> callbacks that requires you to loop until you have a sequence lock.
> Previously, if you had a prepare_task() callback, then you had to call
> rpc_call_setup(), which essentially does the same thing as
> rpc_call_start + sets up the rpc_message. rpc_call_start() simplifies
> things in that it allows the caller to set up the rpc_message before
> calling rpc_execute.

Of course, I need to review all of this more carefully; my comments  
are just a first impression.  From what I can tell, the setting of  
tk_action gates whether the RPC is actually dispatched, or just  
binned, when you call rpc_run_task().  If that's so, then it would be  
easier to understand if you code that logic explicitly in the ULP,  
and not use a side effect (like the tk_action setting).

As an aside, I see also you have open-coded "task->tk_action = NULL;"  
in the NFSv4 procs.  If you must make "rpc_call_start" an exported  
function, it would be cleaner API design to introduce a matching  
function to clear task->tk_action as well.  Something like  
rpc_arm_task() to set tk_action to call_start and rpc_disarm_task()  
to set tk_action to NULL.

But honestly I think hiding all of this entirely from ULPs provides a  
better and simpler RPC client interface.  Basically ULPs are  
puttering around in RPC client internal data structures with the  
current design.

>> Second, I see that you have created a new rpc_run_task() function
>> that replaces rpc_init_task + rpc_execute.  It manages the signal
>> mask appropriately.  However, in the NFS direct I/O path, we still
>> have a pair of rpc_clnt_sigmask() calls in nfs_direct_read() and
>> nfs_direct_write() that wrap all the RPC dispatching done in the
>> lower layers.
>
> Yup. We can get rid of those.

As I understand it, we want to prevent a signal from interrupting the  
dispatcher until all the RPCs have been sent.  Otherwise, we are  
inviting fractured reads and writes.  This is an important feature of  
the direct I/O engine.

> The whole idea here is that we should have
> _one_ entry point to the RPC code instead of the 5 or 6 different ways
> of setting up an rpc_task that we had previously.
>
> IOW: I don't want to have to code up 5 or 6 different ways of blocking
> RPC calls when we get the migration/replication code up and running.

Ah.  That's a reasonable goal, but unfortunately we don't have the  
context provided by nice cover letters when posting these jumbo  
change sets via git.  It would be nice if that objective was stated  
in at least one of the patch descriptions.

>> I had carefully optimized the direct path so there was only a single
>> pair of sigmask calls for each application I/O request, rather than
>> one pair for every dispatched RPC.  With the rpc_run_task interface,
>> we're now back to doing one pair for each RPC.  That seems like a
>> step backwards to me...?
>
> AFAICS, nfs_execute_read() dispatches only _one_ RPC call. Ditto for
> nfs_execute_write(). Those are the critical code paths...


Those are used only in the cached path.

> In fact, if you are interested in optimising away sigmask calls, then
> the first target should AFAICS be asynchronous RPC calls. Why set the
> sigmask at all when doing reads and writes?


Yes, but not at the expense of potentially fracturing writes.

I'll try to stop by CITI tomorrow morning, if you'll be around, to  
discuss it.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

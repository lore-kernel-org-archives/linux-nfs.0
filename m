From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Comments on some of the work in NFS_ALL for 2.6.25
Date: Mon, 14 Jan 2008 18:10:56 -0500
Message-ID: <1200352256.12449.20.camel@heimdal.trondhjem.org>
References: <1F8E054F-E33A-4441-944F-84E64233436A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:57064 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921AbYANXLA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 18:11:00 -0500
In-Reply-To: <1F8E054F-E33A-4441-944F-84E64233436A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-14 at 17:47 -0500, Chuck Lever wrote:
> Hi Trond-
> 
> A couple of initial comments on the RPC client API cleanups in the  
> latest NFS_ALL.
> 
> First, I'm a little uncomfortable with the new rpc_call_start()  
> function.  Seems like that's a detail for the RPC client to manage,  
> not the ULPs (nor the developers of ULPs who want to use the RPC  
> client).  I think it would be cleaner (and less error prone) if the  
> RPC client set up tk_action entirely automatically rather than  
> requiring ULPs to know when to invoke rpc_call_start().

You cannot avoid that. There are plenty of NFSv4 prepare_task()
callbacks that requires you to loop until you have a sequence lock.
Previously, if you had a prepare_task() callback, then you had to call
rpc_call_setup(), which essentially does the same thing as
rpc_call_start + sets up the rpc_message. rpc_call_start() simplifies
things in that it allows the caller to set up the rpc_message before
calling rpc_execute.

> Second, I see that you have created a new rpc_run_task() function  
> that replaces rpc_init_task + rpc_execute.  It manages the signal  
> mask appropriately.  However, in the NFS direct I/O path, we still  
> have a pair of rpc_clnt_sigmask() calls in nfs_direct_read() and  
> nfs_direct_write() that wrap all the RPC dispatching done in the  
> lower layers.

Yup. We can get rid of those. The whole idea here is that we should have
_one_ entry point to the RPC code instead of the 5 or 6 different ways
of setting up an rpc_task that we had previously.

IOW: I don't want to have to code up 5 or 6 different ways of blocking
RPC calls when we get the migration/replication code up and running.

> I had carefully optimized the direct path so there was only a single  
> pair of sigmask calls for each application I/O request, rather than  
> one pair for every dispatched RPC.  With the rpc_run_task interface,  
> we're now back to doing one pair for each RPC.  That seems like a  
> step backwards to me...?

AFAICS, nfs_execute_read() dispatches only _one_ RPC call. Ditto for
nfs_execute_write(). Those are the critical code paths...

Trond


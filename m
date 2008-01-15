From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Comments on some of the work in NFS_ALL for 2.6.25
Date: Tue, 15 Jan 2008 13:47:16 -0500
Message-ID: <1200422836.8937.24.camel@heimdal.trondhjem.org>
References: <1F8E054F-E33A-4441-944F-84E64233436A@oracle.com>
	 <1200352256.12449.20.camel@heimdal.trondhjem.org>
	 <28AB1E12-A4AD-49D8-B89D-7F8F8FF0EA85@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:33081 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbYAOSrU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 13:47:20 -0500
In-Reply-To: <28AB1E12-A4AD-49D8-B89D-7F8F8FF0EA85@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-15 at 12:42 -0500, Chuck Lever wrote:
> Howdy Trond-

> As an aside, I see also you have open-coded "task->tk_action = NULL;"  
> in the NFSv4 procs.  If you must make "rpc_call_start" an exported  
> function, it would be cleaner API design to introduce a matching  
> function to clear task->tk_action as well.  Something like  
> rpc_arm_task() to set tk_action to call_start and rpc_disarm_task()  
> to set tk_action to NULL.

I can add an rpc_call_abort() to wrap the tk_action clear, but frankly
there is a big difference here: the rpc_call_start() is there in order
to hide the private function call_start(). It is not there in order to
hide task->tk_action...

> But honestly I think hiding all of this entirely from ULPs provides a  
> better and simpler RPC client interface.  Basically ULPs are  
> puttering around in RPC client internal data structures with the  
> current design.

To which internal data structures are you referring?

> >> Second, I see that you have created a new rpc_run_task() function
> >> that replaces rpc_init_task + rpc_execute.  It manages the signal
> >> mask appropriately.  However, in the NFS direct I/O path, we still
> >> have a pair of rpc_clnt_sigmask() calls in nfs_direct_read() and
> >> nfs_direct_write() that wrap all the RPC dispatching done in the
> >> lower layers.
> >
> > Yup. We can get rid of those.
> 
> As I understand it, we want to prevent a signal from interrupting the  
> dispatcher until all the RPCs have been sent.  Otherwise, we are  
> inviting fractured reads and writes.  This is an important feature of  
> the direct I/O engine.

We only need to wrap the interruptible waits. I've got a patch that
moves the rpc_sigmask call into nfs_direct_wait(). If you add that to
the patch that gets rid of sigmask for the asynchronous rpc task case.
then that gets rid of them altogether for the aio/dio path.

> > In fact, if you are interested in optimising away sigmask calls, then
> > the first target should AFAICS be asynchronous RPC calls. Why set the
> > sigmask at all when doing reads and writes?
> 
> 
> Yes, but not at the expense of potentially fracturing writes.

I fail to see how this could occur. There are no interruptible waits or
any other checks for signals in the loop that schedules the write rpcs.

Trond


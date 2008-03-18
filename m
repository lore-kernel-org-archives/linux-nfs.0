From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: asynchronous destroy messages
Date: Tue, 18 Mar 2008 18:41:46 -0400
Message-ID: <47E0452A.1060401@citi.umich.edu>
References: <20080318221515.GE29948@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:26642 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761640AbYCSUPG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 16:15:06 -0400
In-Reply-To: <20080318221515.GE29948@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> When an rpc client is shut down, gss destroy messages are sent out
> asynchronously, and nobody waits for them.
>
> If those rpc messages arrive after the client is completely shut down, I
> assume they just get dropped by the networking code?  Is it possible for
> them to arrive while we're still in the process of shutting down, and if
> so, what makes this safe?
>
> Olga's seeing some odd oopses on shutdown after testing our gss callback
> code.  And of course it's probably our callback patches at fault, but I
> was starting to wonder if there was a problem with those destroy
> messages arriving at the wrong moment.  Any pointers welcomed.
>   
What I'm seeing is that nfs4_client structure goes away while an 
rpc_client is still active. nfs4_client and rpc_client share a pointer 
to the rpc_stat structure. so when nfs4_client memory goes away, the 
rpc_client oopses trying to dereference something within cl_stats.

put_nfs4_client() causes rpc_shutdown_client() causes an async destroy 
context message. that message shares the rpc_stats memory with the 
nfs4_client memory that is currently being released. since the task is 
asynchronous, put_nfs4_client() completes and memory goes away. the task 
that's handling destroy context message wakes up (usually in 
call_timeout or call_refresh) and tries to dereference cl_stats.


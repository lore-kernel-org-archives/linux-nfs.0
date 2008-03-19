From: Olga Kornievskaia <aglo@citi.umich.edu>
Subject: Re: asynchronous destroy messages
Date: Wed, 19 Mar 2008 10:59:34 -0400
Message-ID: <47E12A56.20703@citi.umich.edu>
References: <20080318221515.GE29948@fieldses.org>	 <47E1203B.7050201@citi.umich.edu> <1205937584.8388.40.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:24513 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757183AbYCSUPG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 16:15:06 -0400
In-Reply-To: <1205937584.8388.40.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Trond Myklebust wrote:
> On Wed, 2008-03-19 at 10:16 -0400, Olga Kornievskaia wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> When an rpc client is shut down, gss destroy messages are sent out
>>> asynchronously, and nobody waits for them.
>>>
>>> If those rpc messages arrive after the client is completely shut down, I
>>> assume they just get dropped by the networking code?  Is it possible for
>>> them to arrive while we're still in the process of shutting down, and if
>>> so, what makes this safe?
>>>
>>> Olga's seeing some odd oopses on shutdown after testing our gss callback
>>> code.  And of course it's probably our callback patches at fault, but I
>>> was starting to wonder if there was a problem with those destroy
>>> messages arriving at the wrong moment.  Any pointers welcomed.
>>>
>>>   
>>>       
>> What I'm seeing is that nfs4_client structure goes away while an 
>> rpc_client is still active. nfs4_client and rpc_client share a pointer 
>> to the rpc_stat structure. so when nfs4_client memory goes away, the 
>> rpc_client oopses trying to dereference something within cl_stats.
>>
>> put_nfs4_client() causes rpc_shutdown_client() causes an async destroy 
>> context message. that message shares the rpc_stats memory with the 
>> nfs4_client memory that is currently being released. since the task is 
>> asynchronous, put_nfs4_client() completes and memory goes away. the task 
>> that's handling destroy context message wakes up (usually in 
>> call_timeout or call_refresh) and tries to dereference cl_stats.
>>     
>
> clnt->cl_stats is supposed to point to a statically allocated structure
>   
that is not true for the callback. look at do_probe_callback().
> (in this case 'nfs_rpcstat'). While that can, in theory, disappear if
> the user removes the NFS module, in practice that is very unlikely. I
> therefore think you are rather seeing some sort of memory corruption
> issue that is affecting the rpc_client.
>   

> Are you seeing this with the 'devel' branch from my git tree, or does it
> only affect your patched kernel. If the latter, may we see your patches?
>
>   

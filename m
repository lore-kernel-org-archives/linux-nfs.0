From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: portmap -> map db entirely in filesystem
Date: Thu, 29 May 2008 17:03:05 -0400
Message-ID: <445DF5B1-1079-438F-8089-9A8C4AA64C38@oracle.com>
References: <273FE88A07F5D445824060902F7003440FD629@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Enrico Weigelt <weigelt-EU+a56NjgY8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:59158 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbYE2VDW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2008 17:03:22 -0400
In-Reply-To: <273FE88A07F5D445824060902F7003440FD629-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> From: Enrico Weigelt [mailto:weigelt-EU+a56NjgY8@public.gmane.org]
> Sent: Monday, May 26, 2008 2:11 PM
> To: linux-nfs@vger.kernel.org
> Subject: Re: portmap -> map db entirely in filesystem
>
> * Chuck Lever <chuck.lever@oracle.com> wrote:
>> Well, first of all we are moving away from portmap these days since  
>> we
>> need to support IPv6.  We currently have an rpcbind implementation
>> that is ported from Solaris.
>
> I had a look at it a few days ago ... far too fat for me.
> If you really need Ipv6 support on portmap, let's just do it.
> Shouldn't be such a big job.

Like everything else in the modern NFS world, the new versions of the  
rpcbind protocol are more complex than the simpler older versions.

Many common implementations of rpcbind clients require the server to  
support at least rpcbindv3 before they will connect to an RPC service  
via AF_INET6.

So if we want a reasonable level of interoperability, you will need to  
implement at least rpcbindv3 support, which means it has to support TI- 
RPC and netconfig and all the rest.  You will end up re-implementing  
rpcbind in portmapper... so what exactly is the point?

>> But it would make sense to keep the rpcbind service completely in
>> the kernel.
>
> And move more bloat into the kernel ? Isn't it big enough yet ?

We have some user space NFSD implementations, but the main Linux NFSD/ 
NLM implementation is kernel-based.  That's because even though it can  
be done in user space, there are some palpable advantages to having  
NFSD and NLM in the kernel.

My point is there are also advantages to putting rpcbind in the  
kernel, even though, yes, you can do it in user space adequately.

>> That way the kernel RPC services could register with the rpcbind
>> database directly, and we wouldn't have to worry about reregistering
>> running RPC services because of a daemon restart.
>
> Wouldn't it be easier to just fix the portmapper ?

How do you prevent a user space daemon from being killed during OOM or  
crashing because of a bug or a sysadmin's finger slip?

rpcbind already has warm-start built in, by the way.  Again, we  
already have something that does the job, so I'm hard pressed to  
understand why we should bother with fixing portmapper.

>> There's no need to involve permanent storage for rpcbind.
>
> There is even no need to have it running all the time, start on
> demand is enough for some workloads (eg. in embedded/smalldev
> environments)

Exactly... a kernel-provided service would not take any resources  
(other than a little memory) unless called.  It would not even require  
an init script or xinet.d configuration to start it.  So a kernel  
rpcbind service would be more ideal for an embedded deployment that  
either daemon in user space.

Note that portmapper today does not support warm-start, it stores  
state in memory only.  So you would have to hack it to store RPC  
service registrations in a file somewhere if you wanted a start-on- 
demand service based on portmapper.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Thu, 12 Feb 2009 14:35:10 -0500
Message-ID: <03CEE6BB-D39D-47A5-BB6C-2FB3E206142F@oracle.com>
References: <20090211112318.GA29133@janus> <20090211203555.GC27686@fieldses.org> <20090211203703.GA9662@janus> <20090211203948.GD27686@fieldses.org> <20090212142830.GA28107@janus> <1234451789.7190.38.camel@heimdal.trondhjem.org> <20090212153634.GB28107@janus> <1234462647.7190.53.camel@heimdal.trondhjem.org> <20090212182943.GA1945@janus> <1234465837.7190.62.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26076 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758159AbZBLTfi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2009 14:35:38 -0500
In-Reply-To: <1234465837.7190.62.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 12, 2009, at 2:10 PM, Trond Myklebust wrote:
> On Thu, 2009-02-12 at 19:29 +0100, Frank van Maarseveen wrote:
>> On Thu, Feb 12, 2009 at 01:17:27PM -0500, Trond Myklebust wrote:
>>> On Thu, 2009-02-12 at 16:36 +0100, Frank van Maarseveen wrote:
>>>> A little theorizing:
>>>> If the unlock of a yet unrecovered lock has failed up to that  
>>>> point then
>>>> the client sure must remember the lock somehow. That might  
>>>> explain the
>>>> secondary error when a conflicting lock is granted by the server.
>>>
>>> Sorry, but that doesn't hold water. The client will release the VFS
>>> 'mirror' of the lock before it attempts to unlock. Otherwise, you  
>>> could
>>> have some nasty races between the unlock thread and the recovery
>>> thread...
>>> Besides, the granted callback handler on the client only checks  
>>> the list
>>> of blocked locks for a match.
>>
>> ok, then we have more than one NLM bug to resolve.
>>
>>>
>>> Oh, bugger, I know what this is... It's the same thing that  
>>> happened to
>>> the NFSv4 callback server. If you compile with CONFIG_IPV6 or
>>> CONFIG_IPV6_MODULE enabled, and also set  
>>> CONFIG_SUNRPC_REGISTER_V4, then
>>> the NLM server will listen on an IPv6 socket, and so the RPC request
>>> come in with their IPv4 address mapped into the IPv6 namespace.
>>
>> Nope:
>>
>> 	$ zgrep IPV6 /proc/config.gz
>> 	# CONFIG_IPV6 is not set
>> 	$ zgrep SUNRPC /proc/config.gz
>> 	CONFIG_SUNRPC=y
>> 	CONFIG_SUNRPC_GSS=y
>> 	# CONFIG_SUNRPC_BIND34 is not set
>
> Sorry, yes... 2.6.27.x should be OK. The lockd v4mapped addresses  
> bug is
> specific to 2.6.29. Chuck, are you planning on fixing this before
> 2.6.29-final comes out?

I wasn't sure exactly where the compared addresses came from.  I had  
assumed that they all came through the listener, so we wouldn't need  
this kind of translation.  It shouldn't be difficult to map addresses  
passed in via nlmclnt_init() to AF_INET6.

But this is the kind of thing that makes "falling back" to an AF_INET  
listener a little challenging.  We will have to record what flavor the  
listener is and do a translation depending on what listener family was  
actually created.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

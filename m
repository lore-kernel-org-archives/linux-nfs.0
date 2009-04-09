From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind
	instead of getaddrinfo
Date: Thu, 9 Apr 2009 12:19:47 -0400
Message-ID: <20090409161947.GG32589@fieldses.org>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com> <1239117946-7535-4-git-send-email-jlayton@redhat.com> <41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com> <49db7f0d.85c2f10a.5025.ffffb257@mx.google.com> <20090407131151.69203e5e@tleilax.poochiereds.net> <49dbacf3.14025a0a.5898.ffffbaa2@mx.google.com> <20090407231406.GC28733@fieldses.org> <DDF2F477-FC1E-45D0-A9F6-A4D690F2256B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Talpey <tmtalpey@gmail.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org, Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34600 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548AbZDIQTt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2009 12:19:49 -0400
In-Reply-To: <DDF2F477-FC1E-45D0-A9F6-A4D690F2256B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 08, 2009 at 03:32:43PM -0400, Chuck Lever wrote:
> On Apr 7, 2009, at 7:14 PM, J. Bruce Fields wrote:
>> On Tue, Apr 07, 2009 at 03:43:39PM -0400, Tom Talpey wrote:
>>> At 01:11 PM 4/7/2009, Jeff Layton wrote:
>>>> On Tue, 07 Apr 2009 12:27:49 -0400
>>>> Tom Talpey <tmtalpey@gmail.com> wrote:
>>>>
>>>>> At 12:02 PM 4/7/2009, Chuck Lever wrote:
>>>>>>
>>>>>> On Apr 7, 2009, at 11:25 AM, Jeff Layton wrote:
>>>>>>> +	/* Use standard NFS port for NFSv4 */
>>>>>>> +	if (program == 100003 && version == 4) {
>>>>>>> +		port = 2049;
>>>>>>> +		goto set_port;
>>>>>>> +	}
>>>>>>
>>>>>> I think this patch set looks pretty reasonable.  Here's my one
>>>>>> remaining quibble.
>>>>>>
>>>>>> You can specify "port=" for nfs4 mounts, in which case we want  
>>>>>> to use
>>>>>> that value here, too, I think.  It would be simpler overall if the
>>>>>
>>>>> *Must* use a port= specification. The 2049 definition is only  
>>>>> true for
>>>>> NFSv4/TCP, as a counterexample the NFSv4/RDMA IANA binding is
>>>>> port 20049. So slamming the port to 2049 would break NFSv4/RDMA.
>>>>>
>>>>
>>>> rpc.gssd doesn't seem to be rdma-enabled at this point. It only  
>>>> seems
>>>> to handle "tcp" and "udp" in the existing code.
>>>
>>> Fair enough. But hardwiring 2049 for all transports is going to very
>>> problematic. What's the motivation for bypassing the rpcbind query
>>> altogether (that "goto set_port" skips over it)? Why not at least
>>> try the query first?
>>
>> We're just doing the rpcsec_gss context initiation.  Normally that  
>> would
>> be done over an already-established connection--the only reason we  
>> don't
>> is because our implementation is split between the client and the
>> server, so it's more convenient for us to set up a new connection in
>> rpc.gssd.  But we really shouldn't be doing an entirely new rpcbind
>> call--somebody else already did that for us and is telling us the
>> results through the rpc_pipefs info file.
>
> This is an entirely separate RPC transport being set up for gssd, and  
> there seem to be a lot of cases where the kernel (rightfully) passes a  
> zero for the port number.  In fact, even if the kernel did the rpcbind  
> for gssd at some point in the past, gss doesn't have any information  
> about how old that information is.
>
> So, yes, we do want an rpcbind here.

As long as we don't do it in the NFSv4 case, I'm happy.

My only point is that the above argument is putting the cart before the
horse a bit: the fact that there's an entirely separate RPC transport
being set up is entirely an artifact of our implementation, and if it
became a problem at some point, then we'd need to consider modifying the
kernel/gssd interface to eliminate the need for that.

--b.

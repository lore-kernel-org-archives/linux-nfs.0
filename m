From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] SUNRPC: RPC client's TCP transport ignores errors during connect
Date: Tue, 8 Apr 2008 15:35:38 -0400
Message-ID: <E12D75B9-D74B-45F0-97A3-5209F7C3539F@oracle.com>
References: <20080408173602.21776.60671.stgit@manray.1015granger.net> <1207677350.11699.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:24744 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183AbYDHTgI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2008 15:36:08 -0400
In-Reply-To: <1207677350.11699.9.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 8, 2008, at 1:55 PM, Trond Myklebust wrote:
> On Tue, 2008-04-08 at 13:38 -0400, Chuck Lever wrote:
>> Commits 66af1e55 through 663b8858 recently changed how
>> xs_tcp_state_change() awakens RPC tasks in order to address problems
>> with disconnection of TCP sockets that were already connected.
>>
>> The generic function xprt_connect_status() is invoked during a  
>> transport
>> connection operation by this wake-up.  It expects a specific error  
>> value
>> describing the connection failure, but currently always gets  
>> ENOTCONN.
>
> Does it? AFAICS, the only errors that it cares about are ETIMEDOUT,
> ENOTCONN, ECONNRESET, and ECONNREFUSED, and the only effect is change
> the dprintk() message.
>
> OTOH, call_connect_status() will cause the task to exit with an EIO if
> ever it gets sent an ECONNRESET or ECONNREFUSED.

Well, OK... but why keep the extra switch arms in xprt_connect_status  
if transports and the generic logic don't use those error codes?  It  
serves only to confuse.

Last week, you claimed:

 > The client currently doesn't retry in the case of a connection
 > failing for a soft RPC request.

In fact, it does retry a connection attempt on soft RPC requests  
until a *major* timeout occurs.

So is the actual bug in call_timeout?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

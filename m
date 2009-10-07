From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/7] SUNRPC: Allow RPCs to fail quickly if the server is unreachable
Date: Wed, 7 Oct 2009 18:50:00 -0400
Message-ID: <1061150C-52F3-45EE-8451-845B31357C9C@oracle.com>
References: <20091007215019.1844.17414.stgit@matisse.1015granger.net> <20091007220232.1844.62559.stgit@matisse.1015granger.net> <1254954039.7045.31.camel@heimdal.trondhjem.org> <680A4087-D9CB-40D6-8C7E-239E7EB8CC21@oracle.com> <1254955658.7045.46.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:20839 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712AbZJGWvl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2009 18:51:41 -0400
In-Reply-To: <1254955658.7045.46.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 7, 2009, at 6:47 PM, Trond Myklebust wrote:

> On Wed, 2009-10-07 at 18:34 -0400, Chuck Lever wrote:
>> On Oct 7, 2009, at 6:20 PM, Trond Myklebust wrote:
>>> On Wed, 2009-10-07 at 18:02 -0400, Chuck Lever wrote:
>>>> 		 * Special cases: if we've been waiting on the
>>>> 		 * socket's write_space() callback, or if the
>>>> @@ -1198,6 +1200,11 @@ call_transmit_status(struct rpc_task *task)
>>>> 	case -EHOSTUNREACH:
>>>> 	case -ENETUNREACH:
>>>> 	case -EPIPE:
>>>> +		if (RPC_IS_SOFTCONN(task)) {
>>>> +			xprt_end_transmit(task);
>>>> +			rpc_exit(task, task->tk_status);
>>>> +			break;
>>>> +		}
>>>
>>> This doesn't look robust. The EPIPE error may mean that the socket  
>>> got
>>> closed as a result of server action, or a previous RPC call. Don't
>>> forget that we might want to reuse SOFTCONN for NFSv4.1 session
>>> binding
>>> semantics.
>>
>> EPIPE can easily be handled in a separate case that doesn't have soft
>> connect.
>
> It directly affects rpcbind when you cache the rpc client, as you do  
> in
> later patches. If one RPC call fails with EPIPE, then so will all the
> subsequent ones...
>
> IOW: I'd suggest moving EPIPE _below_ your above SOFTCONN special  
> case.
> You might want to do the same for ENOTCONN...

Already done.  :-)

>
> -- 
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




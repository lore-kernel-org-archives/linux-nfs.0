From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] SUNRPC: RPC client's TCP transport ignores errors during connect
Date: Tue, 8 Apr 2008 17:02:08 -0400
Message-ID: <3EA01F3B-34B8-42C3-86DD-1D56D2B5E0DB@oracle.com>
References: <20080408173602.21776.60671.stgit@manray.1015granger.net> <1207677350.11699.9.camel@heimdal.trondhjem.org> <E12D75B9-D74B-45F0-97A3-5209F7C3539F@oracle.com> <1207686073.11699.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:52248 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334AbYDHVCh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2008 17:02:37 -0400
In-Reply-To: <1207686073.11699.32.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 8, 2008, at 4:21 PM, Trond Myklebust wrote:
> On Tue, 2008-04-08 at 15:35 -0400, Chuck Lever wrote:
>> Last week, you claimed:
>>
>>> The client currently doesn't retry in the case of a connection
>>> failing for a soft RPC request.
>>
>> In fact, it does retry a connection attempt on soft RPC requests
>> until a *major* timeout occurs.
>
> You're right. I forgot that we changed that.
>
>> So is the actual bug in call_timeout?
>
> I'm confused. What should call_timeout be doing differently?

If the current soft connect retry behavior is what is desired (and  
thinking on it, it is safer than failing the requests outright) then  
I agree there is no bug.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

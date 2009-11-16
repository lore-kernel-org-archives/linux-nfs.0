From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] SUNRPC: Address buffer overrun in rpc_uaddr2sockaddr()
Date: Mon, 16 Nov 2009 11:39:18 -0500
Message-ID: <1C36AE9F-49E3-4F45-AF56-D0C6C87F72F4@oracle.com>
References: <20091113154934.1828.46527.stgit@matisse.1015granger.net> <1258154588.2981.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:43356 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbZKPQjd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Nov 2009 11:39:33 -0500
In-Reply-To: <1258154588.2981.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 13, 2009, at 6:23 PM, Trond Myklebust wrote:
> On Fri, 2009-11-13 at 10:52 -0500, Chuck Lever wrote:
>> Hi Trond-
>>
>> I haven't heard from the reporter, but since 2.6.32-final is  
>> imminent,
>> would you consider this for 2.6.32-rc ?  As far as I can tell, this
>> issue was introduced in 2.6.32-rc and is not applicable for stable.
>
> I've put it in the 'bugfixes' and 'linux-next' git trees. We'll give  
> it
> a few days testing there before I ask Linus to pull.

Excellent, thanks.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17186 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755520Ab0DEPvW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Apr 2010 11:51:22 -0400
Message-ID: <4BBA069E.8080801@oracle.com>
Date: Mon, 05 Apr 2010 11:49:50 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Tom Tucker <tom@ogc.us>, Steve Wise <swise@opengridcomputing.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH] svcrdma: RDMA support not yet compatible with RPC6
References: <4BB74241.4060308@ogc.us> <4BB9F9D0.1040203@oracle.com> <20100405154850.GG16370@fieldses.org>
In-Reply-To: <20100405154850.GG16370@fieldses.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/05/2010 11:48 AM, J. Bruce Fields wrote:
> On Mon, Apr 05, 2010 at 10:55:12AM -0400, Chuck Lever wrote:
>> On 04/03/2010 09:27 AM, Tom Tucker wrote:
>>> RPC6 requires that it be possible to create endpoints that listen
>>> exclusively for IPv4 or IPv6 connection requests. This is not currently
>>> supported by the RDMA API.
>>>
>>> Signed-off-by: Tom Tucker<tom@opengridcomputing.com>
>>> Tested-by: Steve Wise<swise@opengridcomputing.com>
>>
>> Reviewed-by: Chuck Lever<chuck.lever@oracle.com>
>
> Thanks to all.  I take it the problem began with 37498292a "NFSD: Create
> PF_INET6 listener in write_ports"?

I don't know exactly, but that would make sense.

-- 
chuck[dot]lever[at]oracle[dot]com

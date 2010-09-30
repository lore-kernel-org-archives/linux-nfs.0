Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3363 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932083Ab0I3Pek (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 11:34:40 -0400
Message-ID: <4CA4ADEA.2010700@parallels.com>
Date: Thu, 30 Sep 2010 19:34:02 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 0/9] sunrpc: Create sockets in namespaces
References: <4CA32AB4.2090808@parallels.com> <20100929214527.GC26180@fieldses.org> <0678928F-3DE0-4AB9-8CD9-7BDA3A362A20@oracle.com> <4CA42437.3090102@parallels.com> <F11D1388-D48E-48F5-9711-79960B397FBF@oracle.com>
In-Reply-To: <F11D1388-D48E-48F5-9711-79960B397FBF@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/30/2010 07:16 PM, Chuck Lever wrote:
> 
> On Sep 30, 2010, at 1:46 AM, Pavel Emelyanov wrote:
> 
>>>> Shall I commit this to my for-2.6.37 tree?  Objections?
>>>
>>> I think it looks OK.
>>>
>>> But I was wondering if there were any other changes needed for the RDMA 
>>> transport capability, or had we decided that would happen at a latter point, 
>>> or that changes are entirely unneeded
>>
>> We definitely need more changes in the RDMA transport, but I would like to
>> have it done later (unless someone other than me starts doing it earlier ;) ).
> 
> OK, thanks for clearing that up.  It makes sense to keep the scope of this socket
> patch set narrow, but I don't want the RDMA pieces to get lost.  The more we let
> the RDMA and socket transport capabilities differ, the harder it will be to support
> RDMA in the long run.

OK, but I may have problems with the IB hardware. If you can advise me the
way to test the RDMA without it, it would be very helpful.

> Anyway, Bruce, I have no objection to the latest version of this socket patch set, fwiw.
> 
>>> (are namespaces already supported in the IB stack)?
>>
>> Nope. And this makes RDMA netnsization even more harder :(
> 


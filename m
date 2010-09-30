Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:21864 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756646Ab0I3PQj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 11:16:39 -0400
Subject: Re: [PATCH v3 0/9] sunrpc: Create sockets in namespaces
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CA42437.3090102@parallels.com>
Date: Thu, 30 Sep 2010 11:16:03 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Message-Id: <F11D1388-D48E-48F5-9711-79960B397FBF@oracle.com>
References: <4CA32AB4.2090808@parallels.com> <20100929214527.GC26180@fieldses.org> <0678928F-3DE0-4AB9-8CD9-7BDA3A362A20@oracle.com> <4CA42437.3090102@parallels.com>
To: Pavel Emelyanov <xemul@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 30, 2010, at 1:46 AM, Pavel Emelyanov wrote:

>>> Shall I commit this to my for-2.6.37 tree?  Objections?
>> 
>> I think it looks OK.
>> 
>> But I was wondering if there were any other changes needed for the RDMA 
>> transport capability, or had we decided that would happen at a latter point, 
>> or that changes are entirely unneeded
> 
> We definitely need more changes in the RDMA transport, but I would like to
> have it done later (unless someone other than me starts doing it earlier ;) ).

OK, thanks for clearing that up.  It makes sense to keep the scope of this socket patch set narrow, but I don't want the RDMA pieces to get lost.  The more we let the RDMA and socket transport capabilities differ, the harder it will be to support RDMA in the long run.

Anyway, Bruce, I have no objection to the latest version of this socket patch set, fwiw.

>> (are namespaces already supported in the IB stack)?
> 
> Nope. And this makes RDMA netnsization even more harder :(

-- 
chuck[dot]lever[at]oracle[dot]com





Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:51133 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753205Ab0I2Vts convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 17:49:48 -0400
Subject: Re: [PATCH v3 0/9] sunrpc: Create sockets in namespaces
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100929214527.GC26180@fieldses.org>
Date: Wed, 29 Sep 2010 17:49:31 -0400
Cc: Pavel Emelyanov <xemul@parallels.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Message-Id: <0678928F-3DE0-4AB9-8CD9-7BDA3A362A20@oracle.com>
References: <4CA32AB4.2090808@parallels.com> <20100929214527.GC26180@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 29, 2010, at 5:45 PM, J. Bruce Fields wrote:

> On Wed, Sep 29, 2010 at 04:01:56PM +0400, Pavel Emelyanov wrote:
>> v3 changes:
>> Moved the generic xprt alloc/free code to xprt.c.
>> Got David's ack on the 8th patch :)
>> 
>> v2 changes:
>> Fixed comments from Chuck and Trond.
>> Added one patch, that factors out rpc_xprt allocation as well.
>> 
>> v1:
>> This set implements pulling the net * argument down to the existing
>> sock_create_kern calls in the sunrpc layer and creating the sockets
>> in the given net.
> 
> Shall I commit this to my for-2.6.37 tree?  Objections?

I think it looks OK.

But I was wondering if there were any other changes needed for the RDMA transport capability, or had we decided that would happen at a latter point, or that changes are entirely unneeded (are namespaces already supported in the IB stack)?

-- 
chuck[dot]lever[at]oracle[dot]com





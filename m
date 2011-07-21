Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7278 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751425Ab1GUHu7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2011 03:50:59 -0400
Message-ID: <4E27DA40.7040207@parallels.com>
Date: Thu, 21 Jul 2011 11:50:24 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 0/9] sunrpc: Create sockets in namespaces
References: <4CA32AB4.2090808@parallels.com> <20110720211040.GC27871@fieldses.org>
In-Reply-To: <20110720211040.GC27871@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/21/2011 01:10 AM, J. Bruce Fields wrote:
> Just curious--is there still work left on nfs and rpc containerization?
> And what's left to do there?

Yes, there's still more work todo. Unfortunately it is stalled now, but
I plan to return back to it soon. Sorry about it.

> --b.
> 
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
>>
>> Thanks,
>> Pavel
> .
> 


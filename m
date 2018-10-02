Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:41524 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726118AbeJBVSG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Oct 2018 17:18:06 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 4/4] svcrdma: Increase the default connection credit
 limit
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <a31d401b-bf12-fd44-5e0c-540b0cd4a9ba@grimberg.me>
Date: Tue, 2 Oct 2018 10:34:11 -0400
Cc: Bruce Fields <bfields@fieldses.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5F196CB9-ABF7-4660-A4B1-E536F564A717@oracle.com>
References: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
 <20181001181611.2305.48362.stgit@klimt.1015granger.net>
 <a31d401b-bf12-fd44-5e0c-540b0cd4a9ba@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Oct 1, 2018, at 6:33 PM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>> Reduce queuing on clients by allowing more credits by default.
>> 64 is the default NFSv4.1 slot table size on Linux clients. This
>> size prevents the credit limit from putting RPC requests to sleep
>> again after they have already slept waiting for a session slot.
> 
> Would it make sense to have it in a shared header with the client?
> 
> Otherwise,
> Reviewed-by: Sagi Grimberg <sagi@grimberg.me>

Thanks for the review!

Typically all the server-side stuff is kept in separate headers,
I guess that's historical and matches the generic layer (..) .


--
Chuck Lever

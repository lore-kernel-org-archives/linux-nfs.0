Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:33948 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750742AbdIGPIl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Sep 2017 11:08:41 -0400
Date: Thu, 7 Sep 2017 09:08:29 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Tom Talpey <tom@talpey.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Sagi Grimberg <sagi@grimberg.me>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
Message-ID: <20170907150829.GA20644@obsidianresearch.com>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
 <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me>
 <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com>
 <6dcdcc25-2613-cdb5-1db2-6c944f05242b@grimberg.me>
 <4E2E5580-69A5-4C3B-9FCA-E61AE2042E6B@oracle.com>
 <9059315f-1985-042e-a59f-26a66fbece3e@grimberg.me>
 <5B2F42B8-2CBD-43F4-BBAD-71EDD4F871FB@oracle.com>
 <20170906193946.GC18461@obsidianresearch.com>
 <f2cb453d-a59f-de64-7a42-09e075562895@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <f2cb453d-a59f-de64-7a42-09e075562895@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 07, 2017 at 09:17:16AM -0400, Tom Talpey wrote:

> >Why is waiting for the send completion so fundamentally different from
> >waiting for the remote RPC reply?
> >
> >I would say that 99% of time the send completion and RPC reply
> >completion will occure approximately concurrently.
> 
> Absolutely not. The RPC reply requires upper layer processing at
> the server, which involves work requests, context switches, file

I should have said '99% of the time the SEND will occure approximately
concurrently or sooner'

Jason

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:36830 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752101AbeENUhJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2018 16:37:09 -0400
Received: by mail-wr0-f172.google.com with SMTP id p4-v6so13719310wrh.3
        for <linux-nfs@vger.kernel.org>; Mon, 14 May 2018 13:37:08 -0700 (PDT)
Date: Mon, 14 May 2018 14:37:03 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 01/19] xprtrdma: Add proper SPDX tags for
 NetApp-contributed source
Message-ID: <20180514203703.GK21531@ziepe.ca>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
 <20180504193432.31688.65935.stgit@manet.1015granger.net>
 <4da36188-17d2-7b68-2974-80402c96359c@Netapp.com>
 <AD3908D5-D04C-4CDB-8ABD-14AB62984A2B@oracle.com>
 <60fdeb9b-f11b-9e29-2609-2f3da2a57d20@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <60fdeb9b-f11b-9e29-2609-2f3da2a57d20@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 07, 2018 at 10:28:13AM -0400, Anna Schumaker wrote:

> > The tags I've proposed are consistent with other usage:
> > 
> > -> .c files use // ... comments
> > -> .h files use /* ... */ comments
> > -> Makefiles use # comments
> > 
> > There were no complaints from checkpatch.pl about the
> > comment style in my patch.
> 
> Ah, okay.  It's probably best to go with how everybody else uses it
> (although I still wonder why they use different styles for .c and .h
> files).  I'll take your patch the way it is now.

It is a mysterious thing, but

 Documentation/process/license-rules.rst

Explains what to do.. Looks like this patch is OK

Jason

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa07-02.prod.phx3.secureserver.net ([173.201.192.231]:56582
        "EHLO p3plsmtpa07-02.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752943AbdIFBgn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Sep 2017 21:36:43 -0400
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
To: Chuck Lever <chuck.lever@oracle.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Sagi Grimberg <sagi@grimberg.me>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
 <20170905200608.GA4055@obsidianresearch.com>
 <0D960F54-0BC7-4A5A-8001-0391673892DF@oracle.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <bdc2a166-d5d9-2919-9abb-fa05f7ea9f84@talpey.com>
Date: Tue, 5 Sep 2017 21:28:52 -0400
MIME-Version: 1.0
In-Reply-To: <0D960F54-0BC7-4A5A-8001-0391673892DF@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/5/2017 5:22 PM, Chuck Lever wrote:
> I think it does bear mentioning that, given this diagnosis, it is
> still safe to remove the ib_post_send counting mechanism in 5/5,
> which has been in xprtrdma for as long as I can recall, and has

2007. :-)

> been effective (with a few minor adjustments) at preventing SQ
> overflow.
> 
> I'm not able to test this change with every HCA the Linux kernel
> currently supports, unfortunately. The best I can do is offer a
> "proof of correctness" and hope that vendors will jump on this
> and try it out.

Someday, a proper set of verbs test cases? Alas.

Tom.

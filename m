Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:54919 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754080AbdIEWDc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Sep 2017 18:03:32 -0400
Date: Tue, 5 Sep 2017 16:03:25 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Sagi Grimberg <sagi@grimberg.me>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
Message-ID: <20170905220325.GA10835@obsidianresearch.com>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
 <20170905200608.GA4055@obsidianresearch.com>
 <0D960F54-0BC7-4A5A-8001-0391673892DF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0D960F54-0BC7-4A5A-8001-0391673892DF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 05, 2017 at 05:22:04PM -0400, Chuck Lever wrote:
> 
> > On Sep 5, 2017, at 4:06 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
> > 
> > On Tue, Sep 05, 2017 at 01:00:10PM -0400, Chuck Lever wrote:
> > 
> >> - Send completions are batched to reduce interrupts, but still
> >>  provide a periodic heartbeat signal for SQ housekeeping
> > 
> > I would scrub this commentary, it is very misleading.
> > 
> > The idea of a periodic completion does not match how verbs works at
> > all, it was an incomplete root cause analysis from a HCA that uses
> > different rules for freeing space in the SQ.
> 
> I think it does bear mentioning that, given this diagnosis, it is
> still safe to remove the ib_post_send counting mechanism in 5/5,
> which has been in xprtrdma for as long as I can recall, and has
> been effective (with a few minor adjustments) at preventing SQ
> overflow.

Sure, but lets just talk about it in the context of ensuing the SQ
does not go full, and not some nebulous idea of heartbeat.

The new approach directly prevents overflow, and the past failings in
NFS all boiled down to stuffing SQEs into a full SQ, as some NICs do
not 'empty' the SQ until the CQ is generated.

> I'm not able to test this change with every HCA the Linux kernel
> currently supports, unfortunately. The best I can do is offer a
> "proof of correctness" and hope that vendors will jump on this
> and try it out.

Assuming it is implemented properly in NFS, any HCA that fails with
this is broken by definition.. A HCA must work correctly if the SQ is
full, and all but the last entry are unsignaled.

Jason

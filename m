Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:45083 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751415AbdJJRTX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Oct 2017 13:19:23 -0400
Date: Tue, 10 Oct 2017 10:19:19 -0700
From: "tj@kernel.org" <tj@kernel.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "lorenzo.pieralisi@arm.com" <lorenzo.pieralisi@arm.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
Subject: Re: net/sunrpc: v4.14-rc4 lockdep warning
Message-ID: <20171010171919.GO3301751@devbig577.frc2.facebook.com>
References: <20171009181738.GA30680@red-moon>
 <1507573931.3516.3.camel@primarydata.com>
 <20171010140336.GI3301751@devbig577.frc2.facebook.com>
 <1507654135.4442.4.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1507654135.4442.4.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Tue, Oct 10, 2017 at 04:48:57PM +0000, Trond Myklebust wrote:
> Thanks for the explanation. What I'm not really understanding here
> though, is how the work item could be queued at all. We have a
> wait_on_bit_lock() in xprt_destroy() that should mean the xprt-
> >task_cleanup work item has completed running, and that it cannot be
> requeued.
> 
> Is there a possibility that the flush_queue() might be triggered
> despite the work item not being queued?

Yeah, for sure.  The lockdep annotations don't distinguish those
cases and assume the worst case.

Thanks.

-- 
tejun

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:42609 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753286AbdIEUGO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Sep 2017 16:06:14 -0400
Date: Tue, 5 Sep 2017 14:06:08 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: sagi@grimberg.me, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
Message-ID: <20170905200608.GA4055@obsidianresearch.com>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170905164347.11106.27140.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 05, 2017 at 01:00:10PM -0400, Chuck Lever wrote:

> - Send completions are batched to reduce interrupts, but still
>   provide a periodic heartbeat signal for SQ housekeeping

I would scrub this commentary, it is very misleading.

The idea of a periodic completion does not match how verbs works at
all, it was an incomplete root cause analysis from a HCA that uses
different rules for freeing space in the SQ.

Instead, I would say this series creates strong SQ accounting and
properly guarentees the SQ can never overflow by only releasing SQ's
back into the pool when the HCA has confirmed they are completed via a
CQ.

Jason

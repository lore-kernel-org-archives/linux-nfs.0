Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:38184 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753190AbdIFLyY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Sep 2017 07:54:24 -0400
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
To: Chuck Lever <chuck.lever@oracle.com>,
        jgunthorpe@obsidianresearch.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me>
Date: Wed, 6 Sep 2017 14:54:20 +0300
MIME-Version: 1.0
In-Reply-To: <20170905164347.11106.27140.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Hi Jason, Sagi-

Hey Chuck,

> As we discussed a few weeks ago, this patch series implements the
> following:
> 
> - Send SGEs are now managed via lock-less, wait-free circular queues
> - Send SGEs referring to page cache pages are DMA unmapped during
>    Send completion
> - Send completions are batched to reduce interrupts, but still
>    provide a periodic heartbeat signal for SQ housekeeping
> - The circular queue prevents Send Queue overflow
> 
> The purpose of this change is to address the issue Sagi reported
> where the HCA continues to retry a delayed Send request _after_ RPC
> completion, resulting in a DMA error.

Question, what happens in direct-io for example? Can a mapped buffer be
reclaimed/free'd before the send completion arrives?

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f52.google.com ([209.85.160.52]:61423 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200Ab3AGRrY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2013 12:47:24 -0500
Received: by mail-pb0-f52.google.com with SMTP id ro2so10676527pbb.11
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jan 2013 09:47:23 -0800 (PST)
Date: Mon, 7 Jan 2013 09:47:20 -0800
From: Tejun Heo <tj@kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>,
        Bruce Fields <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] SUNRPC: Ensure that we free the rpc_task after
 cleanups are done
Message-ID: <20130107174720.GN3926@htj.dyndns.org>
References: <0EC8763B847DB24D9ADF5EBD9CD7B419125A16A9@SACEXCMBX02-PRD.hq.netapp.com>
 <1357323302-12944-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1357323302-12944-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 04, 2013 at 01:15:00PM -0500, Trond Myklebust wrote:
> This patch ensures that we free the rpc_task after the cleanup callbacks
> are done in order to avoid a deadlock problem that can be triggered if
> the callback needs to wait for another workqueue item to complete.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Weston Andros Adamson <dros@netapp.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Bruce Fields <bfields@fieldses.org>
> Cc: stable@vger.kernel.org

Acked-by: Tejun Heo <tj@kernel.org>

> + * Tejun Heo states:
> + * "Workqueue currently considers two work items to be the same if they're
> + * on the same address and won't execute them concurrently - ie. it
> + * makes a work item which is queued again while being executed wait
> + * for the previous execution to complete.
> + *
> + * If a work function frees the work item, and then waits for an event
> + * which should be performed by another work item and *that* work item
> + * recycles the freed work item, it can create a false dependency loop.
> + * There really is no reliable way to detect this short of verifying
> + * every memory free."

I will document it in Documentation/workqueue.txt.

Thanks!

-- 
tejun

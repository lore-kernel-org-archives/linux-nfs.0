Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44102 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792Ab1GFXpd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2011 19:45:33 -0400
Subject: Re: [RFC] sunrpc:  Fix race between work-queue and
 rpc_killall_tasks.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: greearb@candelatech.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 06 Jul 2011 19:45:32 -0400
In-Reply-To: <1309992581-25199-1-git-send-email-greearb@candelatech.com>
References: <1309992581-25199-1-git-send-email-greearb@candelatech.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1309995932.5447.6.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-07-06 at 15:49 -0700, greearb@candelatech.com wrote: 
> From: Ben Greear <greearb@candelatech.com>
> 
> The rpc_killall_tasks logic is not locked against
> the work-queue thread, but it still directly modifies
> function pointers and data in the task objects.
> 
> This patch changes the killall-tasks logic to set a flag
> that tells the work-queue thread to terminate the task
> instead of directly calling the terminate logic.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> 
> NOTE:  This needs review, as I am still struggling to understand
> the rpc code, and it's quite possible this patch either doesn't
> fully fix the problem or actually causes other issues.  That said,
> my nfs stress test seems to run a bit more stable with this patch applied.

Yes, but I don't see why you are adding a new flag, nor do I see why we
want to keep checking for that flag in the rpc_execute() loop.
rpc_killall_tasks() is not a frequent operation that we want to optimise
for.

How about the following instead?

8<---------------------------------------------------------------------------------- 

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44667 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995Ab1KUUlr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 15:41:47 -0500
Date: Mon, 21 Nov 2011 12:41:41 -0800
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: rjw@sisk.pl, linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        john@calva.com, trond.myklebust@netapp.com
Subject: Re: [PATCH 1/2] sunrpc: make rpc_wait_bit_killable handle freeze
 events
Message-ID: <20111121204141.GD25776@google.com>
References: <1321897221-2278-1-git-send-email-jlayton@redhat.com>
 <1321897221-2278-2-git-send-email-jlayton@redhat.com>
 <20111121175644.GF15314@google.com>
 <20111121153615.7e876801@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111121153615.7e876801@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Jeff.

On Mon, Nov 21, 2011 at 03:36:15PM -0500, Jeff Layton wrote:
> I suppose you're suggesting something like this?
> 
> 	freezer_do_not_count();
> 	if (!try_to_freeze())
> 		schedule();
> 	freezer_count();

No,

	freezer_do_not_count();
	schedule();
	freezer_count();
	try_to_freeze();

freezer_count() may make %current eligible for freezing again, so it
has to check whether freezing condition is pending afterwards.

> The freezer is not really my forte', but I have to say that the whole
> do_not_count scheme seems "sketchy". Would we not be better off with
> something closer to the original method that I proposed, along with a
> new TASK_WAKEFREEZE state bit? Processes that are sleeping in
> uninterruptible sleep that are able to deal with freezer events could
> set that bit and fake_signal_wake_up could be changed to also wake
> processes with that bit set.

AFAICS, the above should be race-free w/ the pending freezer update.

  http://git.kernel.org/?p=linux/kernel/git/tj/misc.git;a=shortlog;h=refs/heads/pm-freezer

Thank you.

-- 
tejun

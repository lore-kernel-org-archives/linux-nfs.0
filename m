Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34674 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756AbbKIS1k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2015 13:27:40 -0500
Date: Mon, 9 Nov 2015 13:27:39 -0500
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Improving rpc.gssd's debugging
Message-ID: <20151109182739.GC8738@fieldses.org>
References: <1446920050-5968-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1446920050-5968-1-git-send-email-steved@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 07, 2015 at 01:14:07PM -0500, Steve Dickson wrote:
> Now that rpc.gssd is the critical path of every
> NFS mount, any favored mount, I thought I would
> take a crack at making the daemon a bit more 
> debuggable by making the logging more readable.
> 
> The first level of debugging (-v) will only log 
> errors and warnings that are not normally logged.
> I'm thinking this might be a good level to run
> at a customer's site.
> 
> I also thought about changing the majority of the 
> printerr(0) which always log to printerr(1)s. I 
> decided not to since I figured more info is 
> better.
> 
> Note, I didn't remove any of the messages, I just pushed
> them back to other debug levels. 
> 
> I trimmed down the second level of debugging (-vv) 
> by again moving them back to other levels. 
> 
> The third level (-vvv) is basically the same.
> 
> Using the fourth level (-vvvv) to enable all the logging
> that old level three did.
> 
> Thoughts/Comments... A waste of a good Saturday afternoon?? ;-) 

I haven't reviewed the patches, but those sound like reasonable things
to do to me.

--b.

> 
> Steve Dickson (3):
>   gssd: reworked first level of debugging
>   gssd: log all fatal errors
>   gssd: reworked second level of debugging
> 
>  utils/gssd/context_heimdal.c |  2 +-
>  utils/gssd/context_lucid.c   |  6 +++---
>  utils/gssd/gssd.c            | 14 +++++++-------
>  utils/gssd/gssd_proc.c       | 32 +++++++++++++-------------------
>  utils/gssd/krb5_util.c       | 28 ++++++++++++++++------------
>  5 files changed, 40 insertions(+), 42 deletions(-)
> 
> -- 
> 2.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

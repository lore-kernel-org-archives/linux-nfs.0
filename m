Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41704 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517Ab1KUUq1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 15:46:27 -0500
Date: Mon, 21 Nov 2011 12:46:20 -0800
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: rjw@sisk.pl, linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        john@calva.com, trond.myklebust@netapp.com
Subject: Re: [PATCH 1/2] sunrpc: make rpc_wait_bit_killable handle freeze
 events
Message-ID: <20111121204620.GF25776@google.com>
References: <1321897221-2278-1-git-send-email-jlayton@redhat.com>
 <1321897221-2278-2-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321897221-2278-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 21, 2011 at 12:40:20PM -0500, Jeff Layton wrote:
>  /*
> + * Freezer-friendly macro around schedule() in the kernel.
> + */
> +#define freezable_schedule()						\
> +({									\
> +	freezer_do_not_count();						\
> +	schedule();							\
> +	freezer_count();						\
> +})

So, yes, this seems correct to me but I'm not really sure about the
naming.  Given what freezable means for other interfaces, this is a
bit confusing to me but that could be because I know how each is
implemented.  Anyone with a better name?

Also, this definitely can use a lot more detailed comment.  What it's
supposed to do, how it's supposed to be used and so on.

Thank you.

-- 
tejun

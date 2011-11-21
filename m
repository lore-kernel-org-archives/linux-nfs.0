Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45037 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755302Ab1KUR4u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 12:56:50 -0500
Date: Mon, 21 Nov 2011 09:56:44 -0800
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: rjw@sisk.pl, linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        john@calva.com, trond.myklebust@netapp.com
Subject: Re: [PATCH 1/2] sunrpc: make rpc_wait_bit_killable handle freeze
 events
Message-ID: <20111121175644.GF15314@google.com>
References: <1321897221-2278-1-git-send-email-jlayton@redhat.com>
 <1321897221-2278-2-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321897221-2278-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 21, 2011 at 12:40:20PM -0500, Jeff Layton wrote:
> Allow the freezer to skip wait_on_bit_killable sleeps in the sunrpc
> layer. This should allow suspend and hibernate events to proceed, even
> when there are RPC's pending on the wire.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  include/linux/freezer.h |   12 ++++++++++++
>  net/sunrpc/sched.c      |    3 ++-
>  2 files changed, 14 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/freezer.h b/include/linux/freezer.h
> index a5386e3..8b60dd0 100644
> --- a/include/linux/freezer.h
> +++ b/include/linux/freezer.h
> @@ -135,6 +135,16 @@ static inline void set_freezable_with_signal(void)
>  }
>  
>  /*
> + * Freezer-friendly macro around schedule() in the kernel.
> + */
> +#define freezable_schedule()						\
> +({									\
> +	freezer_do_not_count();						\
> +	schedule();							\
> +	freezer_count();						\

Don't we want try_to_freeze() here?  If the freezer thought the task
was safe to skip, it better stay inside freezer until the freezing
condition is lifted.

Thanks.

-- 
tejun

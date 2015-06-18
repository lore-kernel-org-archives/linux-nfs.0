Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:36078 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbbFRQbA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 12:31:00 -0400
Received: by yhan67 with SMTP id n67so59956168yha.3
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 09:31:00 -0700 (PDT)
Date: Thu, 18 Jun 2015 12:30:54 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 06/11] pNFS/flexfiles: track when layout is first used
Message-ID: <20150618123054.0e53854c@tlielax.poochiereds.net>
In-Reply-To: <1434466052-10491-7-git-send-email-tao.peng@primarydata.com>
References: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
	<1434466052-10491-7-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 16 Jun 2015 22:47:27 +0800
Peng Tao <tao.peng@primarydata.com> wrote:

> So that we can report cumulative time since the beginning
> of statistics collection of the layout.
> 
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 10 +++++++---
>  fs/nfs/flexfilelayout/flexfilelayout.h |  1 +
>  2 files changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> index acbe677..42f79c6 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -453,9 +453,13 @@ nfs4_ff_layout_calc_completion_time(struct rpc_task *task)
>  }
>  
>  static void
> -nfs4_ff_layoutstat_start_io(struct nfs4_ff_layoutstat *layoutstat)
> +nfs4_ff_layoutstat_start_io(struct nfs4_ff_layout_mirror *mirror,
> +			    struct nfs4_ff_layoutstat *layoutstat)
>  {
> +	static const ktime_t notime = {0};
> +
>  	nfs4_ff_start_busy_timer(&layoutstat->busy_timer);
> +	cmpxchg(&mirror->start_time, notime, ktime_get());
>  }
>  
>  static void
> @@ -493,7 +497,7 @@ nfs4_ff_layout_stat_io_start_read(struct nfs4_ff_layout_mirror *mirror,
>  		__u64 requested)
>  {
>  	spin_lock(&mirror->lock);
> -	nfs4_ff_layoutstat_start_io(&mirror->read_stat);
> +	nfs4_ff_layoutstat_start_io(mirror, &mirror->read_stat);
>  	nfs4_ff_layout_stat_io_update_requested(&mirror->read_stat, requested);
>  	spin_unlock(&mirror->lock);
>  }
> @@ -516,7 +520,7 @@ nfs4_ff_layout_stat_io_start_write(struct nfs4_ff_layout_mirror *mirror,
>  		__u64 requested)
>  {
>  	spin_lock(&mirror->lock);
> -	nfs4_ff_layoutstat_start_io(&mirror->write_stat);
> +	nfs4_ff_layoutstat_start_io(mirror , &mirror->write_stat);

Whitespace nit -- extra space between "mirror" and the comma.

>  	nfs4_ff_layout_stat_io_update_requested(&mirror->write_stat, requested);
>  	spin_unlock(&mirror->lock);
>  }
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
> index f7493f7..0e7366f 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> @@ -74,6 +74,7 @@ struct nfs4_ff_layout_mirror {
>  	spinlock_t			lock;
>  	struct nfs4_ff_layoutstat	read_stat;
>  	struct nfs4_ff_layoutstat	write_stat;
> +	ktime_t				start_time;
>  };
>  
>  struct nfs4_ff_layout_segment {


-- 
Jeff Layton <jeff.layton@primarydata.com>

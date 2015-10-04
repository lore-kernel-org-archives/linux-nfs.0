Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34734 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbbJDNf6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Oct 2015 09:35:58 -0400
Received: by qkbi190 with SMTP id i190so40109587qkb.1
        for <linux-nfs@vger.kernel.org>; Sun, 04 Oct 2015 06:35:57 -0700 (PDT)
Date: Sun, 4 Oct 2015 09:35:53 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/4] fs: have flush_delayed_fput flush the workqueue
 job
Message-ID: <20151004093553.0ff25438@tlielax.poochiereds.net>
In-Reply-To: <1442493587-32499-2-git-send-email-jeff.layton@primarydata.com>
References: <1442493587-32499-1-git-send-email-jeff.layton@primarydata.com>
	<1442493587-32499-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Sep 2015 08:39:44 -0400
Jeff Layton <jlayton@poochiereds.net> wrote:

> I think there's a potential race in flush_delayed_fput. A kthread does
> an fput() and that file gets added to the list and the delayed work is
> scheduled. More than 1 jiffy passes, and the workqueue thread picks up
> the work and starts running it. Then the kthread calls
> flush_delayed_work.  It sees that the list is empty and returns
> immediately, even though the __fput for its file may not have run yet.
> 
> Close this by making flush_delayed_fput use flush_delayed_work instead,
> which should immediately schedule the work to run if it's not already,
> and block until the workqueue job completes.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/file_table.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 

It should be noted that the only current user of flush_delayed_fput()
can call it before the workqueue threads are ever started.

Looking at the code, I *think* this will still do the right thing --
block until those threads are started and then flush the work as usual,
but do let me know if I've misread it.

> diff --git a/fs/file_table.c b/fs/file_table.c
> index ad17e05ebf95..52cc6803c07a 100644
> --- a/fs/file_table.c
> +++ b/fs/file_table.c
> @@ -244,6 +244,8 @@ static void ____fput(struct callback_head *work)
>  	__fput(container_of(work, struct file, f_u.fu_rcuhead));
>  }
>  
> +static DECLARE_DELAYED_WORK(delayed_fput_work, delayed_fput);
> +
>  /*
>   * If kernel thread really needs to have the final fput() it has done
>   * to complete, call this.  The only user right now is the boot - we
> @@ -256,11 +258,9 @@ static void ____fput(struct callback_head *work)
>   */
>  void flush_delayed_fput(void)
>  {
> -	delayed_fput(NULL);
> +	flush_delayed_work(&delayed_fput_work);
>  }
>  
> -static DECLARE_DELAYED_WORK(delayed_fput_work, delayed_fput);
> -
>  void fput(struct file *file)
>  {
>  	if (atomic_long_dec_and_test(&file->f_count)) {


-- 
Jeff Layton <jlayton@poochiereds.net>

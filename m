Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f47.google.com ([209.85.160.47]:33702 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759259Ab3CZMQM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Mar 2013 08:16:12 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp2so4709274pbb.34
        for <linux-nfs@vger.kernel.org>; Tue, 26 Mar 2013 05:16:11 -0700 (PDT)
Date: Tue, 26 Mar 2013 20:15:01 +0800
From: Yanchuan Nian <ycnian@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: allow the v4.1 callback thread to freeze
Message-ID: <20130326121049.GB10546@localhost.localdomain>
References: <1364212797-26097-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
In-Reply-To: <1364212797-26097-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 25, 2013 at 07:59:57AM -0400, Jeff Layton wrote:
> The v4.1 callback thread has set_freezable() at the top, but it doesn't
> ever try to freeze within the loop. Have it call try_to_freeze() at the
> top of the loop. If a freeze event occurs, recheck kthread_should_stop()
> after thawing.
> 
> Reported-by: Yanchuan Nian <ycnian@gmail.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/callback.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 5088b57..cff089a 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -125,6 +125,9 @@ nfs41_callback_svc(void *vrqstp)
>  	set_freezable();
>  
>  	while (!kthread_should_stop()) {
> +		if (try_to_freeze())
> +			continue;
> +
>  		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_INTERRUPTIBLE);
>  		spin_lock_bh(&serv->sv_cb_lock);
>  		if (!list_empty(&serv->sv_cb_list)) {

Tested, and the client suspends successfully now.
> -- 
> 1.7.11.7

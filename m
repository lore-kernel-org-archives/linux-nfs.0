Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f48.google.com ([74.125.82.48]:40913 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757992AbaJaMgS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Oct 2014 08:36:18 -0400
Received: by mail-wg0-f48.google.com with SMTP id m15so1030586wgh.21
        for <linux-nfs@vger.kernel.org>; Fri, 31 Oct 2014 05:36:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1414758509-30397-1-git-send-email-jlayton@primarydata.com>
References: <1414758509-30397-1-git-send-email-jlayton@primarydata.com>
Date: Fri, 31 Oct 2014 14:36:16 +0200
Message-ID: <CAHQdGtSFrimRHne+NphHi5YcCSEV9pGjjQkUc2ktULsGDfE3iQ@mail.gmail.com>
Subject: Re: [PATCH] lockd: ratelimit "lockd: cannot monitor" messages
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, imc@cs.ox.ac.uk,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 31, 2014 at 2:28 PM, Jeff Layton <jlayton@primarydata.com> wrote:
> When lockd can't talk to a remote statd, it'll spew a warning message
> to the ring buffer. If the application is really hammering on locks
> however, it's possible for that message to spam the logs. Ratelimit it
> to minimize the potential for harm.
>
> Reported-by: Ian Collier <imc@cs.ox.ac.uk>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/lockd/mon.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 9106f42c472c..1cc6ec51e6b1 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -214,7 +214,7 @@ int nsm_monitor(const struct nlm_host *host)
>         if (unlikely(res.status != 0))
>                 status = -EIO;
>         if (unlikely(status < 0)) {
> -               printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
> +               pr_notice_ratelimited("lockd: cannot monitor %s\n", nsm->sm_name);
>                 return status;
>         }
>

How is this being triggered repeatedly? Normally, the 'cannot monitor'
message should be happening at client mount time or not at all.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

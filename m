Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756474Ab2HFOWv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Aug 2012 10:22:51 -0400
Message-ID: <501FD333.3080704@RedHat.com>
Date: Mon, 06 Aug 2012 10:22:43 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] rpc.gssd: don't call printerr from signal handler
References: <20120731205931.GA32161@fieldses.org> <1343768449-32205-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1343768449-32205-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/31/2012 05:00 PM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> printerr() isn't actually safe to call from a signal handler.  It might
> be possible to make it so, but I think this is the only case in
> nfs-utils where we try to, and I'm not convince it's worth it.
> 
> This fixes a bug that would eventually cause mounts to hang when gssd
> is run with -vv.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed...

steved.
> ---
>  utils/gssd/gssd_main_loop.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
> index 9954ffb..6914687 100644
> --- a/utils/gssd/gssd_main_loop.c
> +++ b/utils/gssd/gssd_main_loop.c
> @@ -61,10 +61,8 @@ extern int pollsize;
>  
>  static volatile int dir_changed = 1;
>  
> -static void dir_notify_handler(int sig)
> +static void dir_notify_handler(__attribute__((unused))int sig)
>  {
> -	printerr(2, "dir_notify_handler: sig %d\n", sig);
> -
>  	dir_changed = 1;
>  }
>  

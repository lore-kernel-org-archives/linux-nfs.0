Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756474Ab2HFOW2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Aug 2012 10:22:28 -0400
Message-ID: <501FD31A.4050105@RedHat.com>
Date: Mon, 06 Aug 2012 10:22:18 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] rpc.gssd: simplify signal handling
References: <20120731205931.GA32161@fieldses.org> <1343768449-32205-1-git-send-email-bfields@redhat.com>
In-Reply-To: <1343768449-32205-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/31/2012 05:00 PM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We're not actually using the extra sa_sigaction parameters.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  utils/gssd/gssd_main_loop.c |   11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
Committed...

steved.
> 
> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
> index c18e12c..9954ffb 100644
> --- a/utils/gssd/gssd_main_loop.c
> +++ b/utils/gssd/gssd_main_loop.c
> @@ -61,9 +61,9 @@ extern int pollsize;
>  
>  static volatile int dir_changed = 1;
>  
> -static void dir_notify_handler(int sig, siginfo_t *si, void *data)
> +static void dir_notify_handler(int sig)
>  {
> -	printerr(2, "dir_notify_handler: sig %d si %p data %p\n", sig, si, data);
> +	printerr(2, "dir_notify_handler: sig %d\n", sig);
>  
>  	dir_changed = 1;
>  }
> @@ -183,13 +183,12 @@ void
>  gssd_run()
>  {
>  	int			ret;
> -	struct sigaction	dn_act;
> +	struct sigaction	dn_act = {
> +		.sa_handler = dir_notify_handler
> +	};
>  	sigset_t		set;
>  
> -	/* Taken from linux/Documentation/dnotify.txt: */
> -	dn_act.sa_sigaction = dir_notify_handler;
>  	sigemptyset(&dn_act.sa_mask);
> -	dn_act.sa_flags = SA_SIGINFO;
>  	sigaction(DNOTIFY_SIGNAL, &dn_act, NULL);
>  
>  	/* just in case the signal is blocked... */

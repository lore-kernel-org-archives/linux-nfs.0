Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59684 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753205AbbBARtr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Feb 2015 12:49:47 -0500
Message-ID: <54CE6738.3090100@RedHat.com>
Date: Sun, 01 Feb 2015 12:49:44 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chris Mayo <aklhfex@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] statd: Fix test for foreground mode
References: <54CE322D.50402@gmail.com>
In-Reply-To: <54CE322D.50402@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/01/2015 09:03 AM, Chris Mayo wrote:
> daemon_init parameter has the opposite sense to code removed in commit 7addf9d
> 
> Signed-off-by: Chris Mayo <aklhfex@gmail.com>
> ---
>  utils/statd/statd.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
Committed... 

Hmm.. I didn't see this because I did all my testing with
systemd starting/stopping the daemons... I looks like
I'm going to have to rejigger my tests a bit... 

What distros/worlds don't systemd? I'll try to bring up
a VM to do some testing in those worlds... 

steved.

> 
> diff --git a/utils/statd/statd.c b/utils/statd/statd.c
> index 60ce6d1..6ff28f4 100644
> --- a/utils/statd/statd.c
> +++ b/utils/statd/statd.c
> @@ -393,7 +393,7 @@ int main (int argc, char **argv)
>  		simulator (--argc, ++argv);	/* simulator() does exit() */
>  #endif
>  
> -	daemon_init(!(run_mode & MODE_NODAEMON));
> +	daemon_init(run_mode & MODE_NODAEMON);
>  
>  	if (run_mode & MODE_LOG_STDERR) {
>  		xlog_syslog(0);
> 

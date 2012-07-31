Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:49458 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab2GaVWV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2012 17:22:21 -0400
Subject: Re: [PATCH 2/4] rpc.gssd: don't call printerr from signal handler
Mime-Version: 1.0 (Apple Message framework v1280)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1343768449-32205-2-git-send-email-bfields@redhat.com>
Date: Tue, 31 Jul 2012 14:22:11 -0700
Cc: Steve Dickson <SteveD@redhat.com>, Jim Rees <rees@umich.edu>,
        linux-nfs@vger.kernel.org
Message-Id: <965D1E6C-BC45-4553-8345-FC45E5097755@oracle.com>
References: <20120731205931.GA32161@fieldses.org> <1343768449-32205-2-git-send-email-bfields@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 31, 2012, at 2:00 PM, J. Bruce Fields wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> printerr() isn't actually safe to call from a signal handler.  It might
> be possible to make it so, but I think this is the only case in
> nfs-utils where we try to, and I'm not convince it's worth it.
> 
> This fixes a bug that would eventually cause mounts to hang when gssd
> is run with -vv.

Yes, I've seen this hang.  gssd gets stuck on a futex() with -vv or higher.

> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
> utils/gssd/gssd_main_loop.c |    4 +---
> 1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
> index 9954ffb..6914687 100644
> --- a/utils/gssd/gssd_main_loop.c
> +++ b/utils/gssd/gssd_main_loop.c
> @@ -61,10 +61,8 @@ extern int pollsize;
> 
> static volatile int dir_changed = 1;
> 
> -static void dir_notify_handler(int sig)
> +static void dir_notify_handler(__attribute__((unused))int sig)
> {
> -	printerr(2, "dir_notify_handler: sig %d\n", sig);
> -
> 	dir_changed = 1;
> }
> 
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




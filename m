Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58168 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147AbbAOTgK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jan 2015 14:36:10 -0500
Date: Thu, 15 Jan 2015 14:36:07 -0500
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [PATCH 3/3] start-statd: Use the canonical to check if systemd
 is running.
Message-ID: <20150115193607.GE15885@fieldses.org>
References: <1421181457-8159-1-git-send-email-steved@redhat.com>
 <1421181457-8159-4-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421181457-8159-4-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 13, 2015 at 03:37:37PM -0500, Steve Dickson wrote:
> Use the approved way, define in
>    http://www.freedesktop.org/software/systemd/man/sd_booted.html
> 
> to check if systemd is installed and running
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/statd/start-statd | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/statd/start-statd b/utils/statd/start-statd
> index ec9383b..b32b3a5 100755
> --- a/utils/statd/start-statd
> +++ b/utils/statd/start-statd
> @@ -7,7 +7,7 @@
>  PATH="/sbin:/usr/sbin:/bin:/usr/bin"
>  
>  # First try systemd if it's installed.
> -if systemctl --help >/dev/null 2>&1; then
> +if test -d /run/systemd/system; then
>      # Quit only if the call worked.
>      systemctl start rpc-statd.service && exit
>  fi

In the case systemctl start fails it then falls back on 

   exec rpc.statd --no-notify

which is kind of unexpected.  It's going to be confusing having this
hand-started statd on a systemd distro.  Better just to fail cleanly.

So that "&& exit" should just be "; exit".

--b.

> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

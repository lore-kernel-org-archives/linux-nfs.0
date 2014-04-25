Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbaDYOdS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 10:33:18 -0400
Message-ID: <535A7191.3030405@RedHat.com>
Date: Fri, 25 Apr 2014 10:30:41 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils/systemd] systemd: add PATH for finding systemctl
References: <5359D0EE.7030408@gmail.com>
In-Reply-To: <5359D0EE.7030408@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/24/2014 11:05 PM, Kinglong Mee wrote:
> The 1.3.0 release adds a call to systemctl fails for it's in /usr/bin.
> 
> [root@localhost nfs-utils]# start-statd
> /usr/sbin/start-statd: line 9: systemctl: command not found
> Statd service already running!
> 
> Reported-by: Allan Duncan <amd1234@fastmail.com.au>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Committed... Thanks!

steved.

> ---
>  utils/statd/start-statd | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/statd/start-statd b/utils/statd/start-statd
> index cde3583..8ac3798 100644
> --- a/utils/statd/start-statd
> +++ b/utils/statd/start-statd
> @@ -4,7 +4,7 @@
>  # /var/run/rpc.statd.pid).
>  # It should run statd with whatever flags are apropriate for this
>  # site.
> -PATH=/sbin:/usr/sbin
> +PATH="/sbin:/usr/sbin:/bin:/usr/bin"
>  if systemctl start statd.service
>  then :
>  else
> -- 1.9.0
> 

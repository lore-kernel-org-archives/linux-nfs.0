Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbaHRREl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2014 13:04:41 -0400
Message-ID: <53F23223.5090904@RedHat.com>
Date: Mon, 18 Aug 2014 13:04:35 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] start-statd: clean up output when systemd is
 not installed
References: <1408286648-19031-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1408286648-19031-1-git-send-email-vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/17/2014 10:44 AM, Mike Frysinger wrote:
> If you don't have systemd, then this script dumps:
> /usr/sbin/start-statd: line 8: systemctl: command not found
> 
> This isn't terribly useful since we ultimately fall back to running
> the daemon ourselves, so probe for systemd's existence before we try
> to use it.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Committed... but I used 'rpm -q systemd' instead of 'systemctl --help'
to test for the existences of systemd

 # First try systemd if it's installed.
-if systemctl --help >/dev/null 2>&1; then
+if rpm -q systemd > /dev/null 2>&1; then
     # Quit only if the call worked.
     systemctl start rpc-statd.service && exit


steved.

> ---
>  utils/statd/start-statd | 14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
>  mode change 100644 => 100755 utils/statd/start-statd
> 
> diff --git a/utils/statd/start-statd b/utils/statd/start-statd
> old mode 100644
> new mode 100755
> index dcdaf77..ec9383b
> --- a/utils/statd/start-statd
> +++ b/utils/statd/start-statd
> @@ -1,12 +1,16 @@
> -#!/bin/bash -p
> +#!/bin/sh
>  # nfsmount calls this script when mounting a filesystem with locking
>  # enabled, but when statd does not seem to be running (based on
>  # /var/run/rpc.statd.pid).
>  # It should run statd with whatever flags are apropriate for this
>  # site.
>  PATH="/sbin:/usr/sbin:/bin:/usr/bin"
> -if systemctl start rpc-statd.service
> -then :
> -else
> -    exec rpc.statd --no-notify
> +
> +# First try systemd if it's installed.
> +if systemctl --help >/dev/null 2>&1; then
> +    # Quit only if the call worked.
> +    systemctl start rpc-statd.service && exit
>  fi
> +
> +# Fall back to launching it ourselves.
> +exec rpc.statd --no-notify
> 

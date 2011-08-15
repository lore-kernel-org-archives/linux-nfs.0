Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:41066 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab1HOHcZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2011 03:32:25 -0400
Received: by wwe5 with SMTP id 5so1119488wwe.1
        for <linux-nfs@vger.kernel.org>; Mon, 15 Aug 2011 00:32:23 -0700 (PDT)
Message-ID: <4E48CB82.8040803@tonian.com>
Date: Mon, 15 Aug 2011 10:32:18 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>,
        steved@redhat.com
Subject: Re: [PATCH 1/2] blkmapd: remove init file
References: <1313086701-7103-1-git-send-email-rees@umich.edu>
In-Reply-To: <1313086701-7103-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks.  I pushed those to
git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git
at pnfs-nfs-utils-1-2-5-rc1-2011-08-15
(and pnfs-nfs-utils-1-2-4-2011-08-12)

Benny

On 2011-08-11 21:18, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  utils/blkmapd/etc/initd/initd.redhat |   76 ----------------------------------
>  1 files changed, 0 insertions(+), 76 deletions(-)
>  delete mode 100644 utils/blkmapd/etc/initd/initd.redhat
> 
> diff --git a/utils/blkmapd/etc/initd/initd.redhat b/utils/blkmapd/etc/initd/initd.redhat
> deleted file mode 100644
> index d6a77e8..0000000
> --- a/utils/blkmapd/etc/initd/initd.redhat
> +++ /dev/null
> @@ -1,76 +0,0 @@
> -#!/bin/sh
> -#
> -# description: Starts and stops the iSCSI initiator
> -#
> -# processname: blkmapd
> -# pidfile: /var/run/blkmapd.pid
> -# config:  /etc/blkmapd.conf
> -
> -# Source function library.
> -if [ -f /etc/init.d/functions ] ; then
> -	. /etc/init.d/functions
> -elif [ -f /etc/rc.d/init.d/functions ] ; then
> -	. /etc/rc.d/init.d/functions
> -else
> -	exit 0
> -fi
> -
> -PATH=/sbin:/bin:/usr/sbin:/usr/bin
> -
> -RETVAL=0
> -
> -start()
> -{
> -	echo -n $"Starting pNFS block-layout device discovery service: "
> -	modprobe -q blocklayoutdriver
> -	daemon /usr/sbin/blkmapd
> -	RETVAL=$?
> -	if [ $RETVAL -eq 0 ]; then
> -		touch /var/lock/subsys/blkmapd
> -	fi
> -	echo
> -	return $RETVAL
> -}
> -
> -stop()
> -{
> -	echo -n $"Stopping pNFS block-layout device discovery service: "
> -	killproc blkmapd 2> /dev/null
> -	rm -f /var/run/blkmapd.pid
> -	RETVAL=$?
> -	[ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/blkmapd
> -	if [ $RETVAL -eq 0 ]; then
> -                echo_success
> -        else
> -                echo_failure
> -        fi
> -	echo
> -	return $RETVAL
> -}
> -
> -restart()
> -{
> -	stop
> -	start
> -}
> -
> -case "$1" in
> -	start)
> -		start
> -		;;
> -	stop)
> -		stop
> -		;;
> -	restart)
> -		stop
> -		start
> -		;;
> -	status)
> -		status blkmapd
> -		;;
> -	*)
> -	echo $"Usage: $0 {start|stop|restart|status}"
> -	exit 1
> -esac
> -
> -exit $RETVAL

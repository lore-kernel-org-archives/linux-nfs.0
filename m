Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752559Ab1F0QXX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jun 2011 12:23:23 -0400
Message-ID: <4E08AE76.6030508@RedHat.com>
Date: Mon, 27 Jun 2011 12:23:18 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 2/2] remove -fwritable-strings for gcc 4.0
References: <cover.1308241259.git.rees@umich.edu> <41c8992e9446c712542515a85a8b4abb83476a9d.1308241259.git.rees@umich.edu>
In-Reply-To: <41c8992e9446c712542515a85a8b4abb83476a9d.1308241259.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/16/2011 12:23 PM, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  tests.init |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/tests.init b/tests.init
> index 69b51bf..5d93eb5 100644
> --- a/tests.init
> +++ b/tests.init
> @@ -210,6 +210,13 @@ LOCKTESTS=`echo tlocklfs tlock64`
>  #UMOUNT=/bin/umount
>  #LOCKTESTS=`echo tlocklfs tlock64`
>  
> +# Use with Linux 2.6 / gcc 4.0
> +CFLAGS=`echo -DLINUX -DGLIBC=22 -DMMAP -DSTDARG`
> +LIBS=`echo -lnsl`
> +MOUNT=/bin/mount
> +UMOUNT=/bin/umount
> +LOCKTESTS=`echo tlocklfs tlock64`
> +
>  # Use with Linux if your distro doesn't provide a "cc".
>  #CC=gcc
>  
Committed on the git://linux-nfs.org/~steved/exports/cthon04 tree

steved.

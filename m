Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36578 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755224AbeDTPDw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Apr 2018 11:03:52 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9B4A430043F8
        for <linux-nfs@vger.kernel.org>; Fri, 20 Apr 2018 15:03:52 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-49.phx2.redhat.com [10.3.116.49])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 667E28573D
        for <linux-nfs@vger.kernel.org>; Fri, 20 Apr 2018 15:03:52 +0000 (UTC)
Subject: Re: [PATCH] nfsd: Set default minor versions
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180417184220.54724-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <5471dbdb-8f4f-7ea7-213b-459b9b282e4e@RedHat.com>
Date: Fri, 20 Apr 2018 11:03:52 -0400
MIME-Version: 1.0
In-Reply-To: <20180417184220.54724-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/17/2018 02:42 PM, Steve Dickson wrote:
> Due to the way the kernel stores the supported
> minor versions, when a minor is turned off,
> via the -N flag, it can only turned back on
> via -V flag.
> 
> The default minor values should also enable
> these minor versions.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  support/include/nfs/nfs.h | 1 +
>  utils/nfsd/nfsd.c         | 4 ++--
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
> index 7933ff5..b7d9e06 100644
> --- a/support/include/nfs/nfs.h
> +++ b/support/include/nfs/nfs.h
> @@ -40,6 +40,7 @@ struct nfs_fh_len {
>  #define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & NFSCTL_TCPBIT) 
>  
>  #define NFSCTL_VERDEFAULT (0xc)       /* versions 3 and 4 */
> +#define NFSCTL_MINDEFAULT (0x7)       /* minor versions 4.1 and 4.2 */
>  #define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |= (1 << ((_v) - 1))) 
>  #define NFSCTL_MINORSET(_cltbits, _v)   ((_cltbits) |= (1 << (_v)))
>  #define NFSCTL_UDPSET(_cltbits)       ((_cltbits) |= NFSCTL_UDPBIT)
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index f41a2de..2303a5d 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -65,8 +65,8 @@ main(int argc, char **argv)
>  	int hcounter = 0;
>  	struct conf_list *hosts;
>  	int	socket_up = 0;
> -	unsigned int minorvers = 0;
> -	unsigned int minorversset = 0;
> +	unsigned int minorvers = NFSCTL_MINDEFAULT;
> +	unsigned int minorversset = NFSCTL_MINDEFAULT;
>  	unsigned int minormask = 0;
>  	unsigned int versbits = NFSCTL_VERDEFAULT;
>  	unsigned int protobits = NFSCTL_PROTODEFAULT;
> 

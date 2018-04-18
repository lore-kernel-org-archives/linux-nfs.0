Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36920 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751714AbeDRQW2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 18 Apr 2018 12:22:28 -0400
Date: Wed, 18 Apr 2018 12:22:28 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Set default minor versions
Message-ID: <20180418162228.GB9897@fieldses.org>
References: <20180417184220.54724-1-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180417184220.54724-1-steved@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2018 at 02:42:20PM -0400, Steve Dickson wrote:
> Due to the way the kernel stores the supported
> minor versions, when a minor is turned off,
> via the -N flag, it can only turned back on
> via -V flag.
> 
> The default minor values should also enable
> these minor versions.

Yeah, I remember now why I didn't want this.

It means that by default if somebody installs an old kernel from the
time when 4.1/4.2 support was much more experimental, then they get
4.1 and 4.2 by default.

Whereas if rpc.nfsd just doesn't touch those values then they'll get the
kernel default, leaving 4.1/4.2 off on older kernels and turning them
back on on newer kernels.

But, whatever, I'm not sure that was the right approach.  And 4.2's been
the kernel's default for 3 years now anyway.

So, ACK to the patch, thanks.

--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
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
> -- 
> 2.14.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

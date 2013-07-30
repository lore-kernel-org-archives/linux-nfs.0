Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45074 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714Ab3G3Pvk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Jul 2013 11:51:40 -0400
Date: Tue, 30 Jul 2013 11:51:39 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] rpc.nfsd: No longer advertise NFS v2 support.
Message-ID: <20130730155138.GD1443@fieldses.org>
References: <1375036598-31090-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1375036598-31090-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 28, 2013 at 02:36:37PM -0400, Steve Dickson wrote:
> Changed the default protocol versions that rpc.nfsd
> register with rpcbind to just 3 and 4. Version 2
> can still be enabled with the '-V' flag, but it
> will not be on by default.

OK, I think that's a first reasonable step--ACK.

--b.

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  support/include/nfs/nfs.h | 1 +
>  utils/nfsd/nfsd.c         | 2 +-
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
> index 174c2dd..5fd86f6 100644
> --- a/support/include/nfs/nfs.h
> +++ b/support/include/nfs/nfs.h
> @@ -52,6 +52,7 @@ struct nfs_fh_old {
>  #define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & NFSCTL_UDPBIT) 
>  #define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & NFSCTL_TCPBIT) 
>  
> +#define NFSCTL_VERDEFAULT (0xc)       /* versions 3 and 4 */
>  #define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |= (1 << ((_v) - 1))) 
>  #define NFSCTL_UDPSET(_cltbits)       ((_cltbits) |= NFSCTL_UDPBIT)
>  #define NFSCTL_TCPSET(_cltbits)       ((_cltbits) |= NFSCTL_TCPBIT)
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index e87c0a9..df48392 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -100,7 +100,7 @@ main(int argc, char **argv)
>  	char *haddr = NULL;
>  	int	socket_up = 0;
>  	int minorvers41 = 0;	/* nfsv4 minor version */
> -	unsigned int versbits = NFSCTL_ALLBITS;
> +	unsigned int versbits = NFSCTL_VERDEFAULT;
>  	unsigned int protobits = NFSCTL_ALLBITS;
>  	unsigned int proto4 = 0;
>  	unsigned int proto6 = 0;
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753777AbaAGVVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jan 2014 16:21:46 -0500
Message-ID: <52CC6B49.2070801@RedHat.com>
Date: Tue, 07 Jan 2014 16:02:01 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix minorversion-choosing interface
References: <OFDD407A92.688D29A1-ONC1257C43.00634FC8-C1257C43.00645775@transmode.se> <20131216185419.GB31816@fieldses.org> <20131216200301.GD31816@fieldses.org> <OF149AE409.624B2B0A-ONC1257C43.006F77D7-C1257C43.006FCED2@transmode.se> <20131216202345.GF31816@fieldses.org> <OF942071D7.5EC379B1-ONC1257C43.007AB858-C1257C43.007B0CFB@transmode.se> <20131217034331.GB3490@fieldses.org>
In-Reply-To: <20131217034331.GB3490@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 16/12/13 22:43, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> By unconditionally adding +/-4.2 to the version string written to the
> kernel we make nfs-utils incompatible with pre-4.2-supporting kernels.
> 
> Ditto for 4.1.  This problem was introduced by
> 12a590f8d556c00a9502eeebaa763d906222d521 "rpc.nfsd: Allow v4.2 server
> support with the -V option", which also change nfsd to unconditionally
> pass +/-4.2.
> 
> Instead, just don't mention 4.1 or 4.2 unless the commandline has
> specifically requested that one or the other be turned on or off.
> 
> Tested-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> Reported-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed...

steved

> ---
>  support/include/nfs/nfs.h | 1 -
>  utils/nfsd/nfsd.c         | 6 +++---
>  utils/nfsd/nfssvc.c       | 6 +++---
>  utils/nfsd/nfssvc.h       | 2 +-
>  4 files changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
> index 38db5b5..df4ad76 100644
> --- a/support/include/nfs/nfs.h
> +++ b/support/include/nfs/nfs.h
> @@ -17,7 +17,6 @@
>  
>  #define NFS4_MINMINOR 1
>  #define NFS4_MAXMINOR 2
> -#define NFS4_VERDEFAULT  0x1  /* minor verion 1 */
>  
>  struct nfs_fh_len {
>  	int		fh_size;
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 6db92f0..a9d77ab 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -99,7 +99,7 @@ main(int argc, char **argv)
>  	char *p, *progname, *port;
>  	char *haddr = NULL;
>  	int	socket_up = 0;
> -	int minorvers = NFS4_VERDEFAULT;	/* nfsv4 minor version */
> +	int minorvers[NFS4_MAXMINOR + 1] = {0};
>  	unsigned int versbits = NFSCTL_VERDEFAULT;
>  	unsigned int protobits = NFSCTL_ALLBITS;
>  	unsigned int proto4 = 0;
> @@ -164,7 +164,7 @@ main(int argc, char **argv)
>  						fprintf(stderr, "%s: unsupported minor version\n", optarg);
>  						exit(1);
>  					}
> -					NFSCTL_VERUNSET(minorvers, i);
> +					minorvers[i] = -1;
>  					break;
>  				}
>  			case 3:
> @@ -185,7 +185,7 @@ main(int argc, char **argv)
>  						fprintf(stderr, "%s: unsupported minor version\n", optarg);
>  						exit(1);
>  					}
> -					NFSCTL_VERSET(minorvers, i);
> +					minorvers[i] = 1;
>  					break;
>  				}
>  			case 3:
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index 8b85846..1b50aba 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -269,7 +269,7 @@ nfssvc_set_sockets(const int family, const unsigned int protobits,
>  }
>  
>  void
> -nfssvc_setvers(unsigned int ctlbits, int minorvers)
> +nfssvc_setvers(unsigned int ctlbits, int minorvers[])
>  {
>  	int fd, n, off;
>  	char *ptr;
> @@ -281,9 +281,9 @@ nfssvc_setvers(unsigned int ctlbits, int minorvers)
>  		return;
>  
>  	for (n = NFS4_MINMINOR; n <= NFS4_MAXMINOR; n++) {
> -		if (NFSCTL_VERISSET(minorvers, n)) 
> +		if (minorvers[n] == 1)
>  			off += snprintf(ptr+off, sizeof(buf) - off, "+4.%d ", n);
> -		else			
> +		else if (minorvers[n] == -1)
>  			off += snprintf(ptr+off, sizeof(buf) - off, "-4.%d ", n);
>  	}
>  	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
> diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
> index 08de0fe..2bbd3d3 100644
> --- a/utils/nfsd/nfssvc.h
> +++ b/utils/nfsd/nfssvc.h
> @@ -24,5 +24,5 @@ void	nfssvc_mount_nfsdfs(char *progname);
>  int	nfssvc_inuse(void);
>  int	nfssvc_set_sockets(const int family, const unsigned int protobits,
>  			   const char *host, const char *port);
> -void	nfssvc_setvers(unsigned int ctlbits, int minorvers4);
> +void	nfssvc_setvers(unsigned int ctlbits, int minorvers4[]);
>  int	nfssvc_threads(unsigned short port, int nrservs);
> 

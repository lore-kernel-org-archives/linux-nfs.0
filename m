From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 2/2] nfsd: default to kernel default for minorversion 1
Date: Mon, 1 Feb 2010 14:58:22 -0500
Message-ID: <20100201195821.GB19418@fieldses.org>
References: <1264631166-21898-1-git-send-email-bfields@citi.umich.edu> <1264631166-21898-2-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43756 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754876Ab0BAT6O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Feb 2010 14:58:14 -0500
In-Reply-To: <1264631166-21898-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 27, 2010 at 05:26:06PM -0500, J. Bruce Fields wrote:
> The current kernel code should not be enabled by default, because it
> does not yet attempt to be a conform completely to the rfc; for example,
> some required pieces of protocol are missing.
> 
> Therefore the kernel defaults to leaving minorversion1 off.  When the
> code matures sufficiently, that default will change.
> 
> That kernel default becomes meaningless if nfs-utils always explicitly
> turns 4.1 on or off.  So, nfs-utils should by default do nothing.
> 
> Provide a --enable-experimental-v41-support option to turn it on
> explicitly.  The option is intentionally spelled out (and has no short
> equivalent), to help ensure that users know what they're getting into.
> 
> Once 4.1 defaults to on, that option will become unnecessary (and can
> probably just be dropped from nfs-utils), and only the -N 4.1 option
> will be necessary.

We need to figure out how we're going to handle this.  The current
situation (ignoring the kernel's default) isn't acceptable.

We need to figure out something for v4 as well.  If every distro has run
nfsd without -N4, depending on the lack of fsid=0 to keep nfsv4 off by
default, then we're effectively turning v4 on by default with the
pseudoroot changes.  But there are good reasons why the v4 server code
is still marked experimental.

--b.

> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  support/include/nfs/nfs.h |    3 ---
>  utils/nfsd/nfsd.c         |   17 +++++++++++++----
>  utils/nfsd/nfssvc.c       |   10 ++++------
>  3 files changed, 17 insertions(+), 13 deletions(-)
> 
> diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
> index a64eb0a..824f604 100644
> --- a/support/include/nfs/nfs.h
> +++ b/support/include/nfs/nfs.h
> @@ -13,9 +13,6 @@
>  #define NFSD_MINVERS 2
>  #define NFSD_MAXVERS 4
>  
> -#define NFSD_MINMINORVERS4 1
> -#define NFSD_MAXMINORVERS4 1
> -
>  struct nfs_fh_len {
>  	int		fh_size;
>  	u_int8_t	fh_handle[NFS3_FHSIZE];
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 1cda1e5..c72f73e 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -49,6 +49,7 @@ static struct option longopts[] =
>  	{ "port", 1, 0, 'p' },
>  	{ "debug", 0, 0, 'd' },
>  	{ "syslog", 0, 0, 's' },
> +	{ "enable-experimental-v41-support", 0, 0, 'X' },
>  	{ NULL, 0, 0, 0 }
>  };
>  
> @@ -103,7 +104,7 @@ main(int argc, char **argv)
>  	char *p, *progname, *port;
>  	char *haddr = NULL;
>  	int	socket_up = 0;
> -	int minorvers4 = NFSD_MAXMINORVERS4;	/* nfsv4 minor version */
> +	int minorvers41 = 0;	/* nfsv4 minor version */
>  	unsigned int versbits = NFSCTL_ALLBITS;
>  	unsigned int protobits = NFSCTL_ALLBITS;
>  	unsigned int proto4 = 0;
> @@ -163,7 +164,12 @@ main(int argc, char **argv)
>  			switch((c = strtol(optarg, &p, 0))) {
>  			case 4:
>  				if (*p == '.') {
> -					minorvers4 = -atoi(p + 1);
> +					int i = atoi(p+1);
> +					if (i != 1) {
> +						fprintf(stderr, "%s: unsupported minor version\n", optarg);
> +						exit(1);
> +					}
> +					minorvers41 = -1;
>  					break;
>  				}
>  			case 3:
> @@ -185,6 +191,9 @@ main(int argc, char **argv)
>  		case 'U':
>  			NFSCTL_UDPUNSET(protobits);
>  			break;
> +		case 'X':
> +			minorvers41 = 1;
> +			break;
>  		default:
>  			fprintf(stderr, "Invalid argument: '%c'\n", c);
>  		case 'h':
> @@ -257,7 +266,7 @@ main(int argc, char **argv)
>  	 * registered with rpcbind. Note that on older kernels w/o the right
>  	 * interfaces, these are a no-op.
>  	 */
> -	nfssvc_setvers(versbits, minorvers4);
> +	nfssvc_setvers(versbits, minorvers41);
>   
>  	error = nfssvc_set_sockets(AF_INET, proto4, haddr, port);
>  	if (!error)
> @@ -309,7 +318,7 @@ static void
>  usage(const char *prog)
>  {
>  	fprintf(stderr, "Usage:\n"
> -		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version ] [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] nrservs\n", 
> +		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version ] [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] [--enable-experimental-v41-support] nrservs\n", 
>  		prog);
>  	exit(2);
>  }
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index 7bbbaba..ec9446a 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -227,7 +227,7 @@ nfssvc_set_sockets(const int family, const unsigned int protobits,
>  }
>  
>  void
> -nfssvc_setvers(unsigned int ctlbits, int minorvers4)
> +nfssvc_setvers(unsigned int ctlbits, int minorvers41)
>  {
>  	int fd, n, off;
>  	char *ptr;
> @@ -238,11 +238,9 @@ nfssvc_setvers(unsigned int ctlbits, int minorvers4)
>  	if (fd < 0)
>  		return;
>  
> -	n = minorvers4 >= 0 ? minorvers4 : -minorvers4;
> -	if (n >= NFSD_MINMINORVERS4 && n <= NFSD_MAXMINORVERS4)
> -		    off += snprintf(ptr+off, sizeof(buf) - off, "%c4.%d",
> -				    minorvers4 > 0 ? '+' : '-',
> -				    n);
> +	if (minorvers41)
> +		off += snprintf(ptr+off, sizeof(buf) - off, "%c4.1",
> +				minorvers41 > 0 ? '+' : '-');
>  	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
>  		if (NFSCTL_VERISSET(ctlbits, n))
>  		    off += snprintf(ptr+off, sizeof(buf) - off, "+%d ", n);
> -- 
> 1.6.3.3
> 

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44702 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751486AbdB0VxN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Feb 2017 16:53:13 -0500
Date: Mon, 27 Feb 2017 16:53:09 -0500
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC nfs-utils PATCH] nfsd: don't enable a UDP socket by default
Message-ID: <20170227215309.GA10497@fieldses.org>
References: <20170225131311.14101-1-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170225131311.14101-1-jlayton@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 25, 2017 at 08:13:11AM -0500, Jeff Layton wrote:
> Most major NFS clients have supported TCP for at least a decade now,
> and v4-only shops are becoming more prevalent. It seems reasonable that
> serving over UDP should be something that is "opt-in".
> 
> I've always hesitated to do this in the past, but now that we have
> nfs.conf, it seems like the time may be right to disable UDP in default
> configurations. In particular, it would be good to try this in the more
> bleeding edge distros (Fedora, Ubuntu, SuSE, etc...) and see how
> problematic it is.
>
> Change the default in rpc.nfsd to just open TCP ports by default. Add
> new -u and -t options that allow users to explicitly override what's
> in the config file, and update the usage message and manpage.

I guess I'm OK with trying it.

What does the failure look like (from the Linux client at least) in the
case of a preexisting UDP mount, or a new UDP mount?  (Do they get a
useful error, or at least something in sylog if there's a hang?)

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  nfs.conf                  |  2 +-
>  support/include/nfs/nfs.h |  2 +-
>  utils/nfsd/nfsd.c         | 18 +++++++++++++-----
>  utils/nfsd/nfsd.man       | 14 ++++++++------
>  4 files changed, 23 insertions(+), 13 deletions(-)
> 
> diff --git a/nfs.conf b/nfs.conf
> index 81ece0602dba..5d5a23463cff 100644
> --- a/nfs.conf
> +++ b/nfs.conf
> @@ -42,7 +42,7 @@
>  # port=0
>  # grace-time=90
>  # lease-time=90
> -# udp=y
> +# udp=n
>  # tcp=y
>  # vers2=n
>  # vers3=y
> diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
> index 15ecc6bfc485..5b1ef0ce3883 100644
> --- a/support/include/nfs/nfs.h
> +++ b/support/include/nfs/nfs.h
> @@ -27,6 +27,7 @@ struct nfs_fh_len {
>  
>  #define NFSCTL_UDPBIT		      (1 << (17 - 1))
>  #define NFSCTL_TCPBIT		      (1 << (18 - 1))
> +#define NFSCTL_PROTODEFAULT	      (NFSCTL_TCPBIT)
>  
>  #define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 1))) 
>  #define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_UDPBIT) 
> @@ -42,6 +43,5 @@ struct nfs_fh_len {
>  #define NFSCTL_TCPSET(_cltbits)       ((_cltbits) |= NFSCTL_TCPBIT)
>  
>  #define NFSCTL_ANYPROTO(_cltbits)     ((_cltbits) & (NFSCTL_UDPBIT | NFSCTL_TCPBIT))
> -#define NFSCTL_ALLBITS (~0)
>  
>  #endif /* _NFS_NFS_H */
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 20f4b7952203..5d101f0e98c3 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -44,7 +44,9 @@ static struct option longopts[] =
>  	{ "help", 0, 0, 'h' },
>  	{ "no-nfs-version", 1, 0, 'N' },
>  	{ "nfs-version", 1, 0, 'V' },
> +	{ "tcp", 0, 0, 't' },
>  	{ "no-tcp", 0, 0, 'T' },
> +	{ "udp", 0, 0, 'u' },
>  	{ "no-udp", 0, 0, 'U' },
>  	{ "port", 1, 0, 'P' },
>  	{ "port", 1, 0, 'p' },
> @@ -68,7 +70,7 @@ main(int argc, char **argv)
>  	unsigned int minorvers = 0;
>  	unsigned int minorversset = 0;
>  	unsigned int versbits = NFSCTL_VERDEFAULT;
> -	unsigned int protobits = NFSCTL_ALLBITS;
> +	unsigned int protobits = NFSCTL_PROTODEFAULT;
>  	int grace = -1;
>  	int lease = -1;
>  
> @@ -138,7 +140,7 @@ main(int argc, char **argv)
>  		}
>  	}
>  
> -	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTUrG:L:", longopts, NULL)) != EOF) {
> +	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:stTitUrG:L:", longopts, NULL)) != EOF) {
>  		switch(c) {
>  		case 'd':
>  			xlog_config(D_ALL, 1);
> @@ -222,9 +224,15 @@ main(int argc, char **argv)
>  			xlog_syslog(1);
>  			xlog_stderr(0);
>  			break;
> +		case 't':
> +			NFSCTL_TCPSET(protobits);
> +			break;
>  		case 'T':
>  			NFSCTL_TCPUNSET(protobits);
>  			break;
> +		case 'u':
> +			NFSCTL_UDPSET(protobits);
> +			break;
>  		case 'U':
>  			NFSCTL_UDPUNSET(protobits);
>  			break;
> @@ -372,9 +380,9 @@ usage(const char *prog)
>  {
>  	fprintf(stderr, "Usage:\n"
>  		"%s [-d|--debug] [-H hostname] [-p|-P|--port port]\n"
> -		"     [-N|--no-nfs-version version] [-V|--nfs-version version]\n"
> -		"     [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] [-r|--rdma=]\n"
> -		"     [-G|--grace-time secs] [-L|--leasetime secs] nrservs\n",
> +		"   [-N|--no-nfs-version version] [-V|--nfs-version version]\n"
> +		"   [-s|--syslog] [-t|--tcp] [-T|--no-tcp] [-u|--udp] [-U|--no-udp]\n"
> +		"   [-r|--rdma=] [-G|--grace-time secs] [-L|--leasetime secs] nrservs\n",
>  		prog);
>  	exit(2);
>  }
> diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
> index 8901fb6c6872..e0c640a64094 100644
> --- a/utils/nfsd/nfsd.man
> +++ b/utils/nfsd/nfsd.man
> @@ -67,15 +67,17 @@ logs error messages (and debug messages, if enabled) to stderr. This option make
>  log these messages to syslog instead. Note that errors encountered during
>  option processing will still be logged to stderr regardless of this option.
>  .TP
> +.B \-t " or " \-\-tcp
> +Instruct the kernel nfs server to open and listen on a TCP socket. This is the default.
> +.TP
>  .B \-T " or " \-\-no-tcp
> -Disable 
> -.B rpc.nfsd 
> -from accepting TCP connections from clients.
> +Instruct the kernel nfs server not to open and listen on a TCP socket.
> +.TP
> +.B \-u " or " \-\-udp
> +Instruct the kernel nfs server to open and listen on a UDP socket.
>  .TP
>  .B \-U " or " \-\-no-udp
> -Disable
> -.B rpc.nfsd
> -from accepting UDP connections from clients.
> +Instruct the kernel nfs server not to open and listen on a UDP socket. This is the default.
>  .TP
>  .B \-V " or " \-\-nfs-version vers
>  This option can be used to request that 
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

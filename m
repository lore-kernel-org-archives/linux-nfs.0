Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54436 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752765AbcLFRwq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 12:52:46 -0500
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
To: NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble>
 <148065110833.28046.2561331715736018574.stgit@noble>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <79c2889c-3a77-7fcb-37d0-8fd970b54be7@RedHat.com>
Date: Tue, 6 Dec 2016 12:52:44 -0500
MIME-Version: 1.0
In-Reply-To: <148065110833.28046.2561331715736018574.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/01/2016 10:58 PM, NeilBrown wrote:
> I haven't added -H support, but everything else should be able to be
> set through /etc/nfs.conf.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  systemd/nfs.conf.man |   24 ++++++++++++++++++++++++
>  utils/nfsd/nfsd.c    |   36 ++++++++++++++++++++++++++++++++++++
>  utils/nfsd/nfsd.man  |   49 ++++++++++++++++++++++++++++++++++++++++++++++---
>  3 files changed, 106 insertions(+), 3 deletions(-)
> 
> diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
> index 1f524d8fe74e..6ac6c65a81d9 100644
> --- a/systemd/nfs.conf.man
> +++ b/systemd/nfs.conf.man
> @@ -76,8 +76,32 @@ file is the only way to configure this program.  See
>  .BR nfsdcltrack (8)
>  for details.
>  
> +.TP
> +.B nfsd
> +Recognized values:
> +.BR threads ,
> +.BR grace-time ,
> +.BR lease-time ,
> +.BR udp ,
> +.BR tcp ,
> +.BR vers2 ,
> +.BR vers3 ,
> +.BR vers4 ,
> +.BR vers4.0 ,
> +.BR vers4.1 ,
> +.BR vers4.2 ,
> +.BR rdma .
I'm curious as to what the criteria was as to
which options were defined. I would think 'debug'
and 'port' would have made the list.

steved.

> +
> +Version and protocol values are Boolean values as described above.
> +Threads and the two times are integers.
> +.B rdma
> +is a service name or number.  See
> +.BR rpc.nfsd (8)
> +for details.
> +
>  .SH FILES
>  .I /etc/nfs.conf
>  .SH SEE ALSO
>  .BR nfsdcltrack (8),
> +.BR rpc.nfsd (8),
>  .BR nfsmount.conf (5).
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 9a65877f30c3..62b2876948c3 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -24,6 +24,7 @@
>  #include <netinet/in.h>
>  #include <arpa/inet.h>
>  
> +#include "conffile.h"
>  #include "nfslib.h"
>  #include "nfssvc.h"
>  #include "xlog.h"
> @@ -33,6 +34,8 @@
>  #define NFSD_NPROC 8
>  #endif
>  
> +char *conf_path = NFS_CONFFILE;
> +
>  static void	usage(const char *);
>  
>  static struct option longopts[] =
> @@ -76,6 +79,39 @@ main(int argc, char **argv)
>  	xlog_syslog(0);
>  	xlog_stderr(1);
>  
> +	conf_init();
> +	count = conf_get_num("nfsd", "threads", count);
> +	grace = conf_get_num("nfsd", "grace-time", grace);
> +	lease = conf_get_num("nfsd", "lease-time", lease);
> +	rdma_port = conf_get_str("nfsd", "rdma");
> +	if (conf_get_bool("nfsd", "udp", NFSCTL_UDPISSET(protobits)))
> +		NFSCTL_UDPSET(protobits);
> +	else
> +		NFSCTL_UDPUNSET(protobits);
> +	if (conf_get_bool("nfsd", "tcp", NFSCTL_TCPISSET(protobits)))
> +		NFSCTL_TCPSET(protobits);
> +	else
> +		NFSCTL_TCPUNSET(protobits);
> +	for (i = 2; i <= 4; i++) {
> +		char tag[10];
> +		sprintf(tag, "vers%d", i);
> +		if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(versbits, i)))
> +			NFSCTL_VERSET(versbits, i);
> +		else
> +			NFSCTL_VERUNSET(versbits, i);
> +	}
> +	/* We assume the kernel will default all minor versions to 'on',
> +	 * and allow the config file to disable some.
> +	 */
> +	for (i = 0; i <= NFS4_MAXMINOR; i++) {
> +		char tag[20];
> +		sprintf(tag, "vers4.%d", i);
> +		if (!conf_get_bool("nfsd", tag, 1)) {
> +			NFSCTL_VERSET(minorversset, i);
> +			NFSCTL_VERUNSET(minorversset, i);
> +		}
> +	}
> +
>  	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTUrG:L:", longopts, NULL)) != EOF) {
>  		switch(c) {
>  		case 'd':
> diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
> index 3ba847e2938f..7b9fbf21a947 100644
> --- a/utils/nfsd/nfsd.man
> +++ b/utils/nfsd/nfsd.man
> @@ -95,11 +95,11 @@ New file open requests (NFSv4) and new file locks (NLM) will not be
>  allowed until after this time has passed to allow clients to recover state.
>  .TP
>  .I nproc
> -specify the number of NFS server threads. By default, just one
> -thread is started. However, for optimum performance several threads
> +specify the number of NFS server threads. By default, eight
> +threads are started. However, for optimum performance several threads
>  should be used. The actual figure depends on the number of and the work
>  load created by the NFS clients, but a useful starting point is
> -8 threads. Effects of modifying that number can be checked using
> +eight threads. Effects of modifying that number can be checked using
>  the
>  .BR nfsstat (8)
>  program.
> @@ -114,6 +114,48 @@ In particular
>  .B rpc.nfsd 0
>  will stop all threads and thus close any open connections.
>  
> +.SH CONFIGURATION FILE
> +Many of the options that can be set on the command line can also be
> +controlled through values set in the
> +.B [nfsd]
> +section of the
> +.I /etc/nfs.conf
> +configuration file.  Values recognized include:
> +.TP
> +.B threads
> +The number of threads to start.
> +.TP
> +.B grace-time
> +The grace time, for both NFSv4 and NLM, in seconds.
> +.TP
> +.B lease-time
> +The lease time for NFSv4, in seconds.
> +.TP
> +.B rdma
> +Set RDMA port.  Use "rdma=nfsrdma" to enable standard port.
> +.TP
> +.B UDP
> +Enable (with "on" or "yes" etc) or disable ("off", "no") UDP support.
> +.TP
> +.B TCP
> +Enable or disable TCP support.
> +.TP
> +.B vers2
> +.TP
> +.B vers3
> +.TP
> +.B vers4
> +Enable or disable a major NFS version.  3 and 4 are normally enabled
> +by default.
> +.TP
> +.B vers4.1
> +.TP
> +.B vers4.2
> +.TP
> +.B vers4.3
> +Setting these to "off" or similar will disable the selected minor
> +versions.  All are enabled by default.
> +
>  .SH NOTES
>  If the program is built with TI-RPC support, it will enable any protocol and
>  address family combinations that are marked visible in the
> @@ -125,6 +167,7 @@ database.
>  .BR rpc.mountd (8),
>  .BR exports (5),
>  .BR exportfs (8),
> +.BR nfs.conf (5),
>  .BR rpc.rquotad (8),
>  .BR nfsstat (8),
>  .BR netconfig(5).
> 
> 

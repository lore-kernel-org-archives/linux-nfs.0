Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934328AbcCPSq4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 14:46:56 -0400
Date: Wed, 16 Mar 2016 14:46:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Shirley Ma <shirley.ma@oracle.com>
Cc: leon@leon.nu, Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: [PATCH] nfs: add nfs IPv6 rdma6 mount option support
Message-ID: <20160316184654.GA8506@pad.redhat.com>
References: <56E9A650.7060409@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56E9A650.7060409@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 11:30:40AM -0700, Shirley Ma wrote:
> Add rdma6 option to support NFS/RDMA IPv6.

This is client-side: cc'ing Trond and Anna.--b.

> 
> Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
> ---
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index f126828..62a55d0 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -191,6 +191,7 @@ static const match_table_t nfs_mount_option_tokens = {
>  
>  enum {
>  	Opt_xprt_udp, Opt_xprt_udp6, Opt_xprt_tcp, Opt_xprt_tcp6, Opt_xprt_rdma,
> +	Opt_xprt_rdma6,
>  
>  	Opt_xprt_err
>  };
> @@ -201,6 +202,7 @@ static const match_table_t nfs_xprt_protocol_tokens = {
>  	{ Opt_xprt_tcp, "tcp" },
>  	{ Opt_xprt_tcp6, "tcp6" },
>  	{ Opt_xprt_rdma, "rdma" },
> +	{ Opt_xprt_rdma6, "rdma6" },
>  
>  	{ Opt_xprt_err, NULL }
>  };
> @@ -1456,6 +1458,8 @@ static int nfs_parse_mount_options(char *raw,
>  				mnt->flags |= NFS_MOUNT_TCP;
>  				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
>  				break;
> +			case Opt_xprt_rdma6:
> +				protofamily = AF_INET6;
>  			case Opt_xprt_rdma:
>  				/* vector side protocols to TCP */
>  				mnt->flags |= NFS_MOUNT_TCP;
> @@ -1490,6 +1494,8 @@ static int nfs_parse_mount_options(char *raw,
>  			case Opt_xprt_tcp:
>  				mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
>  				break;
> +			case Opt_xprt_rdma6:
> +				mountfamily = AF_INET6;
>  			case Opt_xprt_rdma: /* not used for side protocols */
>  			default:
>  				dfprintk(MOUNT, "NFS:   unrecognized "
> diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
> index 8073713..49b8433 100644
> --- a/include/linux/sunrpc/msg_prot.h
> +++ b/include/linux/sunrpc/msg_prot.h
> @@ -149,6 +149,7 @@ typedef __be32	rpc_fraghdr;
>  #define RPCBIND_NETID_UDP	"udp"
>  #define RPCBIND_NETID_TCP	"tcp"
>  #define RPCBIND_NETID_RDMA	"rdma"
> +#define RPCBIND_NETID_RDMA6	"rdma6"
>  #define RPCBIND_NETID_SCTP	"sctp"
>  #define RPCBIND_NETID_UDP6	"udp6"
>  #define RPCBIND_NETID_TCP6	"tcp6"
> 

From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: convert proto= option to use netid's rather than a protoname
Date: Wed, 28 Oct 2009 16:15:33 -0400
Message-ID: <9EF4B3B4-5F00-4E66-81AA-ADDF348ADED4@oracle.com>
References: <1256758812-24928-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:31007 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940AbZJ1UQI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Oct 2009 16:16:08 -0400
In-Reply-To: <1256758812-24928-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 28, 2009, at 3:40 PM, Jeff Layton wrote:

> Solaris uses netids as values for the proto= option, so that when
> someone specifies "tcp6" they get traffic over TCP + IPv6. Until
> recently, this has never really been an issue for Linux since it  
> didn't
> support NFS over IPv6.  The netid and the protocol name were generally
> always the same (modulo any strange configuration in /etc/netconfig).
>
> The solaris manpage documents their proto= option as:
>
>    proto= _netid_ | rdma
>
> This patch is intended to bring Linux closer to how the Solaris proto=
> option works, by declaring a static netid mapping in the kernel and
> converting the proto= and mountproto= options to follow it and display
> the proper values in /proc/mounts.
>
> Much of this functionality will need to be provided by a userspace
> mount.nfs patch. Chuck Lever has a draft patch to change mount.nfs in
> the same way. In principle, we could do *all* of this in userspace but
> for the fact that the mount options in /proc/mounts would no longer
> reflect the options passed to mount.nfs.
>
> The alternative to the static mapping here is to add a mechanism to
> upcall  to userspace for netid's. I'm not opposed to that option, but
> it'll probably mean a bit more overhead (and quite a bit more code).
> Rather than shoot for that at first, I figured it was probably  
> better to
> start simply.
>
> Comments welcome...
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/super.c |   94 +++++++++++++++++++++++++++++++++++++++++++++++ 
> +--------
> 1 files changed, 81 insertions(+), 13 deletions(-)
>
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 90be551..e63b8f4 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -175,14 +175,16 @@ static const match_table_t  
> nfs_mount_option_tokens = {
> };
>
> enum {
> -	Opt_xprt_udp, Opt_xprt_tcp, Opt_xprt_rdma,
> +	Opt_xprt_udp, Opt_xprt_udp6, Opt_xprt_tcp, Opt_xprt_tcp6,  
> Opt_xprt_rdma,
>
> 	Opt_xprt_err
> };
>
> static const match_table_t nfs_xprt_protocol_tokens = {
> 	{ Opt_xprt_udp, "udp" },
> +	{ Opt_xprt_udp6, "udp6" },
> 	{ Opt_xprt_tcp, "tcp" },
> +	{ Opt_xprt_tcp6, "tcp6" },
> 	{ Opt_xprt_rdma, "rdma" },
>
> 	{ Opt_xprt_err, NULL }
> @@ -492,6 +494,45 @@ static const char  
> *nfs_pseudoflavour_to_name(rpc_authflavor_t flavour)
> 	return sec_flavours[i].str;
> }
>
> +static void nfs_show_mountd_netid(struct seq_file *m, struct  
> nfs_server *nfss,
> +				  int showdefaults)
> +{
> +	struct sockaddr *sap = (struct sockaddr *) &nfss->mountd_address;
> +
> +	seq_printf(m, ",mountproto=");
> +	switch (sap->sa_family) {
> +	case AF_INET:
> +		switch (nfss->mountd_protocol) {
> +		case IPPROTO_UDP:
> +			seq_printf(m, RPCBIND_NETID_UDP);
> +			break;
> +		case IPPROTO_TCP:
> +			seq_printf(m, RPCBIND_NETID_TCP);
> +			break;
> +		default:
> +			if (showdefaults)
> +				seq_printf(m, "auto");
> +		}
> +		break;
> +	case AF_INET6:
> +		switch (nfss->mountd_protocol) {
> +		case IPPROTO_UDP:
> +			seq_printf(m, RPCBIND_NETID_UDP6);
> +			break;
> +		case IPPROTO_TCP:
> +			seq_printf(m, RPCBIND_NETID_TCP6);
> +			break;
> +		default:
> +			if (showdefaults)
> +				seq_printf(m, "auto");
> +		}
> +		break;
> +	default:
> +		if (showdefaults)
> +			seq_printf(m, "auto");
> +	}
> +}
> +
> static void nfs_show_mountd_options(struct seq_file *m, struct  
> nfs_server *nfss,
> 				    int showdefaults)
> {
> @@ -518,17 +559,7 @@ static void nfs_show_mountd_options(struct  
> seq_file *m, struct nfs_server *nfss,
> 	if (nfss->mountd_port || showdefaults)
> 		seq_printf(m, ",mountport=%u", nfss->mountd_port);
>
> -	switch (nfss->mountd_protocol) {
> -	case IPPROTO_UDP:
> -		seq_printf(m, ",mountproto=udp");
> -		break;
> -	case IPPROTO_TCP:
> -		seq_printf(m, ",mountproto=tcp");
> -		break;
> -	default:
> -		if (showdefaults)
> -			seq_printf(m, ",mountproto=auto");
> -	}
> +	nfs_show_mountd_netid(m, nfss, showdefaults);
> }
>
> /*
> @@ -578,7 +609,7 @@ static void nfs_show_mount_options(struct  
> seq_file *m, struct nfs_server *nfss,
> 			seq_puts(m, nfs_infop->nostr);
> 	}
> 	seq_printf(m, ",proto=%s",
> -		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_PROTO));
> +		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_NETID));

Does that do the right thing for rdma mounts, currently?

> 	if (version == 4) {
> 		if (nfss->port != NFS_PORT)
> 			seq_printf(m, ",port=%u", nfss->port);
> @@ -887,6 +918,8 @@ static int nfs_parse_mount_options(char *raw,
> {
> 	char *p, *string, *secdata;
> 	int rc, sloppy = 0, invalid_option = 0;
> +	unsigned short protofamily = AF_UNSPEC;
> +	unsigned short mountfamily = AF_UNSPEC;
>
> 	if (!raw) {
> 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
> @@ -1232,12 +1265,17 @@ static int nfs_parse_mount_options(char *raw,
> 			token = match_token(string,
> 					    nfs_xprt_protocol_tokens, args);
>
> +			protofamily = AF_INET;
> 			switch (token) {
> +			case Opt_xprt_udp6:
> +				protofamily = AF_INET6;
> 			case Opt_xprt_udp:
> 				mnt->flags &= ~NFS_MOUNT_TCP;
> 				mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
> 				kfree(string);
> 				break;
> +			case Opt_xprt_tcp6:
> +				protofamily = AF_INET6;
> 			case Opt_xprt_tcp:
> 				mnt->flags |= NFS_MOUNT_TCP;
> 				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
> @@ -1265,10 +1303,15 @@ static int nfs_parse_mount_options(char *raw,
> 					    nfs_xprt_protocol_tokens, args);
> 			kfree(string);
>
> +			mountfamily = AF_INET;
> 			switch (token) {
> +			case Opt_xprt_udp6:
> +				mountfamily = AF_INET6;
> 			case Opt_xprt_udp:
> 				mnt->mount_server.protocol = XPRT_TRANSPORT_UDP;
> 				break;
> +			case Opt_xprt_tcp6:
> +				mountfamily = AF_INET6;
> 			case Opt_xprt_tcp:
> 				mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
> 				break;
> @@ -1367,8 +1410,33 @@ static int nfs_parse_mount_options(char *raw,
> 	if (!sloppy && invalid_option)
> 		return 0;
>
> +	/*
> +	 * verify that any proto=/mountproto= options match the address
> +	 * familiies in the addr=/mountaddr= options.
> +	 */
> +	if (protofamily != AF_UNSPEC &&
> +	    protofamily != mnt->nfs_server.address.ss_family)
> +		goto out_proto_mismatch;
> +
> +	if (mountfamily != AF_UNSPEC) {
> +		if (mnt->mount_server.addrlen) {
> +			if (mountfamily != mnt->mount_server.address.ss_family)
> +				goto out_mountproto_mismatch;
> +		} else {
> +			if (mountfamily != mnt->nfs_server.address.ss_family)
> +				goto out_mountproto_mismatch;
> +		}
> +	}
> +
> 	return 1;
>
> +out_mountproto_mismatch:
> +	printk(KERN_INFO "NFS: mount server address does not match  
> mountproto= "
> +			 "option\n");
> +	return 0;
> +out_proto_mismatch:
> +	printk(KERN_INFO "NFS: server address does not match proto= option 
> \n");
> +	return 0;
> out_invalid_address:
> 	printk(KERN_INFO "NFS: bad IP address specified: %s\n", p);
> 	return 0;
> -- 
> 1.6.0.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




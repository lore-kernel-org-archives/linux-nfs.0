Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6195 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753205Ab1EPXZ2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 19:25:28 -0400
Subject: Re: [PATCH] NFS: pnfs IPv6 support
Content-Type: text/plain; charset=us-ascii
From: Weston Andros Adamson <dros@netapp.com>
In-Reply-To: <1305478207-17335-1-git-send-email-dros@netapp.com>
Date: Mon, 16 May 2011 19:25:11 -0400
Cc: NFS list <linux-nfs@vger.kernel.org>
Message-Id: <2BEC6940-37A7-4445-B5AB-C2B416296D97@netapp.com>
References: <1305478207-17335-1-git-send-email-dros@netapp.com>
To: trond@netapp.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I just realized that this kzalloc()s while holding the spinlock in nfs4_pnfs_ds_add().  I'll fix and post as a patch set with my (almost complete) multipath config support for pnfs.

-dros

On May 15, 2011, at 12:50 PM, Weston Andros Adamson wrote:

> Handle ipv6 remote addresses from GETDEVICEINFO
> 
> - supports netid "tcp" for ipv4 and "tcp6" for ipv6 as rfc 5665 specifies
> - added ds_remotestr to avoid having to handle different AFs in every dprintk
> - tested against pynfs 4.1 server, submitting ipv6 support patch to pynfs
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> 
> Update: ds_remotestr now created with the right port -- was missing ntohs, 
>        thanks Tigran!
> 
> NOTE: checkpatch.pl complains about a printk() call in print_ds() that doesn't 
>     include a KERN_ facility level.  I'm not sure if I should change this or 
>     what I should change it to.
> 
> I am also working on parsing and storing multipath info for dataservers, but
> I'm going to treat that as a separate patch
> 
> fs/nfs/nfs4filelayout.c    |    7 +-
> fs/nfs/nfs4filelayout.h    |    5 +-
> fs/nfs/nfs4filelayoutdev.c |  246 ++++++++++++++++++++++++++++++++------------
> 3 files changed, 184 insertions(+), 74 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index be79dc9..583adb3 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -343,8 +343,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
> 		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
> 		return PNFS_NOT_ATTEMPTED;
> 	}
> -	dprintk("%s USE DS:ip %x %hu\n", __func__,
> -		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
> +	dprintk("%s USE DS: %s\n", __func__, ds->ds_remotestr);
> 
> 	/* No multipath support. Use first DS */
> 	data->ds_clp = ds->ds_clp;
> @@ -383,9 +382,9 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
> 		set_bit(lo_fail_bit(IOMODE_READ), &lseg->pls_layout->plh_flags);
> 		return PNFS_NOT_ATTEMPTED;
> 	}
> -	dprintk("%s ino %lu sync %d req %Zu@%llu DS:%x:%hu\n", __func__,
> +	dprintk("%s ino %lu sync %d req %Zu@%llu DS: %s\n", __func__,
> 		data->inode->i_ino, sync, (size_t) data->args.count, offset,
> -		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
> +		ds->ds_remotestr);
> 
> 	data->write_done_cb = filelayout_write_done_cb;
> 	data->ds_clp = ds->ds_clp;
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
> index 2b461d7..1dfd7eb 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/nfs4filelayout.h
> @@ -49,8 +49,9 @@ enum stripetype4 {
> /* Individual ip address */
> struct nfs4_pnfs_ds {
> 	struct list_head	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
> -	u32			ds_ip_addr;
> -	u32			ds_port;
> +	struct sockaddr_storage	ds_addr;
> +	size_t			ds_addrlen;
> +	char			*ds_remotestr;	/* human readable addr+port */
> 	struct nfs_client	*ds_clp;
> 	atomic_t		ds_count;
> };
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index db07c7a..9464640 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -80,11 +80,11 @@ print_ds(struct nfs4_pnfs_ds *ds)
> 		printk("%s NULL device\n", __func__);
> 		return;
> 	}
> -	printk("        ip_addr %x port %hu\n"
> +	printk("        ds %s\n"
> 		"        ref count %d\n"
> 		"        client %p\n"
> 		"        cl_exchange_flags %x\n",
> -		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
> +		ds->ds_remotestr,
> 		atomic_read(&ds->ds_count), ds->ds_clp,
> 		ds->ds_clp ? ds->ds_clp->cl_exchange_flags : 0);
> }
> @@ -112,17 +112,45 @@ void print_deviceid(struct nfs4_deviceid *id)
> 
> /* nfs4_ds_cache_lock is held */
> static struct nfs4_pnfs_ds *
> -_data_server_lookup_locked(u32 ip_addr, u32 port)
> +_data_server_lookup_locked(struct sockaddr *addr, size_t addrlen)
> {
> 	struct nfs4_pnfs_ds *ds;
> -
> -	dprintk("_data_server_lookup: ip_addr=%x port=%hu\n",
> -			ntohl(ip_addr), ntohs(port));
> +	struct sockaddr_in *a, *b;
> +	struct sockaddr_in6 *a6, *b6;
> 
> 	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node) {
> -		if (ds->ds_ip_addr == ip_addr &&
> -		    ds->ds_port == port) {
> -			return ds;
> +		if (addr->sa_family != ds->ds_addr.ss_family)
> +			continue;
> +
> +		switch (addr->sa_family) {
> +		case AF_INET:
> +			a = (struct sockaddr_in *)addr;
> +			b = (struct sockaddr_in *)&ds->ds_addr;
> +
> +			if (a->sin_addr.s_addr == b->sin_addr.s_addr &&
> +			    a->sin_port == b->sin_port)
> +				return ds;
> +			break;
> +
> +		case AF_INET6:
> +			a6 = (struct sockaddr_in6 *)addr;
> +			b6 = (struct sockaddr_in6 *)&ds->ds_addr;
> +
> +			/* LINKLOCAL addresses must have matching scope_id */
> +			if (ipv6_addr_scope(&a6->sin6_addr) ==
> +			    IPV6_ADDR_SCOPE_LINKLOCAL &&
> +			    a6->sin6_scope_id != b6->sin6_scope_id)
> +				continue;
> +
> +			if (ipv6_addr_equal(&a6->sin6_addr, &b6->sin6_addr) &&
> +			    a6->sin6_port == b6->sin6_port)
> +				return ds;
> +			break;
> +
> +		default:
> +			dprintk("%s: unhandled address family: %u\n",
> +				__func__, addr->sa_family);
> +			return NULL;
> 		}
> 	}
> 	return NULL;
> @@ -136,19 +164,14 @@ static int
> nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
> {
> 	struct nfs_client *clp;
> -	struct sockaddr_in sin;
> 	int status = 0;
> 
> -	dprintk("--> %s ip:port %x:%hu au_flavor %d\n", __func__,
> -		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
> +	dprintk("--> %s addr %s au_flavor %d\n", __func__, ds->ds_remotestr,
> 		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
> 
> -	sin.sin_family = AF_INET;
> -	sin.sin_addr.s_addr = ds->ds_ip_addr;
> -	sin.sin_port = ds->ds_port;
> -
> -	clp = nfs4_set_ds_client(mds_srv->nfs_client, (struct sockaddr *)&sin,
> -				 sizeof(sin), IPPROTO_TCP);
> +	clp = nfs4_set_ds_client(mds_srv->nfs_client,
> +				 (struct sockaddr *)&ds->ds_addr,
> +				 ds->ds_addrlen, IPPROTO_TCP);
> 	if (IS_ERR(clp)) {
> 		status = PTR_ERR(clp);
> 		goto out;
> @@ -160,8 +183,8 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
> 			goto out_put;
> 		}
> 		ds->ds_clp = clp;
> -		dprintk("%s [existing] ip=%x, port=%hu\n", __func__,
> -			ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
> +		dprintk("%s [existing] server=%s\n", __func__,
> +			ds->ds_remotestr);
> 		goto out;
> 	}
> 
> @@ -180,8 +203,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
> 		goto out_put;
> 
> 	ds->ds_clp = clp;
> -	dprintk("%s [new] ip=%x, port=%hu\n", __func__, ntohl(ds->ds_ip_addr),
> -		ntohs(ds->ds_port));
> +	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
> out:
> 	return status;
> out_put:
> @@ -198,6 +220,7 @@ destroy_ds(struct nfs4_pnfs_ds *ds)
> 
> 	if (ds->ds_clp)
> 		nfs_put_client(ds->ds_clp);
> +	kfree(ds->ds_remotestr);
> 	kfree(ds);
> }
> 
> @@ -224,8 +247,56 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
> 	kfree(dsaddr);
> }
> 
> +/*
> + * Set ds->ds_remotestr to human readable format of address to avoid
> + * complicated setup around many dprinks().
> + *
> + * As it's only for debugging, this doesn't error out on kmalloc failure and
> + * the remotestr will just be displayed as "(null)"
> + */
> +static void
> +nfs4_pnfs_set_remotestr(struct nfs4_pnfs_ds *ds, gfp_t gfp_flags)
> +{
> +	char buf[INET6_ADDRSTRLEN + IPV6_SCOPE_ID_LEN];
> +	char *startsep = "";
> +	char *endsep = "";
> +	size_t len;
> +	uint16_t port;
> +
> +	switch (ds->ds_addr.ss_family) {
> +	case AF_INET:
> +		port = ((struct sockaddr_in *)&ds->ds_addr)->sin_port;
> +		break;
> +	case AF_INET6:
> +		startsep = "[";
> +		endsep = "]";
> +		port = ((struct sockaddr_in6 *)&ds->ds_addr)->sin6_port;
> +		break;
> +	default:
> +		dprintk("%s: Unknown address family %u\n",
> +			__func__, ds->ds_addr.ss_family);
> +		return;
> +	}
> +
> +	if (!rpc_ntop((struct sockaddr *)&ds->ds_addr, buf, sizeof(buf))) {
> +		dprintk("%s: error printing addr\n", __func__);
> +		return;
> +	}
> +
> +	len = strlen(buf) + strlen(startsep) + strlen(endsep) + 1 + 5 + 1;
> +	ds->ds_remotestr = kzalloc(len, gfp_flags);
> +
> +	if (unlikely(!ds->ds_remotestr)) {
> +		dprintk("%s: couldn't alloc ds_remotestr\n", __func__);
> +		return;
> +	}
> +
> +	snprintf(ds->ds_remotestr, len, "%s%s%s:%u",
> +		 startsep, buf, endsep, ntohs(port));
> +}
> +
> static struct nfs4_pnfs_ds *
> -nfs4_pnfs_ds_add(struct inode *inode, u32 ip_addr, u32 port, gfp_t gfp_flags)
> +nfs4_pnfs_ds_add(struct sockaddr *addr, size_t addrlen, gfp_t gfp_flags)
> {
> 	struct nfs4_pnfs_ds *tmp_ds, *ds;
> 
> @@ -234,21 +305,22 @@ nfs4_pnfs_ds_add(struct inode *inode, u32 ip_addr, u32 port, gfp_t gfp_flags)
> 		goto out;
> 
> 	spin_lock(&nfs4_ds_cache_lock);
> -	tmp_ds = _data_server_lookup_locked(ip_addr, port);
> +	tmp_ds = _data_server_lookup_locked(addr, addrlen);
> 	if (tmp_ds == NULL) {
> -		ds->ds_ip_addr = ip_addr;
> -		ds->ds_port = port;
> +		memcpy(&ds->ds_addr, addr, addrlen);
> +		ds->ds_addrlen = addrlen;
> +		nfs4_pnfs_set_remotestr(ds, gfp_flags);
> 		atomic_set(&ds->ds_count, 1);
> 		INIT_LIST_HEAD(&ds->ds_node);
> 		ds->ds_clp = NULL;
> 		list_add(&ds->ds_node, &nfs4_data_server_cache);
> -		dprintk("%s add new data server ip 0x%x\n", __func__,
> -			ds->ds_ip_addr);
> +		dprintk("%s add new data server %s\n", __func__,
> +			ds->ds_remotestr);
> 	} else {
> 		kfree(ds);
> 		atomic_inc(&tmp_ds->ds_count);
> -		dprintk("%s data server found ip 0x%x, inc'ed ds_count to %d\n",
> -			__func__, tmp_ds->ds_ip_addr,
> +		dprintk("%s data server %s found, inc'ed ds_count to %d\n",
> +			__func__, ds->ds_remotestr,
> 			atomic_read(&tmp_ds->ds_count));
> 		ds = tmp_ds;
> 	}
> @@ -258,18 +330,21 @@ out:
> }
> 
> /*
> - * Currently only support ipv4, and one multi-path address.
> + * Currently only supports ipv4, ipv6 and one multi-path address.
>  */
> static struct nfs4_pnfs_ds *
> decode_and_add_ds(struct xdr_stream *streamp, struct inode *inode, gfp_t gfp_flags)
> {
> 	struct nfs4_pnfs_ds *ds = NULL;
> -	char *buf;
> -	const char *ipend, *pstr;
> -	u32 ip_addr, port;
> +	char *buf, *portstr;
> +	struct sockaddr_storage ss;
> +	size_t sslen;
> +	u32 port;
> 	int nlen, rlen, i;
> 	int tmp[2];
> 	__be32 *p;
> +	char *netid, *match_netid;
> +	size_t match_netid_len;
> 
> 	/* r_netid */
> 	p = xdr_inline_decode(streamp, 4);
> @@ -281,62 +356,97 @@ decode_and_add_ds(struct xdr_stream *streamp, struct inode *inode, gfp_t gfp_fla
> 	if (unlikely(!p))
> 		goto out_err;
> 
> -	/* Check that netid is "tcp" */
> -	if (nlen != 3 ||  memcmp((char *)p, "tcp", 3)) {
> -		dprintk("%s: ERROR: non ipv4 TCP r_netid\n", __func__);
> +	netid = kmalloc(nlen+1, gfp_flags);
> +	if (unlikely(!netid))
> 		goto out_err;
> -	}
> 
> -	/* r_addr */
> +	netid[nlen] = '\0';
> +	memcpy(netid, p, nlen);
> +
> +	/* r_addr: ip/ip6addr with port in dec octets - see RFC 5665 */
> 	p = xdr_inline_decode(streamp, 4);
> 	if (unlikely(!p))
> -		goto out_err;
> +		goto out_free_netid;
> 	rlen = be32_to_cpup(p);
> 
> 	p = xdr_inline_decode(streamp, rlen);
> 	if (unlikely(!p))
> -		goto out_err;
> +		goto out_free_netid;
> 
> -	/* ipv6 length plus port is legal */
> -	if (rlen > INET6_ADDRSTRLEN + 8) {
> +	/* port is ".ABC.DEF", 8 chars max */
> +	if (rlen > INET6_ADDRSTRLEN + IPV6_SCOPE_ID_LEN + 8) {
> 		dprintk("%s: Invalid address, length %d\n", __func__,
> 			rlen);
> -		goto out_err;
> +		goto out_free_netid;
> 	}
> 	buf = kmalloc(rlen + 1, gfp_flags);
> 	if (!buf) {
> 		dprintk("%s: Not enough memory\n", __func__);
> -		goto out_err;
> +		goto out_free_netid;
> 	}
> 	buf[rlen] = '\0';
> 	memcpy(buf, p, rlen);
> 
> -	/* replace the port dots with dashes for the in4_pton() delimiter*/
> -	for (i = 0; i < 2; i++) {
> -		char *res = strrchr(buf, '.');
> -		if (!res) {
> -			dprintk("%s: Failed finding expected dots in port\n",
> -				__func__);
> -			goto out_free;
> -		}
> -		*res = '-';
> +	/* replace port '.' with '-' */
> +	portstr = strrchr(buf, '.');
> +	if (!portstr) {
> +		dprintk("%s: Failed finding expected dot in port\n",
> +			__func__);
> +		goto out_free_buf;
> +	}
> +	*portstr = '-';
> +
> +	/* find '.' between address and port */
> +	portstr = strrchr(buf, '.');
> +	if (!portstr) {
> +		dprintk("%s: Failed finding expected dot between address and "
> +			"port\n", __func__);
> +		goto out_free_buf;
> 	}
> +	*portstr = '\0';
> 
> -	/* Currently only support ipv4 address */
> -	if (in4_pton(buf, rlen, (u8 *)&ip_addr, '-', &ipend) == 0) {
> -		dprintk("%s: Only ipv4 addresses supported\n", __func__);
> -		goto out_free;
> +	if (!rpc_pton(buf, portstr-buf, (struct sockaddr *)&ss, sizeof(ss))) {
> +		dprintk("%s: error parsing address %s\n", __func__, buf);
> +		goto out_free_buf;
> 	}
> 
> -	/* port */
> -	pstr = ipend;
> -	sscanf(pstr, "-%d-%d", &tmp[0], &tmp[1]);
> +	portstr++;
> +	sscanf(portstr, "%d-%d", &tmp[0], &tmp[1]);
> 	port = htons((tmp[0] << 8) | (tmp[1]));
> 
> -	ds = nfs4_pnfs_ds_add(inode, ip_addr, port, gfp_flags);
> -	dprintk("%s: Decoded address and port %s\n", __func__, buf);
> -out_free:
> +	switch (ss.ss_family) {
> +	case AF_INET:
> +		((struct sockaddr_in *)&ss)->sin_port = port;
> +		sslen = sizeof(struct sockaddr_in);
> +		match_netid = "tcp";
> +		match_netid_len = 3;
> +		break;
> +
> +	case AF_INET6:
> +		((struct sockaddr_in6 *)&ss)->sin6_port = port;
> +		sslen = sizeof(struct sockaddr_in6);
> +		match_netid = "tcp6";
> +		match_netid_len = 4;
> +		break;
> +
> +	default:
> +		dprintk("%s: unsupported address family: %u\n",
> +			__func__, ss.ss_family);
> +		break;
> +	}
> +
> +	if (nlen != match_netid_len || strncmp(netid, match_netid, nlen)) {
> +		dprintk("%s: ERROR: r_netid \"%s\" != \"%s\"\n",
> +			__func__, netid, match_netid);
> +		goto out_free_buf;
> +	}
> +
> +	ds = nfs4_pnfs_ds_add((struct sockaddr *)&ss, sslen, gfp_flags);
> +	dprintk("%s: Added DS %s\n", __func__, ds->ds_remotestr);
> +out_free_buf:
> 	kfree(buf);
> +out_free_netid:
> +	kfree(netid);
> out_err:
> 	return ds;
> }
> @@ -674,13 +784,13 @@ nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j)
> 
> static void
> filelayout_mark_devid_negative(struct nfs4_file_layout_dsaddr *dsaddr,
> -			       int err, u32 ds_addr)
> +			       int err, const char *ds_remotestr)
> {
> 	u32 *p = (u32 *)&dsaddr->deviceid;
> 
> -	printk(KERN_ERR "NFS: data server %x connection error %d."
> +	printk(KERN_ERR "NFS: data server %s connection error %d."
> 		" Deviceid [%x%x%x%x] marked out of use.\n",
> -		ds_addr, err, p[0], p[1], p[2], p[3]);
> +		ds_remotestr, err, p[0], p[1], p[2], p[3]);
> 
> 	spin_lock(&filelayout_deviceid_lock);
> 	dsaddr->flags |= NFS4_DEVICE_ID_NEG_ENTRY;
> @@ -711,7 +821,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
> 		err = nfs4_ds_connect(s, ds);
> 		if (err) {
> 			filelayout_mark_devid_negative(dsaddr, err,
> -						       ntohl(ds->ds_ip_addr));
> +						       ds->ds_remotestr);
> 			return NULL;
> 		}
> 	}
> -- 
> 1.7.4.2
> 


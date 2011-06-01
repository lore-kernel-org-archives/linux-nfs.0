From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: Re: [PATCH 2/3] NFS: Parse and store all multipath DS addresses
Date: Wed, 1 Jun 2011 08:38:40 +0200 (CEST)
Message-ID: <alpine.LFD.2.02.1106010835170.4046@mokka>
References: <1306882138-6528-1-git-send-email-dros@netapp.com> <1306882138-6528-3-git-send-email-dros@netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: trond@netapp.com, linux-nfs@vger.kernel.org
To: Weston Andros Adamson <dros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:50307 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab1FAGir (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 02:38:47 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id A36C917C6
	for <linux-nfs@vger.kernel.org>; Wed,  1 Jun 2011 08:38:45 +0200 (MEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 976CC13E91
	for <linux-nfs@vger.kernel.org>; Wed,  1 Jun 2011 08:38:45 +0200 (MEST)
In-Reply-To: <1306882138-6528-3-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 31 May 2011, Weston Andros Adamson wrote:

> Date: Tue, 31 May 2011 18:48:57 -0400
> From: Weston Andros Adamson <dros@netapp.com>
> To: trond@netapp.com
> Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
> Subject: [PATCH 2/3] NFS: Parse and store all multipath DS addresses
> 
> This parses and stores all addresses associated with each data server,
> laying the groundwork for supporting multipath to data servers.
>
> - Skips over addresses that cannot be parsed (ie IPv6 addrs if v6 is not
>   enabled).  Only fails if none of the addresses are recognizable
> - Currently only uses the first address that parsed cleanly
> - Tested against pynfs server (modified to support multipath)
>
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> fs/nfs/nfs4filelayout.h    |   12 +-
> fs/nfs/nfs4filelayoutdev.c |  363 ++++++++++++++++++++++++++++----------------
> 2 files changed, 243 insertions(+), 132 deletions(-)
>
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
> index 6c6a817..68cce73 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/nfs4filelayout.h
> @@ -47,11 +47,17 @@ enum stripetype4 {
> };
>
> /* Individual ip address */
> +struct nfs4_pnfs_ds_addr {
> +	struct sockaddr_storage	da_addr;
> +	size_t			da_addrlen;
> +	struct list_head	da_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
> +	char			*da_remotestr;	/* human readable addr+port */
> +};
> +
> struct nfs4_pnfs_ds {
> 	struct list_head	ds_node;  /* nfs4_pnfs_dev_hlist dev_dslist */
> -	struct sockaddr_storage	ds_addr;
> -	size_t			ds_addrlen;
> -	char			*ds_remotestr;	/* human readable addr+port */
> +	char			*ds_remotestr;	/* comma sep list of addrs */
> +	struct list_head	ds_addrs;
> 	struct nfs_client	*ds_clp;
> 	atomic_t		ds_count;
> };
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 0adb9be..f26c1cf 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -65,53 +65,104 @@ print_ds(struct nfs4_pnfs_ds *ds)
> 		ds->ds_clp ? ds->ds_clp->cl_exchange_flags : 0);
> }
>
> -/* nfs4_ds_cache_lock is held */
> -static struct nfs4_pnfs_ds *
> -_data_server_lookup_locked(struct sockaddr *addr, size_t addrlen)
> +static bool
> +same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
> {
> -	struct nfs4_pnfs_ds *ds;
> 	struct sockaddr_in *a, *b;
> 	struct sockaddr_in6 *a6, *b6;
>
> -	list_for_each_entry(ds, &nfs4_data_server_cache, ds_node) {
> -		if (addr->sa_family != ds->ds_addr.ss_family)
> -			continue;
> -
> -		switch (addr->sa_family) {
> -		case AF_INET:
> -			a = (struct sockaddr_in *)addr;
> -			b = (struct sockaddr_in *)&ds->ds_addr;
> -
> -			if (a->sin_addr.s_addr == b->sin_addr.s_addr &&
> -			    a->sin_port == b->sin_port)
> -				return ds;
> -			break;
> -
> -		case AF_INET6:
> -			a6 = (struct sockaddr_in6 *)addr;
> -			b6 = (struct sockaddr_in6 *)&ds->ds_addr;
> -
> -			/* LINKLOCAL addresses must have matching scope_id */
> -			if (ipv6_addr_scope(&a6->sin6_addr) ==
> -			    IPV6_ADDR_SCOPE_LINKLOCAL &&
> -			    a6->sin6_scope_id != b6->sin6_scope_id)
> -				continue;
> -
> -			if (ipv6_addr_equal(&a6->sin6_addr, &b6->sin6_addr) &&
> -			    a6->sin6_port == b6->sin6_port)
> -				return ds;
> -			break;
> -
> -		default:
> -			dprintk("%s: unhandled address family: %u\n",
> -				__func__, addr->sa_family);
> -			return NULL;
> +	if (addr1->sa_family != addr2->sa_family)
> +		return false;
> +
> +	switch (addr1->sa_family) {
> +	case AF_INET:
> +		a = (struct sockaddr_in *)addr1;
> +		b = (struct sockaddr_in *)addr2;
> +
> +		if (a->sin_addr.s_addr == b->sin_addr.s_addr &&
> +		    a->sin_port == b->sin_port)
> +			return true;
> +		break;
> +
> +	case AF_INET6:
> +		a6 = (struct sockaddr_in6 *)addr1;
> +		b6 = (struct sockaddr_in6 *)addr2;
> +
> +		/* LINKLOCAL addresses must have matching scope_id */
> +		if (ipv6_addr_scope(&a6->sin6_addr) ==
> +		    IPV6_ADDR_SCOPE_LINKLOCAL &&
> +		    a6->sin6_scope_id != b6->sin6_scope_id)
> +			return false;
> +
> +		if (ipv6_addr_equal(&a6->sin6_addr, &b6->sin6_addr) &&
> +		    a6->sin6_port == b6->sin6_port)
> +			return true;
> +		break;
> +
> +	default:
> +		dprintk("%s: unhandled address family: %u\n",
> +			__func__, addr1->sa_family);
> +		return false;
> +	}
> +
> +	return false;
> +}
> +
> +/*
> + * Lookup DS by addresses.  The first matching address returns true.
> + * nfs4_ds_cache_lock is held
> + */
> +static struct nfs4_pnfs_ds *
> +_data_server_lookup_locked(struct list_head *dsaddrs)
> +{
> +	struct nfs4_pnfs_ds *ds;
> +	struct nfs4_pnfs_ds_addr *da1, *da2;
> +
> +	list_for_each_entry(da1, dsaddrs, da_node) {
> +		list_for_each_entry(ds, &nfs4_data_server_cache, ds_node) {
> +			list_for_each_entry(da2, &ds->ds_addrs, da_node) {
> +				if (same_sockaddr(
> +					(struct sockaddr *)&da1->da_addr,
> +					(struct sockaddr *)&da2->da_addr))
> +					return ds;
> +			}
> 		}
> 	}
> 	return NULL;
> }
>
> /*
> + * Compare two lists of addresses.
> + */
> +static bool
> +_data_server_match_all_addrs_locked(struct list_head *dsaddrs1,
> +				    struct list_head *dsaddrs2)
> +{
> +	struct nfs4_pnfs_ds_addr *da1, *da2;
> +	size_t count1 = 0,
> +	       count2 = 0;
> +
> +	list_for_each_entry(da1, dsaddrs1, da_node)
> +		count1++;
> +
> +	list_for_each_entry(da2, dsaddrs2, da_node) {
> +		bool found = false;
> +		count2++;
> +		list_for_each_entry(da1, dsaddrs1, da_node) {
> +			if (same_sockaddr((struct sockaddr *)&da1->da_addr,
> +				(struct sockaddr *)&da2->da_addr)) {
> +				found = true;
> +				break;
> +			}
> +		}
> +		if (!found)
> +			return false;
> +	}
> +
> +	return (count1 == count2);
> +}
> +
> +/*
>  * Create an rpc connection to the nfs4_pnfs_ds data server
>  * Currently only support IPv4

is it still true?

Tigran.
>  */
> @@ -119,14 +170,21 @@ static int
> nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
> {
> 	struct nfs_client *clp;
> +	struct nfs4_pnfs_ds_addr *da;
> 	int status = 0;
>
> -	dprintk("--> %s addr %s au_flavor %d\n", __func__, ds->ds_remotestr,
> +	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
> 		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
>
> +	BUG_ON(list_empty(&ds->ds_addrs));
> +
> +	da = list_first_entry(&ds->ds_addrs, struct nfs4_pnfs_ds_addr, da_node);
> +	dprintk("%s: using the first address for DS %s: %s\n",
> +		__func__, ds->ds_remotestr, da->da_remotestr);
> +
> 	clp = nfs4_set_ds_client(mds_srv->nfs_client,
> -				 (struct sockaddr *)&ds->ds_addr,
> -				 ds->ds_addrlen, IPPROTO_TCP);
> +				 (struct sockaddr *)&da->da_addr,
> +				 da->da_addrlen, IPPROTO_TCP);
> 	if (IS_ERR(clp)) {
> 		status = PTR_ERR(clp);
> 		goto out;
> @@ -169,12 +227,24 @@ out_put:
> static void
> destroy_ds(struct nfs4_pnfs_ds *ds)
> {
> +	struct nfs4_pnfs_ds_addr *da;
> +
> 	dprintk("--> %s\n", __func__);
> 	ifdebug(FACILITY)
> 		print_ds(ds);
>
> 	if (ds->ds_clp)
> 		nfs_put_client(ds->ds_clp);
> +
> +	while (!list_empty(&ds->ds_addrs)) {
> +		da = list_first_entry(&ds->ds_addrs,
> +				      struct nfs4_pnfs_ds_addr,
> +				      da_node);
> +		list_del_init(&da->da_node);
> +		kfree(da->da_remotestr);
> +		kfree(da);
> +	}
> +
> 	kfree(ds->ds_remotestr);
> 	kfree(ds);
> }
> @@ -207,67 +277,73 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
>  * complicated setup around many dprinks.
>  */
> static char *
> -nfs4_pnfs_remotestr(struct sockaddr *ds_addr, gfp_t gfp_flags)
> +nfs4_pnfs_remotestr(struct list_head *dsaddrs, gfp_t gfp_flags)
> {
> -	char buf[INET6_ADDRSTRLEN + IPV6_SCOPE_ID_LEN];
> +	struct nfs4_pnfs_ds_addr *da;
> 	char *remotestr;
> -	char *startsep = "";
> -	char *endsep = "";
> 	size_t len;
> -	uint16_t port;
> +	char *p;
>
> -	switch (ds_addr->sa_family) {
> -	case AF_INET:
> -		port = ((struct sockaddr_in *)ds_addr)->sin_port;
> -		break;
> -	case AF_INET6:
> -		startsep = "[";
> -		endsep = "]";
> -		port = ((struct sockaddr_in6 *)ds_addr)->sin6_port;
> -		break;
> -	default:
> -		dprintk("%s: Unknown address family %u\n",
> -			__func__, ds_addr->sa_family);
> -		return NULL;
> +	len = 3;        /* '{', '}' and eol */
> +	list_for_each_entry(da, dsaddrs, da_node) {
> +		len += strlen(da->da_remotestr) + 1;    /* string plus comma */
> 	}
>
> -	if (!rpc_ntop((struct sockaddr *)ds_addr, buf, sizeof(buf))) {
> -		dprintk("%s: error printing addr\n", __func__);
> +	remotestr = kzalloc(len, gfp_flags);
> +	if (!remotestr)
> 		return NULL;
> -	}
>
> -	len = strlen(buf) + strlen(startsep) + strlen(endsep) + 1 + 5 + 1;
> -	remotestr = kzalloc(len, gfp_flags);
> +	p = remotestr;
> +	*(p++) = '{';
> +	len--;
> +	list_for_each_entry(da, dsaddrs, da_node) {
> +		size_t ll = strlen(da->da_remotestr);
>
> -	if (unlikely(!remotestr)) {
> -		dprintk("%s: couldn't alloc remotestr\n", __func__);
> -		return NULL;
> -	}
> +		if (ll > len)
> +			goto out_err;
>
> -	snprintf(remotestr, len, "%s%s%s:%u",
> -		 startsep, buf, endsep, ntohs(port));
> +		memcpy(p, da->da_remotestr, ll);
> +		p += ll;
> +		len -= ll;
>
> +		if (len < 1)
> +			goto out_err;
> +		(*p++) = ',';
> +		len--;
> +	}
> +	if (len < 2)
> +		goto out_err;
> +	*(p++) = '}';
> +	*p = '\0';
> 	return remotestr;
> +out_err:
> +	kfree(remotestr);
> +	return NULL;
> }
>
> static struct nfs4_pnfs_ds *
> -nfs4_pnfs_ds_add(struct sockaddr *addr, size_t addrlen, gfp_t gfp_flags)
> +nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
> {
> 	struct nfs4_pnfs_ds *tmp_ds, *ds = NULL;
> 	char *remotestr;
>
> -	ds = kzalloc(sizeof(*tmp_ds), gfp_flags);
> +	if (list_empty(dsaddrs)) {
> +		dprintk("%s: no addresses defined\n", __func__);
> +		goto out;
> +	}
> +
> +	ds = kzalloc(sizeof(*ds), gfp_flags);
> 	if (!ds)
> 		goto out;
>
> 	/* this is only used for debugging, so it's ok if its NULL */
> -	remotestr = nfs4_pnfs_remotestr(addr, gfp_flags);
> +	remotestr = nfs4_pnfs_remotestr(dsaddrs, gfp_flags);
>
> 	spin_lock(&nfs4_ds_cache_lock);
> -	tmp_ds = _data_server_lookup_locked(addr, addrlen);
> +	tmp_ds = _data_server_lookup_locked(dsaddrs);
> 	if (tmp_ds == NULL) {
> -		memcpy(&ds->ds_addr, addr, addrlen);
> -		ds->ds_addrlen = addrlen;
> +		INIT_LIST_HEAD(&ds->ds_addrs);
> +		list_splice_init(dsaddrs, &ds->ds_addrs);
> 		ds->ds_remotestr = remotestr;
> 		atomic_set(&ds->ds_count, 1);
> 		INIT_LIST_HEAD(&ds->ds_node);
> @@ -276,6 +352,11 @@ nfs4_pnfs_ds_add(struct sockaddr *addr, size_t addrlen, gfp_t gfp_flags)
> 		dprintk("%s add new data server %s\n", __func__,
> 			ds->ds_remotestr);
> 	} else {
> +		if (!_data_server_match_all_addrs_locked(&tmp_ds->ds_addrs,
> +							 dsaddrs)) {
> +			dprintk("%s:  multipath address mismatch: %s != %s",
> +				__func__, tmp_ds->ds_remotestr, remotestr);
> +		}
> 		kfree(remotestr);
> 		kfree(ds);
> 		atomic_inc(&tmp_ds->ds_count);
> @@ -292,19 +373,20 @@ out:
> /*
>  * Currently only supports ipv4, ipv6 and one multi-path address.
>  */
> -static struct nfs4_pnfs_ds *
> -decode_and_add_ds(struct xdr_stream *streamp, struct inode *inode, gfp_t gfp_flags)
> +static struct nfs4_pnfs_ds_addr *
> +decode_ds_addr(struct xdr_stream *streamp, gfp_t gfp_flags)
> {
> -	struct nfs4_pnfs_ds *ds = NULL;
> +	struct nfs4_pnfs_ds_addr *da = NULL;
> 	char *buf, *portstr;
> -	struct sockaddr_storage ss;
> -	size_t sslen;
> 	u32 port;
> 	int nlen, rlen;
> 	int tmp[2];
> 	__be32 *p;
> 	char *netid, *match_netid;
> -	size_t match_netid_len;
> +	size_t len, match_netid_len;
> +	char *startsep = "";
> +	char *endsep = "";
> +
>
> 	/* r_netid */
> 	p = xdr_inline_decode(streamp, 4);
> @@ -365,50 +447,74 @@ decode_and_add_ds(struct xdr_stream *streamp, struct inode *inode, gfp_t gfp_fla
> 	}
> 	*portstr = '\0';
>
> -	if (!rpc_pton(buf, portstr-buf, (struct sockaddr *)&ss, sizeof(ss))) {
> -		dprintk("%s: Error parsing address %s\n", __func__, buf);
> +	da = kzalloc(sizeof(*da), gfp_flags);
> +	if (unlikely(!da))
> 		goto out_free_buf;
> +
> +	INIT_LIST_HEAD(&da->da_node);
> +
> +	if (!rpc_pton(buf, portstr-buf, (struct sockaddr *)&da->da_addr,
> +		      sizeof(da->da_addr))) {
> +		dprintk("%s: error parsing address %s\n", __func__, buf);
> +		goto out_free_da;
> 	}
>
> 	portstr++;
> 	sscanf(portstr, "%d-%d", &tmp[0], &tmp[1]);
> 	port = htons((tmp[0] << 8) | (tmp[1]));
>
> -	switch (ss.ss_family) {
> +	switch (da->da_addr.ss_family) {
> 	case AF_INET:
> -		((struct sockaddr_in *)&ss)->sin_port = port;
> -		sslen = sizeof(struct sockaddr_in);
> +		((struct sockaddr_in *)&da->da_addr)->sin_port = port;
> +		da->da_addrlen = sizeof(struct sockaddr_in);
> 		match_netid = "tcp";
> 		match_netid_len = 3;
> 		break;
>
> 	case AF_INET6:
> -		((struct sockaddr_in6 *)&ss)->sin6_port = port;
> -		sslen = sizeof(struct sockaddr_in6);
> +		((struct sockaddr_in6 *)&da->da_addr)->sin6_port = port;
> +		da->da_addrlen = sizeof(struct sockaddr_in6);
> 		match_netid = "tcp6";
> 		match_netid_len = 4;
> +		startsep = "[";
> +		endsep = "]";
> 		break;
>
> 	default:
> 		dprintk("%s: unsupported address family: %u\n",
> -			__func__, ss.ss_family);
> -		goto out_free_buf;
> +			__func__, da->da_addr.ss_family);
> +		goto out_free_da;
> 	}
>
> 	if (nlen != match_netid_len || strncmp(netid, match_netid, nlen)) {
> 		dprintk("%s: ERROR: r_netid \"%s\" != \"%s\"\n",
> 			__func__, netid, match_netid);
> -		goto out_free_buf;
> +		goto out_free_da;
> 	}
>
> -	ds = nfs4_pnfs_ds_add((struct sockaddr *)&ss, sslen, gfp_flags);
> -	dprintk("%s: Added DS %s\n", __func__, ds->ds_remotestr);
> +	/* save human readable address */
> +	len = strlen(startsep) + strlen(buf) + strlen(endsep) + 7;
> +	da->da_remotestr = kzalloc(len, gfp_flags);
> +
> +	/* NULL is ok, only used for dprintk */
> +	if (da->da_remotestr)
> +		snprintf(da->da_remotestr, len, "%s%s%s:%u", startsep,
> +			 buf, endsep, ntohs(port));
> +
> +	dprintk("%s: Parsed DS addr %s\n", __func__, da->da_remotestr);
> +	kfree(buf);
> +	kfree(netid);
> +	return da;
> +
> +out_free_da:
> +	kfree(da);
> out_free_buf:
> +	dprintk("%s: Error parsing DS addr: %s\n", __func__, buf);
> 	kfree(buf);
> out_free_netid:
> 	kfree(netid);
> out_err:
> -	return ds;
> +	return NULL;
> }
>
> /* Decode opaque device data and return the result */
> @@ -425,6 +531,8 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
> 	struct xdr_stream stream;
> 	struct xdr_buf buf;
> 	struct page *scratch;
> +	struct list_head dsaddrs;
> +	struct nfs4_pnfs_ds_addr *da;
>
> 	/* set up xdr stream */
> 	scratch = alloc_page(gfp_flags);
> @@ -501,6 +609,8 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
> 				NFS_SERVER(ino)->nfs_client,
> 				&pdev->dev_id);
>
> +	INIT_LIST_HEAD(&dsaddrs);
> +
> 	for (i = 0; i < dsaddr->ds_num; i++) {
> 		int j;
> 		u32 mp_count;
> @@ -510,48 +620,43 @@ decode_device(struct inode *ino, struct pnfs_device *pdev, gfp_t gfp_flags)
> 			goto out_err_free_deviceid;
>
> 		mp_count = be32_to_cpup(p); /* multipath count */
> -		if (mp_count > 1) {
> -			printk(KERN_WARNING
> -			       "%s: Multipath count %d not supported, "
> -			       "skipping all greater than 1\n", __func__,
> -				mp_count);
> -		}
> 		for (j = 0; j < mp_count; j++) {
> -			if (j == 0) {
> -				dsaddr->ds_list[i] = decode_and_add_ds(&stream,
> -					ino, gfp_flags);
> -				if (dsaddr->ds_list[i] == NULL)
> -					goto out_err_free_deviceid;
> -			} else {
> -				u32 len;
> -				/* skip extra multipath */
> -
> -				/* read len, skip */
> -				p = xdr_inline_decode(&stream, 4);
> -				if (unlikely(!p))
> -					goto out_err_free_deviceid;
> -				len = be32_to_cpup(p);
> -
> -				p = xdr_inline_decode(&stream, len);
> -				if (unlikely(!p))
> -					goto out_err_free_deviceid;
> -
> -				/* read len, skip */
> -				p = xdr_inline_decode(&stream, 4);
> -				if (unlikely(!p))
> -					goto out_err_free_deviceid;
> -				len = be32_to_cpup(p);
> -
> -				p = xdr_inline_decode(&stream, len);
> -				if (unlikely(!p))
> -					goto out_err_free_deviceid;
> -			}
> +			da = decode_ds_addr(&stream, gfp_flags);
> +			if (da)
> +				list_add_tail(&da->da_node, &dsaddrs);
> +		}
> +		if (list_empty(&dsaddrs)) {
> +			dprintk("%s: no suitable DS addresses found\n",
> +				__func__);
> +			goto out_err_free_deviceid;
> +		}
> +
> +		dsaddr->ds_list[i] = nfs4_pnfs_ds_add(&dsaddrs, gfp_flags);
> +		if (!dsaddr->ds_list[i])
> +			goto out_err_drain_dsaddrs;
> +
> +		/* If DS was already in cache, free ds addrs */
> +		while (!list_empty(&dsaddrs)) {
> +			da = list_first_entry(&dsaddrs,
> +					      struct nfs4_pnfs_ds_addr,
> +					      da_node);
> +			list_del_init(&da->da_node);
> +			kfree(da->da_remotestr);
> +			kfree(da);
> 		}
> 	}
>
> 	__free_page(scratch);
> 	return dsaddr;
>
> +out_err_drain_dsaddrs:
> +	while (!list_empty(&dsaddrs)) {
> +		da = list_first_entry(&dsaddrs, struct nfs4_pnfs_ds_addr,
> +				      da_node);
> +		list_del_init(&da->da_node);
> +		kfree(da->da_remotestr);
> +		kfree(da);
> +	}
> out_err_free_deviceid:
> 	nfs4_fl_free_deviceid(dsaddr);
> 	/* stripe_indicies was part of dsaddr */
> -- 
> 1.7.5.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

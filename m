Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f175.google.com ([209.85.160.175]:51971 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbbAMTnp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 14:43:45 -0500
Received: by mail-yk0-f175.google.com with SMTP id 200so2311290ykr.6
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jan 2015 11:43:44 -0800 (PST)
Date: Tue, 13 Jan 2015 11:43:41 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 04/49] nfs41: pull decode_ds_addr from file layout to
 generic pnfs
Message-ID: <20150113194341.GC90833@kitty>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
 <1420590534-84063-5-git-send-email-loghyr@primarydata.com>
 <54B3F411.4010604@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54B3F411.4010604@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2015 at 11:19:29AM -0500, Anna Schumaker wrote:
> On 01/06/2015 07:28 PM, Tom Haynes wrote:
> > From: Peng Tao <tao.peng@primarydata.com>
> > 
> > It can be reused by flexfile layout.
> > 
> > Reviewed-by: Jeff Layton <jlayton@primarydata.com>
> > Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> > Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
> > ---
> >  fs/nfs/filelayout/filelayoutdev.c | 152 +------------------------
> >  fs/nfs/pnfs.h                     |   6 +
> >  fs/nfs/pnfs_dev.c                 | 229 ++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 237 insertions(+), 150 deletions(-)
> > 
> > diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
> > index fbfbb70..c7f6041 100644
> > --- a/fs/nfs/filelayout/filelayoutdev.c
> > +++ b/fs/nfs/filelayout/filelayoutdev.c
> > @@ -31,7 +31,6 @@
> >  #include <linux/nfs_fs.h>
> >  #include <linux/vmalloc.h>
> >  #include <linux/module.h>
> > -#include <linux/sunrpc/addr.h>
> >  
> >  #include "../internal.h"
> >  #include "../nfs4session.h"
> > @@ -104,153 +103,6 @@ nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr)
> >  	kfree(dsaddr);
> >  }
> >  
> > -/*
> > - * Currently only supports ipv4, ipv6 and one multi-path address.
> > - */
> > -static struct nfs4_pnfs_ds_addr *
> > -decode_ds_addr(struct net *net, struct xdr_stream *streamp, gfp_t gfp_flags)
> > -{
> > -	struct nfs4_pnfs_ds_addr *da = NULL;
> > -	char *buf, *portstr;
> > -	__be16 port;
> > -	int nlen, rlen;
> > -	int tmp[2];
> > -	__be32 *p;
> > -	char *netid, *match_netid;
> > -	size_t len, match_netid_len;
> > -	char *startsep = "";
> > -	char *endsep = "";
> > -
> > -
> > -	/* r_netid */
> > -	p = xdr_inline_decode(streamp, 4);
> > -	if (unlikely(!p))
> > -		goto out_err;
> > -	nlen = be32_to_cpup(p++);
> > -
> > -	p = xdr_inline_decode(streamp, nlen);
> > -	if (unlikely(!p))
> > -		goto out_err;
> > -
> > -	netid = kmalloc(nlen+1, gfp_flags);
> > -	if (unlikely(!netid))
> > -		goto out_err;
> > -
> > -	netid[nlen] = '\0';
> > -	memcpy(netid, p, nlen);
> > -
> > -	/* r_addr: ip/ip6addr with port in dec octets - see RFC 5665 */
> > -	p = xdr_inline_decode(streamp, 4);
> > -	if (unlikely(!p))
> > -		goto out_free_netid;
> > -	rlen = be32_to_cpup(p);
> > -
> > -	p = xdr_inline_decode(streamp, rlen);
> > -	if (unlikely(!p))
> > -		goto out_free_netid;
> > -
> > -	/* port is ".ABC.DEF", 8 chars max */
> > -	if (rlen > INET6_ADDRSTRLEN + IPV6_SCOPE_ID_LEN + 8) {
> > -		dprintk("%s: Invalid address, length %d\n", __func__,
> > -			rlen);
> > -		goto out_free_netid;
> > -	}
> > -	buf = kmalloc(rlen + 1, gfp_flags);
> > -	if (!buf) {
> > -		dprintk("%s: Not enough memory\n", __func__);
> > -		goto out_free_netid;
> > -	}
> > -	buf[rlen] = '\0';
> > -	memcpy(buf, p, rlen);
> > -
> > -	/* replace port '.' with '-' */
> > -	portstr = strrchr(buf, '.');
> > -	if (!portstr) {
> > -		dprintk("%s: Failed finding expected dot in port\n",
> > -			__func__);
> > -		goto out_free_buf;
> > -	}
> > -	*portstr = '-';
> > -
> > -	/* find '.' between address and port */
> > -	portstr = strrchr(buf, '.');
> > -	if (!portstr) {
> > -		dprintk("%s: Failed finding expected dot between address and "
> > -			"port\n", __func__);
> > -		goto out_free_buf;
> > -	}
> > -	*portstr = '\0';
> > -
> > -	da = kzalloc(sizeof(*da), gfp_flags);
> > -	if (unlikely(!da))
> > -		goto out_free_buf;
> > -
> > -	INIT_LIST_HEAD(&da->da_node);
> > -
> > -	if (!rpc_pton(net, buf, portstr-buf, (struct sockaddr *)&da->da_addr,
> > -		      sizeof(da->da_addr))) {
> > -		dprintk("%s: error parsing address %s\n", __func__, buf);
> > -		goto out_free_da;
> > -	}
> > -
> > -	portstr++;
> > -	sscanf(portstr, "%d-%d", &tmp[0], &tmp[1]);
> > -	port = htons((tmp[0] << 8) | (tmp[1]));
> > -
> > -	switch (da->da_addr.ss_family) {
> > -	case AF_INET:
> > -		((struct sockaddr_in *)&da->da_addr)->sin_port = port;
> > -		da->da_addrlen = sizeof(struct sockaddr_in);
> > -		match_netid = "tcp";
> > -		match_netid_len = 3;
> > -		break;
> > -
> > -	case AF_INET6:
> > -		((struct sockaddr_in6 *)&da->da_addr)->sin6_port = port;
> > -		da->da_addrlen = sizeof(struct sockaddr_in6);
> > -		match_netid = "tcp6";
> > -		match_netid_len = 4;
> > -		startsep = "[";
> > -		endsep = "]";
> > -		break;
> > -
> > -	default:
> > -		dprintk("%s: unsupported address family: %u\n",
> > -			__func__, da->da_addr.ss_family);
> > -		goto out_free_da;
> > -	}
> > -
> > -	if (nlen != match_netid_len || strncmp(netid, match_netid, nlen)) {
> > -		dprintk("%s: ERROR: r_netid \"%s\" != \"%s\"\n",
> > -			__func__, netid, match_netid);
> > -		goto out_free_da;
> > -	}
> > -
> > -	/* save human readable address */
> > -	len = strlen(startsep) + strlen(buf) + strlen(endsep) + 7;
> > -	da->da_remotestr = kzalloc(len, gfp_flags);
> > -
> > -	/* NULL is ok, only used for dprintk */
> > -	if (da->da_remotestr)
> > -		snprintf(da->da_remotestr, len, "%s%s%s:%u", startsep,
> > -			 buf, endsep, ntohs(port));
> > -
> > -	dprintk("%s: Parsed DS addr %s\n", __func__, da->da_remotestr);
> > -	kfree(buf);
> > -	kfree(netid);
> > -	return da;
> > -
> > -out_free_da:
> > -	kfree(da);
> > -out_free_buf:
> > -	dprintk("%s: Error parsing DS addr: %s\n", __func__, buf);
> > -	kfree(buf);
> > -out_free_netid:
> > -	kfree(netid);
> > -out_err:
> > -	return NULL;
> > -}
> > -
> >  /* Decode opaque device data and return the result */
> >  struct nfs4_file_layout_dsaddr *
> >  nfs4_fl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
> > @@ -353,8 +205,8 @@ nfs4_fl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
> >  
> >  		mp_count = be32_to_cpup(p); /* multipath count */
> >  		for (j = 0; j < mp_count; j++) {
> > -			da = decode_ds_addr(server->nfs_client->cl_net,
> > -					    &stream, gfp_flags);
> > +			da = nfs4_decode_mp_ds_addr(server->nfs_client->cl_net,
> > +						    &stream, gfp_flags);
> >  			if (da)
> >  				list_add_tail(&da->da_node, &dsaddrs);
> >  		}
> > diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> > index d0b8e0c..4c53f16 100644
> > --- a/fs/nfs/pnfs.h
> > +++ b/fs/nfs/pnfs.h
> > @@ -295,6 +295,12 @@ void nfs4_deviceid_purge_client(const struct nfs_client *);
> >  void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds);
> >  struct nfs4_pnfs_ds *nfs4_pnfs_ds_add(struct list_head *dsaddrs,
> >  				      gfp_t gfp_flags);
> > +void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
> > +			  struct nfs4_deviceid_node *devid, unsigned int timeo,
> > +			  unsigned int retrans);
> > +struct nfs4_pnfs_ds_addr *nfs4_decode_mp_ds_addr(struct net *net,
> > +						 struct xdr_stream *xdr,
> > +						 gfp_t gfp_flags);
> >  
> >  /* pnfs_nfsio.c */
> >  void pnfs_generic_clear_request_commit(struct nfs_page *req,
> > diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> > index 26d7e8d..a4e33aa 100644
> > --- a/fs/nfs/pnfs_dev.c
> > +++ b/fs/nfs/pnfs_dev.c
> > @@ -29,6 +29,7 @@
> >   */
> >  
> >  #include <linux/export.h>
> > +#include <linux/sunrpc/addr.h>
> >  #include <linux/nfs_fs.h>
> >  #include "nfs4session.h"
> >  #include "internal.h"
> > @@ -598,3 +599,231 @@ out:
> >  	return ds;
> >  }
> >  EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_add);
> > +
> > +static void nfs4_wait_ds_connect(struct nfs4_pnfs_ds *ds)
> > +{
> > +	might_sleep();
> > +	wait_on_bit(&ds->ds_state, NFS4DS_CONNECTING,
> > +			TASK_KILLABLE);
> > +}
> > +
> > +static void nfs4_clear_ds_conn_bit(struct nfs4_pnfs_ds *ds)
> > +{
> > +	smp_mb__before_atomic();
> > +	clear_bit(NFS4DS_CONNECTING, &ds->ds_state);
> > +	smp_mb__after_atomic();
> > +	wake_up_bit(&ds->ds_state, NFS4DS_CONNECTING);
> > +}
> > +
> > +static int _nfs4_pnfs_ds_connect(struct nfs_server *mds_srv,
> > +				 struct nfs4_pnfs_ds *ds,
> > +				 unsigned int timeo,
> > +				 unsigned int retrans)
> > +{
> > +	struct nfs_client *clp = ERR_PTR(-EIO);
> > +	struct nfs4_pnfs_ds_addr *da;
> > +	int status = 0;
> > +
> > +	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
> > +		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
> > +
> > +	list_for_each_entry(da, &ds->ds_addrs, da_node) {
> > +		dprintk("%s: DS %s: trying address %s\n",
> > +			__func__, ds->ds_remotestr, da->da_remotestr);
> > +
> > +		clp = nfs4_set_ds_client(mds_srv->nfs_client,
> > +					(struct sockaddr *)&da->da_addr,
> > +					da->da_addrlen, IPPROTO_TCP,
> > +					timeo, retrans);
> > +		if (!IS_ERR(clp))
> > +			break;
> > +	}
> > +
> > +	if (IS_ERR(clp)) {
> > +		status = PTR_ERR(clp);
> > +		goto out;
> > +	}
> > +
> > +	status = nfs4_init_ds_session(clp, mds_srv->nfs_client->cl_lease_time);
> > +	if (status)
> > +		goto out_put;
> > +
> > +	smp_wmb();
> > +	ds->ds_clp = clp;
> > +	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
> > +out:
> > +	return status;
> > +out_put:
> > +	nfs_put_client(clp);
> > +	goto out;
> > +}
> > +
> > +/*
> > + * Create an rpc connection to the nfs4_pnfs_ds data server.
> > + * Currently only supports IPv4 and IPv6 addresses.
> > + * If connection fails, make devid unavailable.
> > + */
> > +void nfs4_pnfs_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds,
> > +			  struct nfs4_deviceid_node *devid, unsigned int timeo,
> > +			  unsigned int retrans)
> > +{
> > +	if (test_and_set_bit(NFS4DS_CONNECTING, &ds->ds_state) == 0) {
> > +		int err = 0;
> > +
> > +		err = _nfs4_pnfs_ds_connect(mds_srv, ds, timeo, retrans);
> > +		if (err)
> > +			nfs4_mark_deviceid_unavailable(devid);
> > +		nfs4_clear_ds_conn_bit(ds);
> > +	} else {
> > +		nfs4_wait_ds_connect(ds);
> > +	}
> > +}
> > +EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_connect);
> 
> Why are we adding nfs4_pnfs_ds_connect() here?  Shouldn't this be in the next patch?

Okay, moved.

> 
> Thanks,
> Anna
> 
> > +
> > +/*
> > + * Currently only supports ipv4, ipv6 and one multi-path address.
> > + */
> > +struct nfs4_pnfs_ds_addr *
> > +nfs4_decode_mp_ds_addr(struct net *net, struct xdr_stream *xdr, gfp_t gfp_flags)
> > +{
> > +	struct nfs4_pnfs_ds_addr *da = NULL;
> > +	char *buf, *portstr;
> > +	__be16 port;
> > +	int nlen, rlen;
> > +	int tmp[2];
> > +	__be32 *p;
> > +	char *netid, *match_netid;
> > +	size_t len, match_netid_len;
> > +	char *startsep = "";
> > +	char *endsep = "";
> > +
> > +
> > +	/* r_netid */
> > +	p = xdr_inline_decode(xdr, 4);
> > +	if (unlikely(!p))
> > +		goto out_err;
> > +	nlen = be32_to_cpup(p++);
> > +
> > +	p = xdr_inline_decode(xdr, nlen);
> > +	if (unlikely(!p))
> > +		goto out_err;
> > +
> > +	netid = kmalloc(nlen+1, gfp_flags);
> > +	if (unlikely(!netid))
> > +		goto out_err;
> > +
> > +	netid[nlen] = '\0';
> > +	memcpy(netid, p, nlen);
> > +
> > +	/* r_addr: ip/ip6addr with port in dec octets - see RFC 5665 */
> > +	p = xdr_inline_decode(xdr, 4);
> > +	if (unlikely(!p))
> > +		goto out_free_netid;
> > +	rlen = be32_to_cpup(p);
> > +
> > +	p = xdr_inline_decode(xdr, rlen);
> > +	if (unlikely(!p))
> > +		goto out_free_netid;
> > +
> > +	/* port is ".ABC.DEF", 8 chars max */
> > +	if (rlen > INET6_ADDRSTRLEN + IPV6_SCOPE_ID_LEN + 8) {
> > +		dprintk("%s: Invalid address, length %d\n", __func__,
> > +			rlen);
> > +		goto out_free_netid;
> > +	}
> > +	buf = kmalloc(rlen + 1, gfp_flags);
> > +	if (!buf) {
> > +		dprintk("%s: Not enough memory\n", __func__);
> > +		goto out_free_netid;
> > +	}
> > +	buf[rlen] = '\0';
> > +	memcpy(buf, p, rlen);
> > +
> > +	/* replace port '.' with '-' */
> > +	portstr = strrchr(buf, '.');
> > +	if (!portstr) {
> > +		dprintk("%s: Failed finding expected dot in port\n",
> > +			__func__);
> > +		goto out_free_buf;
> > +	}
> > +	*portstr = '-';
> > +
> > +	/* find '.' between address and port */
> > +	portstr = strrchr(buf, '.');
> > +	if (!portstr) {
> > +		dprintk("%s: Failed finding expected dot between address and "
> > +			"port\n", __func__);
> > +		goto out_free_buf;
> > +	}
> > +	*portstr = '\0';
> > +
> > +	da = kzalloc(sizeof(*da), gfp_flags);
> > +	if (unlikely(!da))
> > +		goto out_free_buf;
> > +
> > +	INIT_LIST_HEAD(&da->da_node);
> > +
> > +	if (!rpc_pton(net, buf, portstr-buf, (struct sockaddr *)&da->da_addr,
> > +		      sizeof(da->da_addr))) {
> > +		dprintk("%s: error parsing address %s\n", __func__, buf);
> > +		goto out_free_da;
> > +	}
> > +
> > +	portstr++;
> > +	sscanf(portstr, "%d-%d", &tmp[0], &tmp[1]);
> > +	port = htons((tmp[0] << 8) | (tmp[1]));
> > +
> > +	switch (da->da_addr.ss_family) {
> > +	case AF_INET:
> > +		((struct sockaddr_in *)&da->da_addr)->sin_port = port;
> > +		da->da_addrlen = sizeof(struct sockaddr_in);
> > +		match_netid = "tcp";
> > +		match_netid_len = 3;
> > +		break;
> > +
> > +	case AF_INET6:
> > +		((struct sockaddr_in6 *)&da->da_addr)->sin6_port = port;
> > +		da->da_addrlen = sizeof(struct sockaddr_in6);
> > +		match_netid = "tcp6";
> > +		match_netid_len = 4;
> > +		startsep = "[";
> > +		endsep = "]";
> > +		break;
> > +
> > +	default:
> > +		dprintk("%s: unsupported address family: %u\n",
> > +			__func__, da->da_addr.ss_family);
> > +		goto out_free_da;
> > +	}
> > +
> > +	if (nlen != match_netid_len || strncmp(netid, match_netid, nlen)) {
> > +		dprintk("%s: ERROR: r_netid \"%s\" != \"%s\"\n",
> > +			__func__, netid, match_netid);
> > +		goto out_free_da;
> > +	}
> > +
> > +	/* save human readable address */
> > +	len = strlen(startsep) + strlen(buf) + strlen(endsep) + 7;
> > +	da->da_remotestr = kzalloc(len, gfp_flags);
> > +
> > +	/* NULL is ok, only used for dprintk */
> > +	if (da->da_remotestr)
> > +		snprintf(da->da_remotestr, len, "%s%s%s:%u", startsep,
> > +			 buf, endsep, ntohs(port));
> > +
> > +	dprintk("%s: Parsed DS addr %s\n", __func__, da->da_remotestr);
> > +	kfree(buf);
> > +	kfree(netid);
> > +	return da;
> > +
> > +out_free_da:
> > +	kfree(da);
> > +out_free_buf:
> > +	dprintk("%s: Error parsing DS addr: %s\n", __func__, buf);
> > +	kfree(buf);
> > +out_free_netid:
> > +	kfree(netid);
> > +out_err:
> > +	return NULL;
> > +}
> > +EXPORT_SYMBOL_GPL(nfs4_decode_mp_ds_addr);
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33700 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756643AbbFPOtN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2015 10:49:13 -0400
Received: by padev16 with SMTP id ev16so14237736pad.0
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 07:49:13 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 08/11] pnfs/flexfiles: encode LAYOUTSTATS flexfiles specific data
Date: Tue, 16 Jun 2015 22:47:29 +0800
Message-Id: <1434466052-10491-9-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
References: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 159 ++++++++++++++++++++++++++++++++-
 fs/nfs/flexfilelayout/flexfilelayout.h |   1 +
 2 files changed, 158 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 1efbef5..64beedd 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -275,6 +275,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 
 		spin_lock_init(&fls->mirror_array[i]->lock);
 		fls->mirror_array[i]->ds_count = ds_count;
+		fls->mirror_array[i]->lseg = &fls->generic_hdr;
 
 		/* deviceid */
 		rc = decode_deviceid(&stream, &devid);
@@ -1662,6 +1663,142 @@ out:
 	dprintk("%s: Return\n", __func__);
 }
 
+static int
+ff_layout_ntop4(const struct sockaddr *sap, char *buf, const size_t buflen)
+{
+	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+
+	return snprintf(buf, buflen, "%pI4", &sin->sin_addr);
+}
+
+static size_t
+ff_layout_ntop6_noscopeid(const struct sockaddr *sap, char *buf,
+			  const int buflen)
+{
+	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+	const struct in6_addr *addr = &sin6->sin6_addr;
+
+	/*
+	 * RFC 4291, Section 2.2.2
+	 *
+	 * Shorthanded ANY address
+	 */
+	if (ipv6_addr_any(addr))
+		return snprintf(buf, buflen, "::");
+
+	/*
+	 * RFC 4291, Section 2.2.2
+	 *
+	 * Shorthanded loopback address
+	 */
+	if (ipv6_addr_loopback(addr))
+		return snprintf(buf, buflen, "::1");
+
+	/*
+	 * RFC 4291, Section 2.2.3
+	 *
+	 * Special presentation address format for mapped v4
+	 * addresses.
+	 */
+	if (ipv6_addr_v4mapped(addr))
+		return snprintf(buf, buflen, "::ffff:%pI4",
+					&addr->s6_addr32[3]);
+
+	/*
+	 * RFC 4291, Section 2.2.1
+	 */
+	return snprintf(buf, buflen, "%pI6c", addr);
+}
+
+/* Derived from rpc_sockaddr2uaddr */
+static void
+ff_layout_encode_netaddr(struct xdr_stream *xdr, struct nfs4_pnfs_ds_addr *da)
+{
+	struct sockaddr *sap = (struct sockaddr *)&da->da_addr;
+	char portbuf[RPCBIND_MAXUADDRPLEN];
+	char addrbuf[RPCBIND_MAXUADDRLEN];
+	char *netid;
+	unsigned short port;
+	int len, netid_len;
+	__be32 *p;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		if (ff_layout_ntop4(sap, addrbuf, sizeof(addrbuf)) == 0)
+			return;
+		port = ntohs(((struct sockaddr_in *)sap)->sin_port);
+		netid = "tcp";
+		netid_len = 3;
+		break;
+	case AF_INET6:
+		if (ff_layout_ntop6_noscopeid(sap, addrbuf, sizeof(addrbuf)) == 0)
+			return;
+		port = ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
+		netid = "tcp6";
+		netid_len = 4;
+		break;
+	default:
+		/* we only support tcp and tcp6 */
+		WARN_ON_ONCE(1);
+		return;
+	}
+
+	snprintf(portbuf, sizeof(portbuf), ".%u.%u", port >> 8, port & 0xff);
+	len = strlcat(addrbuf, portbuf, sizeof(addrbuf));
+
+	p = xdr_reserve_space(xdr, 4 + netid_len);
+	xdr_encode_opaque(p, netid, netid_len);
+
+	p = xdr_reserve_space(xdr, 4 + len);
+	xdr_encode_opaque(p, addrbuf, len);
+}
+
+static void
+ff_layout_encode_io_latency(struct xdr_stream *xdr,
+			    struct nfs4_ff_io_stat *stat)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 7 * 8);
+	p = xdr_encode_hyper(p, stat->ops_requested);
+	p = xdr_encode_hyper(p, stat->bytes_requested);
+	p = xdr_encode_hyper(p, stat->ops_completed);
+	p = xdr_encode_hyper(p, stat->bytes_completed);
+	p = xdr_encode_hyper(p, stat->bytes_not_delivered);
+	p = xdr_encode_hyper(p, ktime_to_ns(stat->total_busy_time));
+	p = xdr_encode_hyper(p, ktime_to_ns(stat->aggregate_completion_time));
+}
+
+static void
+ff_layout_encode_layoutstats(struct xdr_stream *xdr,
+			     struct nfs42_layoutstat_args *args,
+			     struct nfs42_layoutstat_devinfo *devinfo)
+{
+	struct nfs4_ff_layout_mirror *mirror = devinfo->layout_private;
+	struct nfs4_pnfs_ds_addr *da;
+	struct nfs4_pnfs_ds *ds = mirror->mirror_ds->ds;
+	struct nfs_fh *fh = &mirror->fh_versions[0];
+	ktime_t total_time;
+	__be32 *p;
+
+	da = list_first_entry(&ds->ds_addrs, struct nfs4_pnfs_ds_addr, da_node);
+	dprintk("%s: DS %s: encoding address %s\n",
+		__func__, ds->ds_remotestr, da->da_remotestr);
+	/* netaddr4 */
+	ff_layout_encode_netaddr(xdr, da);
+	/* nfs_fh4 */
+	p = xdr_reserve_space(xdr, 4 + fh->size);
+	xdr_encode_opaque(p, fh->data, fh->size);
+	/* ff_io_latency4 read */
+	ff_layout_encode_io_latency(xdr, &mirror->read_stat.io_stat);
+	/* ff_io_latency4 write */
+	ff_layout_encode_io_latency(xdr, &mirror->write_stat.io_stat);
+	/* nfstime4 */
+	p = xdr_reserve_space(xdr, 8);
+	total_time = ktime_sub(ktime_get(), mirror->start_time);
+	xdr_encode_hyper(p, total_time.tv64);
+}
+
 static bool
 ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 			       struct pnfs_layout_segment *pls,
@@ -1676,6 +1813,8 @@ ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 		if (*dev_count >= dev_limit)
 			break;
 		mirror = FF_LAYOUT_COMP(pls, i);
+		if (!mirror || !mirror->mirror_ds)
+			continue;
 		dev = FF_LAYOUT_DEVID_NODE(pls, i);
 		devinfo = &args->devinfo[*dev_count];
 		memcpy(&devinfo->dev_id, &dev->deviceid, NFS4_DEVICEID4_SIZE);
@@ -1687,8 +1826,10 @@ ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 		devinfo->write_count = mirror->write_stat.io_stat.bytes_completed;
 		devinfo->write_bytes = mirror->write_stat.io_stat.bytes_completed;
 		devinfo->layout_type = LAYOUT_FLEX_FILES;
-		devinfo->layoutstats_encode = NULL;
-		devinfo->layout_private = NULL;
+		devinfo->layoutstats_encode = ff_layout_encode_layoutstats;
+		devinfo->layout_private = mirror;
+		/* lseg refcount put in cleanup_layoutstats */
+		pnfs_get_lseg(pls);
 
 		++(*dev_count);
 	}
@@ -1731,6 +1872,19 @@ ff_layout_prepare_layoutstats(struct nfs42_layoutstat_args *args)
 	return 0;
 }
 
+static void
+ff_layout_cleanup_layoutstats(struct nfs42_layoutstat_data *data)
+{
+	struct nfs4_ff_layout_mirror *mirror;
+	int i;
+
+	for (i = 0; i < data->args.num_dev; i++) {
+		mirror = data->args.devinfo[i].layout_private;
+		data->args.devinfo[i].layout_private = NULL;
+		pnfs_put_lseg(mirror->lseg);
+	}
+}
+
 static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.id			= LAYOUT_FLEX_FILES,
 	.name			= "LAYOUT_FLEX_FILES",
@@ -1754,6 +1908,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.encode_layoutreturn    = ff_layout_encode_layoutreturn,
 	.sync			= pnfs_nfs_generic_sync,
 	.prepare_layoutstats	= ff_layout_prepare_layoutstats,
+	.cleanup_layoutstats	= ff_layout_cleanup_layoutstats,
 };
 
 static int __init nfs4flexfilelayout_init(void)
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 0e7366f..7e24887 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -75,6 +75,7 @@ struct nfs4_ff_layout_mirror {
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
 	ktime_t				start_time;
+	struct pnfs_layout_segment	*lseg; /* back pointer */
 };
 
 struct nfs4_ff_layout_segment {
-- 
1.8.3.1


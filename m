Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59581 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014Ab2A3U5d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jan 2012 15:57:33 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q0UKvWMa019897
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:57:32 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] [RFC] NFS - filelayout DS rpc mountstats support
Date: Mon, 30 Jan 2012 20:57:21 +0000
Message-ID: <EDF21F60-5390-4CDC-961B-C063D21C7BC8@netapp.com>
References: <1327956820-2772-1-git-send-email-dros@netapp.com>
In-Reply-To: <1327956820-2772-1-git-send-email-dros@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_34996E53-A210-4271-808A-011F41C2D1DE";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_34996E53-A210-4271-808A-011F41C2D1DE
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Jan 30, 2012, at 3:53 PM, Weston Andros Adamson wrote:

> The RPC stats displayed in /self/proc/mountstats are collected in the =
sunrpc
> layer and are collected per rpc_client.  This has worked for NFS thus =
far
> since only one nfs_client (and it's associated rpc_client) was ever =
associated
> with a mountpoint.
>=20
> Now with NFS4.1+PNFS+filelayout, NFS can have more than one nfs_client
> associated with a mountpoint!  Note that the rpc stats are hung off of =
the
> rpc_client - so even if two connections share the same transport, they =
will
> not use the same stats structure (ie when MDS =3D=3D DS).
>=20
> This patch -- admittedly ugly -- poles holes through the PNFS layout =
driver
> to print the stats for rpc_client structures for the dataserver =
connections
> with the filelayout driver.
>=20
> I took the approach of keeping them separate in the =
/proc/self/mountstats
> output to avoid doing too much in the kernel.  If we agree this is the =
way to
> go, I'll update mountstats(1) to combine them for the default output =
(much in
> the same way that averaging is done in userland instead of kernel =
here).
> The alternative is to poke holes in the sunrpc layer to allow =
combining stats.
>=20
> Again, I don't love this solution - it seems like a hack.  The other =
option
> I can see is changing the rpc layer to have support for linking =
several
> rpc_client structures to use the same stat struct, but this would =
likely look
> like a huge hack too.
>=20
> Thoughts?
> ---
> fs/nfs/nfs4filelayout.c    |   19 +++++++++++++++++++
> fs/nfs/nfs4filelayout.h    |    2 ++
> fs/nfs/nfs4filelayoutdev.c |   19 +++++++++++++++++++
> fs/nfs/pnfs.h              |   17 +++++++++++++++++
> fs/nfs/pnfs_dev.c          |   36 ++++++++++++++++++++++++++++++++++++
> fs/nfs/super.c             |    1 +
> 6 files changed, 94 insertions(+), 0 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index b4f8f96..ce20ac3 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -916,6 +916,24 @@ filelayout_free_deveiceid_node(struct =
nfs4_deviceid_node *d)
> 	nfs4_fl_free_deviceid(container_of(d, struct =
nfs4_file_layout_dsaddr, id_node));
> }
>=20
> +static void
> +_rpc_print_iostats_cb(struct nfs4_deviceid_node *d, void *ctx)
> +{
> +	struct seq_file *m;
> +	struct nfs4_file_layout_dsaddr *dsaddr;
> +
> +	m =3D (struct seq_file *)ctx;
> +	dsaddr =3D container_of(d, struct nfs4_file_layout_dsaddr, =
id_node);
> +	nfs4_fl_rpc_print_iostats(m, dsaddr);
> +}
> +
> +static void
> +filelayout_rpc_print_iostats(struct seq_file *m, const struct =
nfs_server *nfss)
> +{
> +	nfs4_foreach_deviceid(nfss->pnfs_curr_ld, nfss->nfs_client,
> +			      _rpc_print_iostats_cb, m);
> +}
> +
> static struct pnfs_layoutdriver_type filelayout_type =3D {
> 	.id			=3D LAYOUT_NFSV4_1_FILES,
> 	.name			=3D "LAYOUT_NFSV4_1_FILES",
> @@ -930,6 +948,7 @@ static struct pnfs_layoutdriver_type =
filelayout_type =3D {
> 	.read_pagelist		=3D filelayout_read_pagelist,
> 	.write_pagelist		=3D filelayout_write_pagelist,
> 	.free_deviceid_node	=3D filelayout_free_deveiceid_node,
> +	.rpc_print_iostats	=3D filelayout_rpc_print_iostats,
> };
>=20
> static int __init nfs4filelayout_init(void)
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
> index 2e42284..6942992 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/nfs4filelayout.h
> @@ -110,6 +110,8 @@ u32 nfs4_fl_calc_j_index(struct =
pnfs_layout_segment *lseg, loff_t offset);
> u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, u32 j);
> struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment =
*lseg,
> 					u32 ds_idx);
> +void nfs4_fl_rpc_print_iostats(struct seq_file *,
> +			       struct nfs4_file_layout_dsaddr *);
> extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr =
*dsaddr);
> extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr =
*dsaddr);
> struct nfs4_file_layout_dsaddr *
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 6eb59b0..1a03a14 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -31,6 +31,8 @@
> #include <linux/nfs_fs.h>
> #include <linux/vmalloc.h>
>=20
> +#include <linux/sunrpc/metrics.h>
> +
> #include "internal.h"
> #include "nfs4filelayout.h"
>=20
> @@ -829,6 +831,23 @@ filelayout_mark_devid_negative(struct =
nfs4_file_layout_dsaddr *dsaddr,
> 	spin_unlock(&nfs4_ds_cache_lock);
> }
>=20
> +void
> +nfs4_fl_rpc_print_iostats(struct seq_file *m,
> +			  struct nfs4_file_layout_dsaddr *dsaddr)
> +{
> +	struct nfs4_pnfs_ds *ds;
> +	u32 i;
> +
> +	for (i =3D 0; i < dsaddr->ds_num; i++) {
> +		ds =3D dsaddr->ds_list[i];
> +
> +		if (ds && ds->ds_clp) {
> +			seq_printf(m, "PNFS Dataserver %s\n", =
ds->ds_remotestr);
> +			rpc_print_iostats(m, ds->ds_clp->cl_rpcclient);
> +		}
> +	}
> +}
> +
> struct nfs4_pnfs_ds *
> nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
> {
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 53d593a..86433d8 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -119,6 +119,9 @@ struct pnfs_layoutdriver_type {
> 	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
> 				     struct xdr_stream *xdr,
> 				     const struct nfs4_layoutcommit_args =
*args);
> +
> +	void (*rpc_print_iostats) (struct seq_file *m,
> +				   const struct nfs_server *nfss);
> };
>=20
> struct pnfs_layout_hdr {
> @@ -231,6 +234,7 @@ struct nfs4_deviceid_node {
>=20
> void nfs4_print_deviceid(const struct nfs4_deviceid *dev_id);
> struct nfs4_deviceid_node *nfs4_find_get_deviceid(const struct =
pnfs_layoutdriver_type *, const struct nfs_client *, const struct =
nfs4_deviceid *);
> +void nfs4_foreach_deviceid(const struct pnfs_layoutdriver_type *, =
const struct nfs_client *, void (*callback)(struct nfs4_deviceid_node *, =
void *), void *);
> void nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *, const =
struct nfs_client *, const struct nfs4_deviceid *);
> void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
> 			     const struct pnfs_layoutdriver_type *,
> @@ -328,6 +332,13 @@ static inline int pnfs_return_layout(struct inode =
*ino)
> 	return 0;
> }
>=20
> +static inline void
> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
> +{
> +	if (pnfs_enabled_sb(nfss) && =
nfss->pnfs_curr_ld->rpc_print_iostats)
> +		nfss->pnfs_curr_ld->rpc_print_iostats(m, nfss);
> +}
> +
> #else  /* CONFIG_NFS_V4_1 */
>=20
> static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
> @@ -429,6 +440,12 @@ static inline int pnfs_layoutcommit_inode(struct =
inode *inode, bool sync)
> static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
> {
> }
> +
> +static inline void
> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
> +{
> +}
> +
> #endif /* CONFIG_NFS_V4_1 */
>=20
> #endif /* FS_NFS_PNFS_H */
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index 4f359d2..5a65668 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -115,6 +115,42 @@ nfs4_find_get_deviceid(const struct =
pnfs_layoutdriver_type *ld,
> }
> EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
>=20
> +
> +/*
> + * Apply callback function to each entry in the cache that matches
> + * the specified layout driver and nfs_client (of the MDS)
> + */
> +void
> +_nfs4_foreach_deviceid(const struct pnfs_layoutdriver_type *ld,
> +		       const struct nfs_client *clp,
> +		       void (*callback)(struct nfs4_deviceid_node *, =
void *),
> +		       void *ctx)
> +{
> +	struct nfs4_deviceid_node *d;
> +	struct hlist_node *n;
> +	long hash;
> +
> +	for (hash =3D 0; hash < NFS4_DEVICE_ID_HASH_SIZE; hash++) {
> +		hlist_for_each_entry_rcu(d, n, =
&nfs4_deviceid_cache[hash], node)
> +			if (d->ld =3D=3D ld && d->nfs_client =3D=3D clp) =
{
> +				if (atomic_read(&d->ref))
> +					callback(d, ctx);
> +			}
> +	}
> +}

FWIW, I'm not thrilled about this :)

> +
> +void
> +nfs4_foreach_deviceid(const struct pnfs_layoutdriver_type *ld,
> +		      const struct nfs_client *clp,
> +		      void (*callback)(struct nfs4_deviceid_node *, void =
*),
> +		      void *ctx)
> +{
> +	rcu_read_lock();
> +	_nfs4_foreach_deviceid(ld, clp, callback, ctx);
> +	rcu_read_unlock();
> +}
> +EXPORT_SYMBOL_GPL(nfs4_foreach_deviceid);
> +
> /*
>  * Remove a deviceid from cache
>  *
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index b79f2a1..5d8e00b 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -869,6 +869,7 @@ static int nfs_show_stats(struct seq_file *m, =
struct dentry *root)
> 	seq_printf(m, "\n");
>=20
> 	rpc_print_iostats(m, nfss->client);
> +	pnfs_rpc_print_iostats(m, nfss);
>=20
> 	return 0;
> }
> --=20
> 1.7.4.4
>=20


--Apple-Mail=_34996E53-A210-4271-808A-011F41C2D1DE
Content-Disposition: attachment; filename="smime.p7s"
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIDTzCCA0sw
ggIzoAMCAQICAQEwCwYJKoZIhvcNAQEFMEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYD
VQQGEwJVUzEeMBwGCSqGSIb3DQEJARYPZHJvc0BuZXRhcHAuY29tMB4XDTExMDYwODIyMDc0NloX
DTEyMDYwNzIyMDc0NlowRjEXMBUGA1UEAwwOV2VzdG9uIEFkYW1zb24xCzAJBgNVBAYTAlVTMR4w
HAYJKoZIhvcNAQkBFg9kcm9zQG5ldGFwcC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC8/tJxtovJEXYRfSsrFOWKHxIZGY7/2mBee1DpWuoGDbVNapefCC7WXe+Nqxz609w2J/Mk
/k3trZ3Ge2NXK0tGnP9NzjkzpGA7rSpM3wUFsvbLMUEGfQpvV24/nYvcLHTvOOEUaDPpHduN94bD
dwvyowzDIRIpF2MeRnOzBNeHkrGHlZdzPmGjm8tkhrDRRkDYHhlxaiG4z30KCfAazxomuINiy1kj
vbndXooYMDoh9H63hgW4NkOedtLdflLa322DXQ3nFU7YbyOIjHVl1tgWJLDWf7WT3lsAB8KvuJZ5
zhsUB+fqxCKPJVRPDO1gjChvvtGiG1tGUUZz0H9Wx00zAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIH
gDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDBDAaBgNVHREEEzARgQ9kcm9zQG5ldGFwcC5jb20wDQYJ
KoZIhvcNAQEFBQADggEBACv0niZSmW+psB1sJXULh3mecDbN2mj0bFpN1YNdjcV7BiOLJ1Rs1ibV
f13h73z8C7SBsPXTM5si8gmJtOnXM5jsgtlql44h/RrjUr8+mtK5DPCZls9J7iz3cGthzwOPvxUj
nMSv3BpRX5oJom5ESgCM9Nn4u/ECTlLMhEIOYnBFiN0eDxcxz+r1cpbHg3r0otIKyxLpeaCjP6AH
F93EHp4T8Rb63y3CcDgxrQGHlTdVi3QvxaMUexUXD81fiA+UqsB/MKmRxB1Hs4Vf3Q/+ejcm78K1
ROF8TNPmNWRlKg3Y7cSFjZGzLuzXsvSsCbw4HLn0oZe/OfgSbarTAxttL5IxggHRMIIBzQIBATBL
MEYxFzAVBgNVBAMMDldlc3RvbiBBZGFtc29uMQswCQYDVQQGEwJVUzEeMBwGCSqGSIb3DQEJARYP
ZHJvc0BuZXRhcHAuY29tAgEBMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcB
MBwGCSqGSIb3DQEJBTEPFw0xMjAxMzAyMDU3MjFaMCMGCSqGSIb3DQEJBDEWBBS6+I7Xg4hH6o1Z
wEhekmgFs2M9MDANBgkqhkiG9w0BAQEFAASCAQAhl03GTOxeIHlAGl1LAbWRgA8zAfU9HuGPKQ/8
eD4nqaw6M8LTncILmWZtm/M/iA6ybg8dxNsfbHIHKs2iTpn/F1YZn2zzXIUtF/tC6K58GkExGUGW
OYVtTHfadYU8W8Nxoej4U6PCFvesMo7SHQXwSVmMSnkV+dpoNpUohEGkSoO8PkZAhdsx74jMuUI/
mF9P3q+PsFKxyLMZJxUXbZL4eGhlySLHBXMP7ek5iS024QwnlbkRYLFgjad24IZpj7+0SCSt1/vb
mKCf4sB50ymMOHl4fDl7oKo3U3PYunbYV6v0HG9JENEqNSKmn0GErhjhKDgWYsnj8RSO9cQbD45v
AAAAAAAA

--Apple-Mail=_34996E53-A210-4271-808A-011F41C2D1DE--

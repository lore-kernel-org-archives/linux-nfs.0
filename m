Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19758 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757086Ab2BITNN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Feb 2012 14:13:13 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Thu, 9 Feb 2012 19:13:01 +0000
Message-ID: <39752416-3EE2-4E32-944C-4F75672C2872@netapp.com>
References: <1328805686-19559-1-git-send-email-dros@netapp.com>
 <1328811417.13180.51.camel@lade.trondhjem.org>
In-Reply-To: <1328811417.13180.51.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_83235068-31FD-4165-AD1C-4266B774810F";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_83235068-31FD-4165-AD1C-4266B774810F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 9, 2012, at 1:16 PM, Myklebust, Trond wrote:

> On Thu, 2012-02-09 at 11:41 -0500, Weston Andros Adamson wrote:
>> Include RPC statistics from all data servers in /proc/self/mountstats =
for pNFS
>> filelayout mounts.
>>=20
>> The additional info printed on the "per-op statistics" line does not =
break
>> current mountstats(8) from nfs-utils.
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>>=20
>> This is clearly a better approach than I was taking trying to keep DS =
rpc stats
>> separate in /proc/self/mountstats.
>>=20
>> FYI, there are no other callers of rpc_print_iostats().
>>=20
>> The new output of /proc/self/mountstats works fine with current =
mountstats=20
>> userland tool.  The additional data on the per-op statistics line =
doesn't make
>> it into the output, but I left it in /proc/self/mountstats because it =
doesn't
>> break anything and can be included in newer versions of mountstats.
>>=20
>> I plan on adding the per-DS stats (rpc and others) somewhere in =
/proc/fs/nfsfs/
>> soon.
>>=20
>> fs/nfs/nfs4filelayout.c        |   30 ++++++++++++++++++++++++++
>> fs/nfs/pnfs.h                  |   23 ++++++++++++++++++++
>> fs/nfs/pnfs_dev.c              |   45 =
++++++++++++++++++++++++++++++++++++++++
>> fs/nfs/super.c                 |    3 +-
>> include/linux/sunrpc/metrics.h |   13 +++++++++-
>> net/sunrpc/stats.c             |   38 =
++++++++++++++++++++++++++++++++-
>> 6 files changed, 147 insertions(+), 5 deletions(-)
>>=20
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 79be7ac..51c71e5 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -33,6 +33,8 @@
>> #include <linux/nfs_page.h>
>> #include <linux/module.h>
>>=20
>> +#include <linux/sunrpc/metrics.h>
>> +
>> #include "internal.h"
>> #include "nfs4filelayout.h"
>>=20
>> @@ -918,6 +920,33 @@ filelayout_free_deveiceid_node(struct =
nfs4_deviceid_node *d)
>> 	nfs4_fl_free_deviceid(container_of(d, struct =
nfs4_file_layout_dsaddr, id_node));
>> }
>>=20
>> +static unsigned int
>> +filelayout_rpc_add_iostats(struct rpc_iostats *total,
>> +			   unsigned int maxproc,
>> +			   struct nfs4_deviceid_node *d)
>> +{
>> +	struct nfs4_file_layout_dsaddr *dsaddr;
>> +	struct nfs4_pnfs_ds *ds;
>> +	unsigned int num_ds =3D 0;
>> +	u32 i;
>> +
>> +	dsaddr =3D container_of(d, struct nfs4_file_layout_dsaddr, =
id_node);
>> +
>> +	for (i =3D 0; i < dsaddr->ds_num; i++) {
>> +		ds =3D dsaddr->ds_list[i];
>> +
>> +		/* only add iostats if nfs_client is different from MDS =
*/
>> +		if (ds && ds->ds_clp && d->nfs_client !=3D ds->ds_clp) {
>> +			struct rpc_clnt *clnt =3D =
ds->ds_clp->cl_rpcclient;
>=20
> Hmmm.... Shouldn't this rather be the NFS_CLIENT(inode)? Also, why not
> do this in the read/write completion code? Why walk the deviceid list =
at
> all?

I'm not really following you.  Note that these are rpc_iostats not =
nfs_iostats. =20
nfs_iostats have been properly counting operations to DSs for some time =
now.
rpc_iostats count operations, rtt, exectime, etc per rpc procedure (or =
in the case of NFSv4.X there is a hack to use operations within =
compounds).

We have to walk the device list to get access to the underlying DS's =
nfs_client->rpc_client -- I can't just put this in the read/write =
completion because, unlike nfs_iostats, rpc_iostats count all operations =
and not just read/write events/bytes (not to mention that the =
accumulation is done at the rpc layer).

I do have an implementation that doesn't need to walk the deviceid list =
by allowing a shared rpc_iostats struct between multiple rpc_clients (in =
addition to the current rpc_iostats structure), but that required adding =
locking and reference counting -- all for printing stats (obviously not =
what we want).

Does that make sense?  If so, I'll repost with the fix from below.

Also, it just occurred to me that you might want me to separate this =
into two patches one for changes in net/sunrpc and one for fs/nfs...

-dros

>=20
>> +			rpc_add_iostats(total, clnt->cl_metrics,
>> +					min(maxproc, clnt->cl_maxproc));
>> +			num_ds++;
>> +		}
>> +	}
>> +
>> +	return num_ds;
>> +}
>> +
>> static struct pnfs_layoutdriver_type filelayout_type =3D {
>> 	.id			=3D LAYOUT_NFSV4_1_FILES,
>> 	.name			=3D "LAYOUT_NFSV4_1_FILES",
>> @@ -932,6 +961,7 @@ static struct pnfs_layoutdriver_type =
filelayout_type =3D {
>> 	.read_pagelist		=3D filelayout_read_pagelist,
>> 	.write_pagelist		=3D filelayout_write_pagelist,
>> 	.free_deviceid_node	=3D filelayout_free_deveiceid_node,
>> +	.ds_rpc_add_iostats	=3D filelayout_rpc_add_iostats,
>> };
>>=20
>> static int __init nfs4filelayout_init(void)
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 53d593a..d1b82eb 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -72,6 +72,7 @@ enum layoutdriver_policy_flags {
>> };
>>=20
>> struct nfs4_deviceid_node;
>> +struct rpc_iostats;
>>=20
>> /* Per-layout driver specific registration structure */
>> struct pnfs_layoutdriver_type {
>> @@ -119,6 +120,9 @@ struct pnfs_layoutdriver_type {
>> 	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
>> 				     struct xdr_stream *xdr,
>> 				     const struct nfs4_layoutcommit_args =
*args);
>> +
>> +	unsigned int (*ds_rpc_add_iostats) (struct rpc_iostats *, =
unsigned int,
>> +					    struct nfs4_deviceid_node =
*);
>> };
>>=20
>> struct pnfs_layout_hdr {
>> @@ -239,6 +243,10 @@ void nfs4_init_deviceid_node(struct =
nfs4_deviceid_node *,
>> struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct =
nfs4_deviceid_node *);
>> bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
>> void nfs4_deviceid_purge_client(const struct nfs_client *);
>> +void nfs4_deviceid_rpc_print_iostats(struct seq_file *seq,
>> +				     const struct nfs_client *clp,
>> +				     const struct pnfs_layoutdriver_type =
*ld);
>> +
>>=20
>> static inline int lo_fail_bit(u32 iomode)
>> {
>> @@ -328,6 +336,15 @@ static inline int pnfs_return_layout(struct =
inode *ino)
>> 	return 0;
>> }
>>=20
>> +static inline int
>> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
>> +{
>> +	if (!pnfs_enabled_sb(nfss))
>> +		return 0;
>> +	nfs4_deviceid_rpc_print_iostats(m, nfss->nfs_client,
>> +					nfss->pnfs_curr_ld);
>> +	return 1;
>> +}
>> #else  /* CONFIG_NFS_V4_1 */
>>=20
>> static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
>> @@ -429,6 +446,12 @@ static inline int pnfs_layoutcommit_inode(struct =
inode *inode, bool sync)
>> static inline void nfs4_deviceid_purge_client(struct nfs_client *ncl)
>> {
>> }
>> +
>> +static inline void
>> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
>> +{
>> +	return 0;
>> +}
>> #endif /* CONFIG_NFS_V4_1 */
>>=20
>> #endif /* FS_NFS_PNFS_H */
>> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
>> index 4f359d2..aa5d102 100644
>> --- a/fs/nfs/pnfs_dev.c
>> +++ b/fs/nfs/pnfs_dev.c
>> @@ -29,6 +29,9 @@
>>  */
>>=20
>> #include <linux/export.h>
>> +
>> +#include <linux/sunrpc/metrics.h>
>> +
>> #include "pnfs.h"
>>=20
>> #define NFSDBG_FACILITY		NFSDBG_PNFS
>> @@ -115,6 +118,48 @@ nfs4_find_get_deviceid(const struct =
pnfs_layoutdriver_type *ld,
>> }
>> EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
>>=20
>> +
>> +void
>> +nfs4_deviceid_rpc_print_iostats(struct seq_file *seq,
>> +				const struct nfs_client *clp,
>> +				const struct pnfs_layoutdriver_type *ld)
>> +{
>> +	struct nfs4_deviceid_node *d;
>> +	struct hlist_node *n;
>> +	struct rpc_iostats *totals;
>> +	char msgbuf[64];
>> +	unsigned int num_ds =3D 0;
>> +	unsigned int maxproc;
>> +	long h;
>> +
>> +	if (!ld->ds_rpc_add_iostats)
>> +		return;
>> +	totals =3D rpc_alloc_iostats(clp->cl_rpcclient);
>> +	if (!totals)
>> +		return;
>> +	maxproc =3D clp->cl_rpcclient->cl_maxproc;
>> +	rpc_add_iostats(totals, clp->cl_rpcclient->cl_metrics, maxproc);
>> +
>> +	rcu_read_lock();
>> +	for (h =3D 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++) {
>> +		hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[h], =
node) {
>> +			if (d->ld =3D=3D ld && d->nfs_client =3D=3D clp) =
{
>> +				if (atomic_read(&d->ref))
>> +					num_ds +=3D =
ld->ds_rpc_add_iostats(totals,
>> +							maxproc, d);
>> +			}
>> +		}
>> +	}
>> +	rcu_read_unlock();
>> +
>> +	snprintf(msgbuf, sizeof(msgbuf),
>> +		 " for the metadata server and %u data server%s", =
num_ds,
>> +		 (num_ds !=3D 1) ? "s" : "");
>> +	rpc_print_iostats(seq, clp->cl_rpcclient, totals, msgbuf);
>> +	rpc_free_iostats(totals);
>> +}
>> +EXPORT_SYMBOL_GPL(nfs4_deviceid_rpc_print_iostats);
>=20
> Is this needed? AFAICS it is used in fs/nfs/super.c, which is in the
> same module (i.e. nfs.ko).

oops!

>=20
>> /*
>>  * Remove a deviceid from cache
>>  *
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index d18a90b..76d0850 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -870,7 +870,8 @@ static int nfs_show_stats(struct seq_file *m, =
struct dentry *root)
>> #endif
>> 	seq_printf(m, "\n");
>>=20
>> -	rpc_print_iostats(m, nfss->client);
>> +	if (!pnfs_rpc_print_iostats(m, nfss))
>> +		rpc_print_iostats(m, nfss->client, NULL, NULL);
>>=20
>> 	return 0;
>> }
>> diff --git a/include/linux/sunrpc/metrics.h =
b/include/linux/sunrpc/metrics.h
>> index b6edbc0..e6e04e4 100644
>> --- a/include/linux/sunrpc/metrics.h
>> +++ b/include/linux/sunrpc/metrics.h
>> @@ -75,14 +75,23 @@ struct rpc_clnt;
>>=20
>> struct rpc_iostats *	rpc_alloc_iostats(struct rpc_clnt *);
>> void			rpc_count_iostats(struct rpc_task *);
>> -void			rpc_print_iostats(struct seq_file *, =
struct rpc_clnt *);
>> +void			rpc_print_iostats(struct seq_file *,
>> +					  struct rpc_clnt *,
>> +					  struct rpc_iostats *,
>> +					  const char *);
>> +void			rpc_add_iostats(struct rpc_iostats *,
>> +					struct rpc_iostats *, unsigned =
int);
>> void			rpc_free_iostats(struct rpc_iostats *);
>>=20
>> #else  /*  CONFIG_PROC_FS  */
>>=20
>> static inline struct rpc_iostats *rpc_alloc_iostats(struct rpc_clnt =
*clnt) { return NULL; }
>> static inline void rpc_count_iostats(struct rpc_task *task) {}
>> -static inline void rpc_print_iostats(struct seq_file *seq, struct =
rpc_clnt *clnt) {}
>> +static inline void rpc_print_iostats(struct seq_file *seq,
>> +				     struct rpc_iostats *stat) {}
>> +static inline void rpc_add_iostats(struct rpc_iostats *total,
>> +				   struct rpc_iostats *new,
>> +				   unsigned int maxproc) {}
>> static inline void rpc_free_iostats(struct rpc_iostats *stats) {}
>>=20
>> #endif  /*  CONFIG_PROC_FS  */
>> diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
>> index 3c4f688..342df57 100644
>> --- a/net/sunrpc/stats.c
>> +++ b/net/sunrpc/stats.c
>> @@ -176,12 +176,16 @@ static void _print_name(struct seq_file *seq, =
unsigned int op,
>> 		seq_printf(seq, "\t%12u: ", op);
>> }
>>=20
>> -void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
>> +void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt,
>> +		       struct rpc_iostats *altstats,
>> +		       const char *altstats_msg)
>> {
>> 	struct rpc_iostats *stats =3D clnt->cl_metrics;
>> 	struct rpc_xprt *xprt =3D clnt->cl_xprt;
>> 	unsigned int op, maxproc =3D clnt->cl_maxproc;
>>=20
>> +	if (altstats)
>> +		stats =3D altstats;
>> 	if (!stats)
>> 		return;
>>=20
>> @@ -192,7 +196,8 @@ void rpc_print_iostats(struct seq_file *seq, =
struct rpc_clnt *clnt)
>> 	if (xprt)
>> 		xprt->ops->print_stats(xprt, seq);
>>=20
>> -	seq_printf(seq, "\tper-op statistics\n");
>> +	seq_printf(seq, "\tper-op statistics%s\n",
>> +		   (altstats && altstats_msg) ? altstats_msg : "");
>> 	for (op =3D 0; op < maxproc; op++) {
>> 		struct rpc_iostats *metrics =3D &stats[op];
>> 		_print_name(seq, op, clnt->cl_procinfo);
>> @@ -209,6 +214,35 @@ void rpc_print_iostats(struct seq_file *seq, =
struct rpc_clnt *clnt)
>> }
>> EXPORT_SYMBOL_GPL(rpc_print_iostats);
>>=20
>> +void
>> +rpc_add_iostats(struct rpc_iostats *totals, struct rpc_iostats *new,
>> +		unsigned int maxproc)
>> +{
>> +	unsigned int op;
>> +
>> +	for (op =3D 0; op < maxproc; op++) {
>> +		struct rpc_iostats *op_totals =3D &totals[op],
>> +				   *op_new =3D &new[op];
>> +
>> +		op_totals->om_ops +=3D op_new->om_ops;
>> +		op_totals->om_ntrans +=3D op_new->om_ntrans;
>> +		op_totals->om_timeouts +=3D op_new->om_timeouts;
>> +
>> +		op_totals->om_bytes_sent +=3D op_new->om_bytes_sent;
>> +		op_totals->om_bytes_recv +=3D op_new->om_bytes_recv;
>> +
>> +		op_totals->om_queue =3D ktime_add(op_totals->om_queue,
>> +					       op_new->om_queue);
>> +
>> +		op_totals->om_rtt =3D ktime_add(op_totals->om_rtt,
>> +					      op_new->om_rtt);
>> +
>> +		op_totals->om_execute =3D =
ktime_add(op_totals->om_execute,
>> +						 op_new->om_execute);
>> +	}
>> +}
>> +EXPORT_SYMBOL_GPL(rpc_add_iostats);
>> +
>> /*
>>  * Register/unregister RPC proc files
>>  */
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer
>=20
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>=20


--Apple-Mail=_83235068-31FD-4165-AD1C-4266B774810F
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDkxOTEzMDFaMCMGCSqGSIb3DQEJBDEWBBSqn5nVg5opPVz9
WCpXJZD3DQRqoDANBgkqhkiG9w0BAQEFAASCAQBlv7gYfWZ7cc7dnCh1fcnuDR4/r2rM/+biexRN
T61uHRi3frSSSdm/zQar6oF5qjCtWn4Aw3OF7w23ZeG5dEgrKHvnl8ukzYkT8DF3KRi5salarxVd
jg+DL5R6keot8qpkavWqz9LwD+HQCWETz5tRec8+x7Gvn0lrVTsvS/fzi3d37Cy0K9gqiwZzwsRe
7yIkwkG2bOflyIF21ZahhfCOQDbMnGrY2DXagEvIsqQnUhVY2IkPRQiEG6tVdPsUvaRB/9T1Pyq9
zg8LdqUT/xncqL5+HnuM0YSYekxCOClZYrPRf8MFb2eGLvwO6+qgwjyHx2vH+M/crA8MtOvBtxf6
AAAAAAAA

--Apple-Mail=_83235068-31FD-4165-AD1C-4266B774810F--

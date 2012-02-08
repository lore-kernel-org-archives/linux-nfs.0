Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490Ab2BHVz7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:55:59 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] RFC: NFS - filelayout DS rpc mountstats support
Date: Wed, 8 Feb 2012 21:55:52 +0000
Message-ID: <17E86459-FBAE-4B06-8611-2C3573DA256D@netapp.com>
References: <1328721042-9335-1-git-send-email-dros@netapp.com>
 <1CFC0549-DFAC-4530-A3A5-876DDAE8C5DE@oracle.com>
 <B22F73F9-8343-4543-922E-26F48AA78A90@netapp.com>
In-Reply-To: <B22F73F9-8343-4543-922E-26F48AA78A90@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_2A811CB4-7E7B-48EE-901C-D0E580F95059";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_2A811CB4-7E7B-48EE-901C-D0E580F95059
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252


On Feb 8, 2012, at 4:04 PM, Adamson, Dros wrote:

>=20
> On Feb 8, 2012, at 12:26 PM, Chuck Lever wrote:
>=20
>> Hi-
>>=20
>> On Feb 8, 2012, at 12:10 PM, Weston Andros Adamson wrote:
>>=20
>>> The per-op stats displayed in /self/proc/mountstats are collected in =
the sunrpc
>>=20
>> You mean /proc/self/mountstats here.
>=20
> oops!
>=20
>>=20
>>> layer and are collected per rpc_client.  This has worked for nfs =
thus far
>>> since only one nfs_client was ever associated with a mountpoint, but =
with
>>> NFS4.1+PNFS+filelayout an nfs mount can have more than one =
nfs_client.
>>>=20
>>> This can be seen with a pnfs mount where no data server is the same =
as the MDS -
>>> all reads, writes and commits will never make it into the current =
mountstats
>>> output.
>>>=20
>>> I took the approach of keeping the stats from the MDS and DSs =
separate in the
>>> /proc/self/mountstats output to avoid doing too much in the kernel, =
and to
>>> expose the fact that these stats are from separate connections =
(maybe for later
>>> use).
>>>=20
>>> This method has issues:
>>>=20
>>> 1) even changing the "statvers" of mountstats doesn't stop the =
userland
>>>  mountstats(8) from trying to parse this output -- and it does so
>>>  incorrectly.
>>=20
>> User land is broken then.  :-)
>=20
> Agreed!

What do you think should happen if statsvers > supported?  Just print an =
error, or print a warning and try to parse anyway?

Thanks!

-dros

>=20
>>=20
>>> 2) when using DS multipath this method fails to count operations =
that happened
>>>  on a different path to the same DS (after a failure).
>=20
> I should have noted that this isn't a problem yet because I haven't =
submitted the multipath failover patches :)
>=20
>>>=20
>>> 3) currently this will display stats twice when DS =3D=3D MDS.
>>=20
>> Why is this case hard to detect in the kernel or in mountstats?
>=20
> Not hard, just an issue with the current patch.
>=20
>>=20
>>>=20
>>> So... What should I do here?
>>>=20
>>> A different approach is to add support in net/sunrpc to specify a =
"parent"
>>> stat structure so that operations on DS nfs_clients bump stats on
>>> the main nfs_server->nfs_client->rpc_client.  This would take care =
of all the
>>> issues with the current patch, but seems like a hack.
>>=20
>> Is this the same as displaying all data in one set of stats?
>=20
> Yes
>=20
>>=20
>> Seems like that might be the best next step, then we can split up the =
MDS and DS stats at some later point.
>=20
> Ok, I'll try to do that.
>=20
> Any advice on how to handle the "xprt: =85" line?  Obviously the =
different underlying rpc_clients will have different values.  I'd have =
to look at mountstats(8) some more, but I *think* we could just make it =
a comma separated list.
>=20
> For the 'next step', we can use this patch - we just need to figure =
out where it should go.  Do we keep it in /proc/self/mountstats?  I =
think because of problem #2 we might want to move them out to somewhere =
in /proc/fs/nfsfs/ along with other per-DS statistics.
>=20
>>=20
>>> One task that seems like a good thing to do is to fix mountstats(8) =
to respect
>>> the "statsvers" value.
>>=20
>> Agree.
>=20
> I'll do this first.
>=20
> Thanks Chuck!
>=20
> -dros
>=20
>>=20
>>>=20
>>> Thoughts?
>>> ---
>>>=20
>>> I cleaned up this patch, but I still have reservations (noted in =
commit message)
>>>=20
>>> fs/nfs/nfs4filelayout.c    |   23 +++++++++++++++++++++++
>>> fs/nfs/pnfs.h              |   20 ++++++++++++++++++++
>>> fs/nfs/pnfs_dev.c          |   25 +++++++++++++++++++++++++
>>> fs/nfs/super.c             |    1 +
>>> include/linux/nfs_iostat.h |    2 +-
>>> 5 files changed, 70 insertions(+), 1 deletions(-)
>>>=20
>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>> index 79be7ac..9410fd0 100644
>>> --- a/fs/nfs/nfs4filelayout.c
>>> +++ b/fs/nfs/nfs4filelayout.c
>>> @@ -33,6 +33,8 @@
>>> #include <linux/nfs_page.h>
>>> #include <linux/module.h>
>>>=20
>>> +#include <linux/sunrpc/metrics.h>
>>> +
>>> #include "internal.h"
>>> #include "nfs4filelayout.h"
>>>=20
>>> @@ -918,6 +920,26 @@ filelayout_free_deveiceid_node(struct =
nfs4_deviceid_node *d)
>>> 	nfs4_fl_free_deviceid(container_of(d, struct =
nfs4_file_layout_dsaddr, id_node));
>>> }
>>>=20
>>> +static void
>>> +filelayout_rpc_print_iostats(struct seq_file *m, struct =
nfs4_deviceid_node *d)
>>> +{
>>> +	struct nfs4_file_layout_dsaddr *dsaddr;
>>> +	struct nfs4_pnfs_ds *ds;
>>> +	u32 i;
>>> +
>>> +	dsaddr =3D container_of(d, struct nfs4_file_layout_dsaddr, =
id_node);
>>> +
>>> +	for (i =3D 0; i < dsaddr->ds_num; i++) {
>>> +		ds =3D dsaddr->ds_list[i];
>>> +
>>> +		if (ds && ds->ds_clp) {
>>> +			seq_printf(m, "  pnfs dataserver %s\n",
>>> +				   ds->ds_remotestr);
>>> +			rpc_print_iostats(m, ds->ds_clp->cl_rpcclient);
>>> +		}
>>> +	}
>>> +}
>>> +
>>> static struct pnfs_layoutdriver_type filelayout_type =3D {
>>> 	.id			=3D LAYOUT_NFSV4_1_FILES,
>>> 	.name			=3D "LAYOUT_NFSV4_1_FILES",
>>> @@ -932,6 +954,7 @@ static struct pnfs_layoutdriver_type =
filelayout_type =3D {
>>> 	.read_pagelist		=3D filelayout_read_pagelist,
>>> 	.write_pagelist		=3D filelayout_write_pagelist,
>>> 	.free_deviceid_node	=3D filelayout_free_deveiceid_node,
>>> +	.ds_rpc_print_iostats	=3D filelayout_rpc_print_iostats,
>>> };
>>>=20
>>> static int __init nfs4filelayout_init(void)
>>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>>> index 53d593a..0a5e020 100644
>>> --- a/fs/nfs/pnfs.h
>>> +++ b/fs/nfs/pnfs.h
>>> @@ -119,6 +119,9 @@ struct pnfs_layoutdriver_type {
>>> 	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
>>> 				     struct xdr_stream *xdr,
>>> 				     const struct nfs4_layoutcommit_args =
*args);
>>> +
>>> +	void (*ds_rpc_print_iostats) (struct seq_file *,
>>> +				      struct nfs4_deviceid_node *);
>>> };
>>>=20
>>> struct pnfs_layout_hdr {
>>> @@ -239,6 +242,10 @@ void nfs4_init_deviceid_node(struct =
nfs4_deviceid_node *,
>>> struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct =
nfs4_deviceid_node *);
>>> bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
>>> void nfs4_deviceid_purge_client(const struct nfs_client *);
>>> +void nfs4_deviceid_rpc_print_iostats(struct seq_file *seq,
>>> +				     const struct nfs_client *clp,
>>> +				     const struct pnfs_layoutdriver_type =
*ld);
>>> +
>>>=20
>>> static inline int lo_fail_bit(u32 iomode)
>>> {
>>> @@ -328,6 +335,14 @@ static inline int pnfs_return_layout(struct =
inode *ino)
>>> 	return 0;
>>> }
>>>=20
>>> +static inline void
>>> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
>>> +{
>>> +	if (!pnfs_enabled_sb(nfss))
>>> +		return;
>>> +	nfs4_deviceid_rpc_print_iostats(m, nfss->nfs_client,
>>> +					nfss->pnfs_curr_ld);
>>> +}
>>> #else  /* CONFIG_NFS_V4_1 */
>>>=20
>>> static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
>>> @@ -429,6 +444,11 @@ static inline int =
pnfs_layoutcommit_inode(struct inode *inode, bool sync)
>>> static inline void nfs4_deviceid_purge_client(struct nfs_client =
*ncl)
>>> {
>>> }
>>> +
>>> +static inline void
>>> +pnfs_rpc_print_iostats(struct seq_file *m, struct nfs_server *nfss)
>>> +{
>>> +}
>>> #endif /* CONFIG_NFS_V4_1 */
>>>=20
>>> #endif /* FS_NFS_PNFS_H */
>>> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
>>> index 4f359d2..277de87 100644
>>> --- a/fs/nfs/pnfs_dev.c
>>> +++ b/fs/nfs/pnfs_dev.c
>>> @@ -115,6 +115,31 @@ nfs4_find_get_deviceid(const struct =
pnfs_layoutdriver_type *ld,
>>> }
>>> EXPORT_SYMBOL_GPL(nfs4_find_get_deviceid);
>>>=20
>>> +
>>> +void
>>> +nfs4_deviceid_rpc_print_iostats(struct seq_file *seq,
>>> +				const struct nfs_client *clp,
>>> +				const struct pnfs_layoutdriver_type *ld)
>>> +{
>>> +	struct nfs4_deviceid_node *d;
>>> +	struct hlist_node *n;
>>> +	long h;
>>> +
>>> +	if (!ld->ds_rpc_print_iostats)
>>> +		return;
>>> +
>>> +	rcu_read_lock();
>>> +	for (h =3D 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++) {
>>> +		hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[h], =
node)
>>> +			if (d->ld =3D=3D ld && d->nfs_client =3D=3D clp) =
{
>>> +				if (atomic_read(&d->ref))
>>> +					ld->ds_rpc_print_iostats(seq, =
d);
>>> +			}
>>> +	}
>>> +	rcu_read_unlock();
>>> +}
>>> +EXPORT_SYMBOL_GPL(nfs4_deviceid_rpc_print_iostats);
>>> +
>>> /*
>>> * Remove a deviceid from cache
>>> *
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index d18a90b..453e496 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -871,6 +871,7 @@ static int nfs_show_stats(struct seq_file *m, =
struct dentry *root)
>>> 	seq_printf(m, "\n");
>>>=20
>>> 	rpc_print_iostats(m, nfss->client);
>>> +	pnfs_rpc_print_iostats(m, nfss);
>>>=20
>>> 	return 0;
>>> }
>>> diff --git a/include/linux/nfs_iostat.h b/include/linux/nfs_iostat.h
>>> index 8866bb3..7fe4605 100644
>>> --- a/include/linux/nfs_iostat.h
>>> +++ b/include/linux/nfs_iostat.h
>>> @@ -21,7 +21,7 @@
>>> #ifndef _LINUX_NFS_IOSTAT
>>> #define _LINUX_NFS_IOSTAT
>>>=20
>>> -#define NFS_IOSTAT_VERS		"1.0"
>>> +#define NFS_IOSTAT_VERS		"2.0"
>>>=20
>>> /*
>>> * NFS byte counters
>>> --=20
>>> 1.7.4.4
>>>=20
>>=20
>> --=20
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>=20
>>=20
>>=20
>>=20
>=20


--Apple-Mail=_2A811CB4-7E7B-48EE-901C-D0E580F95059
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDgyMTU1MDdaMCMGCSqGSIb3DQEJBDEWBBQBP+mRv7qUS9qs
yxmdw2IfzBJFCjANBgkqhkiG9w0BAQEFAASCAQCx+MtMwQMCf9HwTHTJVyukU2qjwJB0O5zzIVP2
U0pM+ikapK5YnZJx+9HHrJGaNFk7rBA+Pk4863TZ9foCwGasMdqLyFbBVp2u3qblBXSZy1hyvb9v
gjv4grhShlHC6ZU/4hynadFq69ozEbvy+Cwwgt8fGbztRVdwDfreUDp4CSBL8KhhVBPy7C1xZ2vS
+ZsZ2d8vkK69ogrJWkMHHQnLaR515ABkVt2CFkDvTKndVCw9EGeLXETP0F3QJo8Seq5sfgBrNxtO
rNHHBVYbygZJYp6Ef5p6utpUhsdSk3WTBxJev9vCekbkH2WAmwf3sJ7PenG9rxyp10Vlk8v3b4DS
AAAAAAAA

--Apple-Mail=_2A811CB4-7E7B-48EE-901C-D0E580F95059--

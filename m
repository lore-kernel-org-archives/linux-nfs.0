Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53655 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932093Ab2BITsu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Feb 2012 14:48:50 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Thu, 9 Feb 2012 19:48:19 +0000
Message-ID: <BAC7F881-0F2D-423D-92FB-DE0F579CC6D6@netapp.com>
References: <1328805686-19559-1-git-send-email-dros@netapp.com>
 <1328811417.13180.51.camel@lade.trondhjem.org>
 <39752416-3EE2-4E32-944C-4F75672C2872@netapp.com>
 <1328815664.13180.60.camel@lade.trondhjem.org>
In-Reply-To: <1328815664.13180.60.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_356F3CE0-E157-4730-B359-B50785300D5B";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_356F3CE0-E157-4730-B359-B50785300D5B
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 9, 2012, at 2:27 PM, Myklebust, Trond wrote:

> On Thu, 2012-02-09 at 19:13 +0000, Adamson, Dros wrote:
>> On Feb 9, 2012, at 1:16 PM, Myklebust, Trond wrote:
>>=20
>>> On Thu, 2012-02-09 at 11:41 -0500, Weston Andros Adamson wrote:
>>>> Include RPC statistics from all data servers in =
/proc/self/mountstats for pNFS
>>>> filelayout mounts.
>>>>=20
>>>> The additional info printed on the "per-op statistics" line does =
not break
>>>> current mountstats(8) from nfs-utils.
>>>>=20
>>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>>> ---
>>>>=20
>>>> This is clearly a better approach than I was taking trying to keep =
DS rpc stats
>>>> separate in /proc/self/mountstats.
>>>>=20
>>>> FYI, there are no other callers of rpc_print_iostats().
>>>>=20
>>>> The new output of /proc/self/mountstats works fine with current =
mountstats=20
>>>> userland tool.  The additional data on the per-op statistics line =
doesn't make
>>>> it into the output, but I left it in /proc/self/mountstats because =
it doesn't
>>>> break anything and can be included in newer versions of mountstats.
>>>>=20
>>>> I plan on adding the per-DS stats (rpc and others) somewhere in =
/proc/fs/nfsfs/
>>>> soon.
>>>>=20
>>>> fs/nfs/nfs4filelayout.c        |   30 ++++++++++++++++++++++++++
>>>> fs/nfs/pnfs.h                  |   23 ++++++++++++++++++++
>>>> fs/nfs/pnfs_dev.c              |   45 =
++++++++++++++++++++++++++++++++++++++++
>>>> fs/nfs/super.c                 |    3 +-
>>>> include/linux/sunrpc/metrics.h |   13 +++++++++-
>>>> net/sunrpc/stats.c             |   38 =
++++++++++++++++++++++++++++++++-
>>>> 6 files changed, 147 insertions(+), 5 deletions(-)
>>>>=20
>>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>>> index 79be7ac..51c71e5 100644
>>>> --- a/fs/nfs/nfs4filelayout.c
>>>> +++ b/fs/nfs/nfs4filelayout.c
>>>> @@ -33,6 +33,8 @@
>>>> #include <linux/nfs_page.h>
>>>> #include <linux/module.h>
>>>>=20
>>>> +#include <linux/sunrpc/metrics.h>
>>>> +
>>>> #include "internal.h"
>>>> #include "nfs4filelayout.h"
>>>>=20
>>>> @@ -918,6 +920,33 @@ filelayout_free_deveiceid_node(struct =
nfs4_deviceid_node *d)
>>>> 	nfs4_fl_free_deviceid(container_of(d, struct =
nfs4_file_layout_dsaddr, id_node));
>>>> }
>>>>=20
>>>> +static unsigned int
>>>> +filelayout_rpc_add_iostats(struct rpc_iostats *total,
>>>> +			   unsigned int maxproc,
>>>> +			   struct nfs4_deviceid_node *d)
>>>> +{
>>>> +	struct nfs4_file_layout_dsaddr *dsaddr;
>>>> +	struct nfs4_pnfs_ds *ds;
>>>> +	unsigned int num_ds =3D 0;
>>>> +	u32 i;
>>>> +
>>>> +	dsaddr =3D container_of(d, struct nfs4_file_layout_dsaddr, =
id_node);
>>>> +
>>>> +	for (i =3D 0; i < dsaddr->ds_num; i++) {
>>>> +		ds =3D dsaddr->ds_list[i];
>>>> +
>>>> +		/* only add iostats if nfs_client is different from MDS =
*/
>>>> +		if (ds && ds->ds_clp && d->nfs_client !=3D ds->ds_clp) {
>>>> +			struct rpc_clnt *clnt =3D =
ds->ds_clp->cl_rpcclient;
>>>=20
>>> Hmmm.... Shouldn't this rather be the NFS_CLIENT(inode)? Also, why =
not
>>> do this in the read/write completion code? Why walk the deviceid =
list at
>>> all?
>>=20
>> I'm not really following you.  Note that these are rpc_iostats not =
nfs_iostats. =20
>> nfs_iostats have been properly counting operations to DSs for some =
time now.
>> rpc_iostats count operations, rtt, exectime, etc per rpc procedure =
(or in the case of NFSv4.X there is a hack to use operations within =
compounds).
>>=20
>> We have to walk the device list to get access to the underlying DS's =
nfs_client->rpc_client -- I can't just put this in the read/write =
completion because, unlike nfs_iostats, rpc_iostats count all operations =
and not just read/write events/bytes (not to mention that the =
accumulation is done at the rpc layer).
>=20
> In doing this, you are assuming that DSes are not shared among =
multiple
> filesystems or MDSes (i.e. that each DS is used by a single struct
> nfs_server). For something like a NetApp filer in c-mode, that is
> clearly not a valid assumption.

True - I had thought of this, but I thought it was fine since I was just =
carrying this assumption forward...

The current mountstats code already prints =
nfs_server->nfs_client->rpc_client->rpc_iostats -- which clearly doesn't =
differentiate between multiple nfs_servers that could be sharing the =
nfs_client.

>=20
>> I do have an implementation that doesn't need to walk the deviceid =
list by allowing a shared rpc_iostats struct between multiple =
rpc_clients (in addition to the current rpc_iostats structure), but that =
required adding locking and reference counting -- all for printing stats =
(obviously not what we want).
>=20
> This might be more in line with what we want. Note that it should be
> easy to clone an rpc_client and then replace its rpc_iostats struct. I
> don't think that needs any extra locking. We're already ignoring =
locking
> here between different rpc_tasks, so throwing in different rpc_clients
> to the mix will make no difference.

Yeah, that's easy enough and i guess we could ignore locking, but we are =
still left with the same problem: how is this supposed to account for =
different mount points using the same nfs_client?  nfs_client only has =
one rpc_client member.  I doubt we want to make a hash lookup on =
nfs_server to get the right rpc_client (which could all use the same =
underlying xprt).

Maybe it's time to move these stats into fs/nfs/ where they really =
belong?  We could get rid of the hack that overloads procnum with opnum =
from inside the compound for v4+ and finally only show a specific =
mount's RPC stats.

Thoughts?

-dros



--Apple-Mail=_356F3CE0-E157-4730-B359-B50785300D5B
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDkxOTQ4MTlaMCMGCSqGSIb3DQEJBDEWBBSm9SA0Aw/CBYgo
B9tvSbQVTHB04jANBgkqhkiG9w0BAQEFAASCAQCra/XaI77BC31N7oE5ADMcEsR33t8uS5cWrtzQ
EDALgvNQdCAQxWlzWnngJ78Wcm/1k4LCGD4j3wODdg3nh+rcc0qOc36iAmqEYv5U1u5jUQF0fUHC
1rw/GG/qf+IH7NQP4QvV8PM4ffVWP3KPza48RaroEbjwY9Gre3uObk3PbiFGHYldiwq3UBhQBHnF
/gQTB2lFsoYtr0ds9Y+EuTM3bj30vHOfKNtBOvN7geENC3ZBpv2MjSIjxUaqYiJePE0ny3+21Pmr
uBHgkLA2E8Stwm1TPuy4tOvf+GoymOTo2Re7tdGbF5gPDWpPpEwdcC+iCY6yniRFP1zfvR/cyZC1
AAAAAAAA

--Apple-Mail=_356F3CE0-E157-4730-B359-B50785300D5B--

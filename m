Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42439 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752509Ab2EISWY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 14:22:24 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q49IMCwq009053
	for <linux-nfs@vger.kernel.org>; Wed, 9 May 2012 11:22:12 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>
Subject: Re: [PATCH] NFS: Prevent a deadlock in the new read and write code
Date: Wed, 9 May 2012 18:22:11 +0000
Message-ID: <31612217-5DE3-43D0-BFAF-40A23530FEC8@netapp.com>
References: <1336582284-8558-1-git-send-email-Trond.Myklebust@netapp.com>
 <A96F9C32-8B2A-441A-BBE9-91747BB585FF@netapp.com>
In-Reply-To: <A96F9C32-8B2A-441A-BBE9-91747BB585FF@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_CD90DF2D-27F5-4F9A-9E8B-A73048006237";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_CD90DF2D-27F5-4F9A-9E8B-A73048006237
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On May 9, 2012, at 2:20 PM, Adamson, Dros wrote:

> ACK - This fixes the errant behavior I was seeing.
>=20
> Before (on any protocol version mounted at /mnt):
> $ dd if=3D/dev/zero of=3Dzerofile bs=3D10024 count=3D1000 ; while =
true; do (rm -rf /mnt/foo && echo rm ok) || ls -la /mnt/foo ; mkdir -p =
/mnt/foo/; cp zerofile /mnt/foo/file ; done
> 1000+0 records in
> 1000+0 records out
> 10024000 bytes (10 MB) copied, 0.146738 s, 68.3 MB/s
> rm ok
> rm: cannot remove `/mnt/foo': Directory not empty
> ls: /mnt/foo/.nfs000000000004089d00000001: No such file or directory
> total 9800
> drwxrwxr-x 2 dros dros     4096 May  9 09:46 .
> drwxrwxrwx 5 root root     4096 May  9 09:46 ..
> -rw-rw-r-- 0 dros dros 10024000 May  9 09:46 =
.nfs000000000004089d00000001
> rm: cannot remove `/mnt/foo': Directory not empty
> ...
>=20

Oops, this is after the patch is applied:

> $ dd if=3D/dev/zero of=3Dzerofile bs=3D10024 count=3D1000 ; while =
true; do (rm -rf /mnt/foo && echo rm ok) || ls -la /mnt/foo ; mkdir -p =
/mnt/foo/; cp zerofile /mnt/foo/file ; done
> 1000+0 records in
> 1000+0 records out
> 10024000 bytes (10 MB) copied, 0.137596 s, 72.9 MB/s
> rm ok
> rm ok
> rm ok
> rm ok
> ...
>=20
> -dros
>=20
> On May 9, 2012, at 12:51 PM, Trond Myklebust wrote:
>=20
>> In order to avoid an ABBA lock ordering issue, the write code must
>> unlock and release the nfs_page _before_ it calls end_page_writeback.
>> Since the last release of the nfs_page will trigger a call to put
>> the open_context, we need to ensure that something else holds a
>> reference to the open context until we're done with the
>> end_page_writeback so that we don't end up calling iput while we're
>> still holding a PG_writeback lock.
>> We can fix this by changing nfs_writedata_release to put the open
>> context after we have processed all the page data.
>>=20
>> The read code does not suffer from the same problem, since it doesn't
>> hold a lock on the nfs_page, so it just calls nfs_release_request =
after
>> unlocking the page itself. However, for symmetry reasons, we make the
>> same change to nfs_readdata_release.
>>=20
>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Cc: Fred Isaman <iisaman@netapp.com>
>> ---
>> fs/nfs/read.c  |    3 ++-
>> fs/nfs/write.c |   13 ++++++++++++-
>> 2 files changed, 14 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>> index f23cf25..dec47e5 100644
>> --- a/fs/nfs/read.c
>> +++ b/fs/nfs/read.c
>> @@ -87,8 +87,8 @@ void nfs_readdata_release(struct nfs_read_data =
*rdata)
>> {
>> 	struct nfs_pgio_header *hdr =3D rdata->header;
>> 	struct nfs_read_header *read_header =3D container_of(hdr, struct =
nfs_read_header, header);
>> +	struct nfs_open_context *ctx =3D rdata->args.context;
>>=20
>> -	put_nfs_open_context(rdata->args.context);
>> 	if (rdata->pages.pagevec !=3D rdata->pages.page_array)
>> 		kfree(rdata->pages.pagevec);
>> 	if (rdata !=3D &read_header->rpc_data)
>> @@ -97,6 +97,7 @@ void nfs_readdata_release(struct nfs_read_data =
*rdata)
>> 		rdata->header =3D NULL;
>> 	if (atomic_dec_and_test(&hdr->refcnt))
>> 		hdr->completion_ops->completion(hdr);
>> +	put_nfs_open_context(ctx);
>> }
>>=20
>> static
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index 6f263da..69825f7 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -119,8 +119,8 @@ void nfs_writedata_release(struct nfs_write_data =
*wdata)
>> {
>> 	struct nfs_pgio_header *hdr =3D wdata->header;
>> 	struct nfs_write_header *write_header =3D container_of(hdr, =
struct nfs_write_header, header);
>> +	struct nfs_open_context *ctx =3D wdata->args.context;
>>=20
>> -	put_nfs_open_context(wdata->args.context);
>> 	if (wdata->pages.pagevec !=3D wdata->pages.page_array)
>> 		kfree(wdata->pages.pagevec);
>> 	if (wdata !=3D &write_header->rpc_data)
>> @@ -129,6 +129,10 @@ void nfs_writedata_release(struct nfs_write_data =
*wdata)
>> 		wdata->header =3D NULL;
>> 	if (atomic_dec_and_test(&hdr->refcnt))
>> 		hdr->completion_ops->completion(hdr);
>> +	/* Note: put the open context after processing all the
>> +	 * page data in order to avoid a deadlock in =
nfs_write_completion.
>> +	 */
>> +	put_nfs_open_context(ctx);
>> }
>>=20
>> static void nfs_context_set_write_error(struct nfs_open_context *ctx, =
int error)
>> @@ -597,6 +601,13 @@ int nfs_write_need_commit(struct nfs_write_data =
*data)
>>=20
>> #endif
>>=20
>> +/*
>> + * nfs_write_completion - process the results of the write RPC calls
>> + *
>> + * Note: this function assumes that the caller is holding a =
reference
>> + * to the nfs_open_context in order to avoid a deadlock when calling
>> + * nfs_end_page_writeback after nfs_unlock_request.
>> + */
>> static void nfs_write_completion(struct nfs_pgio_header *hdr)
>> {
>> 	struct nfs_commit_info cinfo;
>> --=20
>> 1.7.7.6
>>=20
>=20


--Apple-Mail=_CD90DF2D-27F5-4F9A-9E8B-A73048006237
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MDkxODIyMTFaMCMGCSqGSIb3DQEJBDEWBBQ3X4mmDNRHhGoX
DoklaPNy0BtH4TANBgkqhkiG9w0BAQEFAASCAQAzPmL2OquBawE+//gzLNiNsqqSUfRLHvWm0Bkj
MGqYGhoadL8mCi9GKOZ35BTCMuF2wueC8dZ5sTKIsKC6ygMdWnm/hGUD0E3bbFsdEbCFqJwSSgRb
3IDiKuqJdEApzaehjfqZnsEo4TodGAAWT1VDpL/kj1IyuJUsT9ARwRPfvO7Ga5wHjMByKqVcyb54
0AIJQY15l5CbOaUpeV2cP7CYWmKJP6E3KpDzKOGP5UDtTG1zrUgam6Ottlqi/ksYVq/y0GAUtDnp
yfdC36sExTkMWGUNQbSQOUW/9/6t3Om+PNrKJaPg5We0R4NwOncGLQ2Eb7JgJaOL2OPjibhmMUhj
AAAAAAAA

--Apple-Mail=_CD90DF2D-27F5-4F9A-9E8B-A73048006237--

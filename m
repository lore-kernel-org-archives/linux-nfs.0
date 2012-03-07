Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35058 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031282Ab2CGAAr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 19:00:47 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: add crc hash to nfs_display_fhandle
Date: Wed, 7 Mar 2012 00:00:31 +0000
Message-ID: <5CD896A5-70D2-43B0-9FD2-4BBCB707CA46@netapp.com>
References: <1331075875-20421-1-git-send-email-dros@netapp.com>
 <1331076593.10560.51.camel@lade.trondhjem.org>
In-Reply-To: <1331076593.10560.51.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_54AAC554-DDA4-4D0B-B325-4C25F9DF1D2C";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_54AAC554-DDA4-4D0B-B325-4C25F9DF1D2C
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii


On Mar 6, 2012, at 6:29 PM, Myklebust, Trond wrote:

> On Tue, 2012-03-06 at 18:17 -0500, Weston Andros Adamson wrote:
>> Match wireshark's CRC-32 hash for easier debugging.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> Requested by Chuck and others.
>> 
>> Nothing in trond/nfs-for-next uses nfs_display_fhandle() yet.
>> I tested by calling it in nfs4xdr.c:encode_putfh().
>> 
>> fs/nfs/inode.c |    8 +++++++-
>> 1 files changed, 7 insertions(+), 1 deletions(-)
>> 
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 99a4f52..c1f44e9 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -39,6 +39,7 @@
>> #include <linux/slab.h>
>> #include <linux/compat.h>
>> #include <linux/freezer.h>
>> +#include <linux/crc32.h>
>> 
>> #include <asm/system.h>
>> #include <asm/uaccess.h>
>> @@ -1057,13 +1058,18 @@ struct nfs_fh *nfs_alloc_fhandle(void)
>> void _nfs_display_fhandle(const struct nfs_fh *fh, const char *caption)
>> {
>> 	unsigned short i;
>> +	u32 crc;
>> 
>> 	if (fh->size == 0 || fh == NULL) {
>> 		printk(KERN_DEFAULT "%s at %p is empty\n", caption, fh);
>> 		return;
>> 	}
>> 
>> -	printk(KERN_DEFAULT "%s at %p is %u bytes:\n", caption, fh, fh->size);
>> +	/* match wireshark's CRC-32 hash */
>> +	crc = ~crc32(0xFFFFFFFF, &fh->data[0], fh->size);
>> +
>> +	printk(KERN_DEFAULT "%s at %p is %u bytes, crc: 0x%08x:\n",
>> +	                    caption, fh, fh->size, crc);
>> 	for (i = 0; i < fh->size; i += 16) {
>> 		__be32 *pos = (__be32 *)&fh->data[i];
> Could we split this into 2 functions:
> 
> nfs_display_fhandle_hash() and nfs_display_fhandle(), with the latter
> calling the former?
> 
> That will allow us to select both a short form and a full form. I can
> see the former being used in something like nfs_fhget(), or the
> revalidation functions, while the latter would be useful in
> *_proc_lookup() or nfs_instantiate()...

No problem.

-dros
--Apple-Mail=_54AAC554-DDA4-4D0B-B325-4C25F9DF1D2C
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAzMDcwMDAwMzFaMCMGCSqGSIb3DQEJBDEWBBQBQmLw0vxyDqMD
XF526ZKv81abODANBgkqhkiG9w0BAQEFAASCAQAUeToRn02hgmL+XWSAifZ8IhXceVrqREyA1sKv
aSeyog5XhzCGCqzLAveI9wq3w4ntYxTSSLDq70dOo3wrFuPy9M07JSt7Q8vLnDAXwHQNfQg1nVm0
nQGEcxDikYiwwde/ryec1u8Jcyj5W8QE7a3KFpnHtCtzbSSWCbDXxClTC5CYDBz0x+dHIbwWozgc
x8xdcT9K0V4VZHBDk2Lo5SlE6eEJKQpp3frhPWGD7X/ki9ZW5hsa0HIRTVRPO+TyIoDPPGHTXKjH
uqC0bwwPkRxudeW+yWn6Mhn7JxuAtaWm/qepoTmu7QV+vCuzrg1BUJ4g6L5ExmF/r8k7J7JOrHNy
AAAAAAAA

--Apple-Mail=_54AAC554-DDA4-4D0B-B325-4C25F9DF1D2C--

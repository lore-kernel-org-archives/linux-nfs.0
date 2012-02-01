Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45815 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753825Ab2BAXHh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Feb 2012 18:07:37 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: dont allow minorversion= opt when vers != 4
Date: Wed, 1 Feb 2012 23:07:16 +0000
Message-ID: <BD47F92C-6031-4F3F-A715-8275C7399717@netapp.com>
References: <1328123201-894-1-git-send-email-dros@netapp.com>
 <4F29C04B.8020703@panasas.com>
In-Reply-To: <4F29C04B.8020703@panasas.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_DE3ADC2C-E728-4E49-89E8-81FDD390C1A2";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_DE3ADC2C-E728-4E49-89E8-81FDD390C1A2
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Feb 1, 2012, at 5:44 PM, Boaz Harrosh wrote:

> On 02/01/2012 09:06 PM, Weston Andros Adamson wrote:
>> Don't allow invalid 'vers' and 'minorversion' combinations in mount =
options,
>> such as "vers=3D3,minorversion=3D1".
>>=20
>=20
> Just my $0.017 I don't see the point in this.=20
>=20
> If vers=3D=3D3 then minorversion is ignored, just like today.
> What kind  of extra protection does it buy us?

No, minorversion is not ignored when vers=3D3. =20

Try an invalid (v4) minorversion:

$ sudo mount -t nfs -o vers=3D3,minorversion=3D2 server:/export /mnt=20
mount.nfs: an incorrect mount option was specified
$ dmesg | tail -1
[ 1734.758101] NFS: bad mount option value specified: minorversion=3D2

I can understand why this was never a priority, but I find it quite =
confusing when version=3D3,minorversion=3D1 succeeds -- I've =
fat-fingered that more than a few times, started running tests and only =
later realized my mistake.

>=20
> But maybe it's just me
>=20

I know it's not just me who's been confused by this in the past :)

-dros

> Thanks
> Boaz
>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> %d -> %u for printing mnt->version.
>>=20
>> fs/nfs/super.c |    7 +++++++
>> 1 files changed, 7 insertions(+), 0 deletions(-)
>>=20
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 8e210b2..b88e023 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -1519,6 +1519,9 @@ static int nfs_parse_mount_options(char *raw,
>> 	if (!sloppy && invalid_option)
>> 		return 0;
>>=20
>> +	if (mnt->minorversion && mnt->version !=3D 4)
>> +		goto out_minorversion_mismatch;
>> +
>> 	/*
>> 	 * verify that any proto=3D/mountproto=3D options match the =
address
>> 	 * familiies in the addr=3D/mountaddr=3D options.
>> @@ -1552,6 +1555,10 @@ out_invalid_address:
>> out_invalid_value:
>> 	printk(KERN_INFO "NFS: bad mount option value specified: %s\n", =
p);
>> 	return 0;
>> +out_minorversion_mismatch:
>> +	printk(KERN_INFO "NFS: mount option vers=3D%u does not support "
>> +			 "minorversion=3D%u\n", mnt->version, =
mnt->minorversion);
>> +	return 0;
>> out_nomem:
>> 	printk(KERN_INFO "NFS: not enough memory to parse option\n");
>> 	return 0;
>=20


--Apple-Mail=_DE3ADC2C-E728-4E49-89E8-81FDD390C1A2
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDEyMzA3MTdaMCMGCSqGSIb3DQEJBDEWBBQb2V2egGzBt26V
oU/1gBSlEWCX5zANBgkqhkiG9w0BAQEFAASCAQCCQyFvWfl/rbR0nTBd36sYwxgrShgYWU0M1TvH
AymFRoIJu6dAQFDY9a4B7hgE0jCm0f7bH8W2Of2wBMNkGnw4laraCiX/cdY5CTF78sUBYPipwlzJ
pwUUcr3PQQSNnxw9UdDQAkzuuHAfZRbk4OEEL2Z+JjP08bgLcrLRBbzEYVshBQKDPsC0hkg765L9
251Gl71zKXdi3h/kqYCYdDpa3ctfdpXouoRpbSqig14BsKWX/0Mk3EHyzg1306sWCIMZpbEeHEr9
UGg/yY33k50VRXOFa/WMJu3//8CNfsih1kcZ11wHjX7djJWLsZ98QjK6flfd9z1w62XTI5zwpzLA
AAAAAAAA

--Apple-Mail=_DE3ADC2C-E728-4E49-89E8-81FDD390C1A2--

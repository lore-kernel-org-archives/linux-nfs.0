Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31397 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755707Ab2C1PO4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Mar 2012 11:14:56 -0400
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q2SFErit002981
	for <linux-nfs@vger.kernel.org>; Wed, 28 Mar 2012 08:14:55 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4: Fix two infinite loops in the mount code
Date: Wed, 28 Mar 2012 15:14:47 +0000
Message-ID: <74BCDDD5-955E-4C06-9640-47D477A9FF8F@netapp.com>
References: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
 <38AF6CFC-8017-4D08-8DB0-A80BA724E54A@netapp.com>
 <1332947296.11400.7.camel@lade.trondhjem.org>
In-Reply-To: <1332947296.11400.7.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_FD94A6E6-E6EE-40D2-ADE5-09A7959EFE77";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_FD94A6E6-E6EE-40D2-ADE5-09A7959EFE77
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

OK, I need more coffee :)

-dros

On Mar 28, 2012, at 11:08 AM, Myklebust, Trond wrote:

> On Wed, 2012-03-28 at 15:07 +0000, Adamson, Dros wrote:
>> This should probably be sent to stable.
>=20
> See below. :-)
>=20
>> -dros
>>=20
>> On Mar 27, 2012, at 6:35 PM, Trond Myklebust wrote:
>>=20
>>> We can currently loop forever in nfs4_lookup_root() and in
>>> nfs41_proc_secinfo_no_name(), if the first iteration returns a
>>> NFS4ERR_DELAY or something else that causes exception.retry to get
>>> set.
>>>=20
>>> Reported-by: Dros Adamson <Weston.Adamson@netapp.com>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> Cc: stable@vger.kernel.org
>>> ---
>>> fs/nfs/nfs4proc.c |    6 ++++--
>>> 1 files changed, 4 insertions(+), 2 deletions(-)
>>>=20
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 45df7d4..ee9ca19 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -2290,11 +2290,12 @@ static int nfs4_lookup_root(struct =
nfs_server *server, struct nfs_fh *fhandle,
>>> 		switch (err) {
>>> 		case 0:
>>> 		case -NFS4ERR_WRONGSEC:
>>> -			break;
>>> +			goto out;
>>> 		default:
>>> 			err =3D nfs4_handle_exception(server, err, =
&exception);
>>> 		}
>>> 	} while (exception.retry);
>>> +out:
>>> 	return err;
>>> }
>>>=20
>>> @@ -6229,11 +6230,12 @@ nfs41_proc_secinfo_no_name(struct nfs_server =
*server, struct nfs_fh *fhandle,
>>> 		case 0:
>>> 		case -NFS4ERR_WRONGSEC:
>>> 		case -NFS4ERR_NOTSUPP:
>>> -			break;
>>> +			goto out;
>>> 		default:
>>> 			err =3D nfs4_handle_exception(server, err, =
&exception);
>>> 		}
>>> 	} while (exception.retry);
>>> +out:
>>> 	return err;
>>> }
>>>=20
>>> --=20
>>> 1.7.7.6
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer
>=20
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>=20


--Apple-Mail=_FD94A6E6-E6EE-40D2-ADE5-09A7959EFE77
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAzMjgxNTE0NTNaMCMGCSqGSIb3DQEJBDEWBBSNEsSCH0x9AqBJ
zX5dy0F24ytsyzANBgkqhkiG9w0BAQEFAASCAQCB0gj4ECfmV9buRyFQz+VnKF/Yjg1GRu4HFH2n
7EX/gvEG85ypBj9NwC2Ltsmd5U8btAeUpNmHv5ZaGHah/3ACpT+jQbLoTD4cSH4sz/ddDs2v6NAj
2qG/qKIGIa+g3kO7KM01bkA7g78bgkKB/Indz4TFeAXW7oIVictKNVQ4h3ZUn+V6WSmgLH/lABcY
ybFQ0FtfznKQJAoMWTIDUc9nuK/3gD+j//tZZbD3bUO8H9wKkY/p3jOM429uT7nSzsAYv4NXAw1n
xE/C47sI6iZ+AiV5yyBa3LjmdexxHNJE2B9OkWVypM2DQisyT6hs4pX8lo1I8uTmU5f4W3HSSEHV
AAAAAAAA

--Apple-Mail=_FD94A6E6-E6EE-40D2-ADE5-09A7959EFE77--

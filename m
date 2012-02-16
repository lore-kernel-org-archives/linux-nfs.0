Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10118 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754574Ab2BPUoZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 15:44:25 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1GKiLCl025757
	for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 12:44:21 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4: fix server_scope memory leak
Date: Thu, 16 Feb 2012 20:44:15 +0000
Message-ID: <901DD1C3-FEE4-437C-B7E8-C0568B96D949@netapp.com>
References: <1329409026-20466-1-git-send-email-dros@netapp.com>
 <1329409026-20466-2-git-send-email-dros@netapp.com>
 <1329424993.19793.12.camel@lade.trondhjem.org>
In-Reply-To: <1329424993.19793.12.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_E674A939-EC1E-42BB-AE8A-2959EDCA5051";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_E674A939-EC1E-42BB-AE8A-2959EDCA5051
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Feb 16, 2012, at 3:43 PM, Myklebust, Trond wrote:

> On Thu, 2012-02-16 at 11:17 -0500, Weston Andros Adamson wrote:
>> server_scope would never be freed if nfs4_check_cl_exchange_flags() =
returned
>> non-zero
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfs/nfs4proc.c |   15 +++++++++------
>> 1 files changed, 9 insertions(+), 6 deletions(-)
>>=20
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 87c584d..20c3bb0 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -4945,8 +4945,10 @@ int nfs4_proc_exchange_id(struct nfs_client =
*clp, struct rpc_cred *cred)
>> 				clp->cl_rpcclient->cl_auth->au_flavor);
>>=20
>> 	res.server_scope =3D kzalloc(sizeof(struct server_scope), =
GFP_KERNEL);
>> -	if (unlikely(!res.server_scope))
>> -		return -ENOMEM;
>> +	if (unlikely(!res.server_scope)) {
>> +		status =3D -ENOMEM;
>> +		goto out;
>> +	}
>>=20
>> 	status =3D rpc_call_sync(clp->cl_rpcclient, &msg, =
RPC_TASK_TIMEOUT);
>> 	if (!status)
>> @@ -4963,12 +4965,13 @@ int nfs4_proc_exchange_id(struct nfs_client =
*clp, struct rpc_cred *cred)
>> 			clp->server_scope =3D NULL;
>> 		}
>>=20
>> -		if (!clp->server_scope)
>> +		if (!clp->server_scope) {
>> 			clp->server_scope =3D res.server_scope;
>> -		else
>> -			kfree(res.server_scope);
>> +			goto out;
>> +		}
>> 	}
>> -
>> +	kfree(res.server_scope);
>> +out:
>> 	dprintk("<-- %s status=3D %d\n", __func__, status);
>> 	return status;
>> }
>=20
> This looks like it is a bug in existing kernels. Should I queue it up
> for stable@vger.kernel.org?

Yes, I should have mentioned that!

-dros

--Apple-Mail=_E674A939-EC1E-42BB-AE8A-2959EDCA5051
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTYyMDQ0MTZaMCMGCSqGSIb3DQEJBDEWBBQ2k/haEAZ4uIEt
QgK6v1DlV7zD9zANBgkqhkiG9w0BAQEFAASCAQBxWR5QRyxsLzeMI6POIldKvOQn/OZTiUbEyNoh
NNocOXhr+8ilEj7aZSZiKNNMtOq5z4WyP2vwQFMnFz+ftd5CP233FXWDJ4bo5azXhgV7DwAggpeH
u/se0aLt02mJq2RW+N/a3cXQUB1uVVI9A79VairqFlKS6poLdoKVmVw/VNf+ZfCGJGVrNP36fwWb
Gv9QgE6H2OZtqOfct5wBcwDwdDbDFMhC2iIuTXO8Da2L7hnhslxPaX3wU6bCFRIQ/1wisMJZIalt
SFa1nRhGuaKTmGXjApm8q1AC8OHzIW/WoN1CEUYfN5iV3lNxLQpF3MHezQNXOwhdvpQqC/d2xL41
AAAAAAAA

--Apple-Mail=_E674A939-EC1E-42BB-AE8A-2959EDCA5051--

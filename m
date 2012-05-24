Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964803Ab2EXRII (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 13:08:08 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs4.1: add BIND_CONN_TO_SESSION operation
Date: Thu, 24 May 2012 17:07:52 +0000
Message-ID: <44CCA8C0-453D-4729-86E2-0EE6B96BF78B@netapp.com>
References: <1337876797-17706-1-git-send-email-dros@netapp.com>
 <AB759F1A-91C0-4413-B2B9-9F7A9840AC7D@oracle.com>
 <84CCEB7E-7677-4383-B986-C3612D25FB6D@netapp.com>
 <13A8DD85-EBD0-4A6D-9025-2FD83241EBD8@oracle.com>
In-Reply-To: <13A8DD85-EBD0-4A6D-9025-2FD83241EBD8@oracle.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_8B9A71EC-9B8A-45A2-B886-B9729841C44B";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_8B9A71EC-9B8A-45A2-B886-B9729841C44B
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On May 24, 2012, at 1:06 PM, Chuck Lever wrote:

>=20
> On May 24, 2012, at 12:49 PM, Adamson, Dros wrote:
>=20
>>=20
>> On May 24, 2012, at 12:46 PM, Chuck Lever wrote:
>>=20
>>>=20
>>> On May 24, 2012, at 12:26 PM, Weston Andros Adamson wrote:
>>>=20
>>>> This patch adds the BIND_CONN_TO_SESSION operation which is needed =
for
>>>> upcoming SP4_MACH_CRED work and useful for recovering from broken =
connections
>>>> without destroying the session.
>>>>=20
>>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>>> ---
>>>> fs/nfs/nfs4_fs.h        |    1 +
>>>> fs/nfs/nfs4proc.c       |   54 ++++++++++++++++++++++++++++
>>>> fs/nfs/nfs4xdr.c        |   90 =
+++++++++++++++++++++++++++++++++++++++++++++++
>>>> include/linux/nfs4.h    |    5 +++
>>>> include/linux/nfs_xdr.h |    6 +++
>>>> 5 files changed, 156 insertions(+), 0 deletions(-)
>>>=20
>>> [ ... snipped ... ]
>>>=20
>>>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>>>> index 0987146..80fbbfc6 100644
>>>> --- a/include/linux/nfs4.h
>>>> +++ b/include/linux/nfs4.h
>>>> @@ -69,6 +69,10 @@
>>>> #define NFS4_CDFC4_FORE_OR_BOTH 0x3
>>>> #define NFS4_CDFC4_BACK_OR_BOTH 0x7
>>>>=20
>>>> +#define CDFS4_FORE 0x1
>>>> +#define CDFS4_BACK 0x2
>>>> +#define CDFS4_BOTH 0x3
>>>=20
>>> A few more nits:
>>>=20
>>> I'm looking back at the patch I did last year to add =
BIND_CONN_TO_SESS for NFSv4.1 migration support... I used =
NFS4_CDFS4_FORE and so on here, to match the defines in the paragraph =
above.
>>=20
>> Ah, good catch!  I'll change to NFS4_CDFS4_*
>>=20
>>>=20
>>> In the XDR decoder function, I check the "dir_from_server" field to =
ensure it is equal to or less than NFS4_CDFS4_BOTH (-EIO if not).
>>=20
>> Ok, that can't hurt!  Note I'm already returning EIO in the proc =
handler if dir !=3D NFS4_CDFS4_BOTH,
>=20
> Right, that's an implementation-imposed limit.  proc is the right =
place for that.  The XDR check is to sanity check servers, and should =
allow all possible values of that field, and no more.  FWIW.

I'm right there with you :)

-dros

>=20
>> but I think it makes sense to add this sanity check.
>>=20
>> Thanks!
>> -dros
>>=20
>>>=20
>>>> +
>>>> #define NFS4_SET_TO_SERVER_TIME	0
>>>> #define NFS4_SET_TO_CLIENT_TIME	1
>>>>=20
>>>> @@ -582,6 +586,7 @@ enum {
>>>> 	NFSPROC4_CLNT_SECINFO,
>>>>=20
>>>> 	/* nfs41 */
>>>> +	NFSPROC4_CLNT_BIND_CONN_TO_SESSION,
>>>> 	NFSPROC4_CLNT_EXCHANGE_ID,
>>>> 	NFSPROC4_CLNT_CREATE_SESSION,
>>>> 	NFSPROC4_CLNT_DESTROY_SESSION,
>>>=20
>>> --=20
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>>=20
>>>=20
>>>=20
>>>=20
>>=20
>=20
> --=20
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>=20
>=20
>=20
>=20


--Apple-Mail=_8B9A71EC-9B8A-45A2-B886-B9729841C44B
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MjQxNzA3NTNaMCMGCSqGSIb3DQEJBDEWBBSJGZ57C5ZlsvzS
2wgiNbj7NCuVPDANBgkqhkiG9w0BAQEFAASCAQAtMU2cyW9zRqYk8sXCh2QUUuTGGNlIdBMelDlh
bAB0ioirtdySLiqGw5zy1ha/rYMWaq92UYCBBNwQOEuK/7/ie17r9oK+eCsI45sAhZp+N+G1V+cy
M2CBtsh5bwucUxaCJnqvk5WshBuwMSCZJwcHEPaD3Q/qiJjaxYKKRsBlUN74Esp5hbli0Y0F+HUU
MBWjjtMWMLuMj0cOnirPdJOZZXzxCJZofrYeekHfYGCjDJt7LQL38Wi6Yf2ocOgUW4e+1MpC8wq2
ZfA92T8m9BImyfcmKUkx7zt105UZD/N0dPyYaCb3VrlvWrKelGHFFw14I4Hv1j421Qnkv+DMnElI
AAAAAAAA

--Apple-Mail=_8B9A71EC-9B8A-45A2-B886-B9729841C44B--

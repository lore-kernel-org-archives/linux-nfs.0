Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39167 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751890Ab2BBRDq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Feb 2012 12:03:46 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFS: dont allow minorversion= opt when vers != 4
Date: Thu, 2 Feb 2012 17:03:20 +0000
Message-ID: <F797D932-12F4-4063-B46D-0410385A911F@netapp.com>
References: <1328123201-894-1-git-send-email-dros@netapp.com>
 <4F29C04B.8020703@panasas.com>
 <BD47F92C-6031-4F3F-A715-8275C7399717@netapp.com> <4F2A94FA.30603@netapp.com>
In-Reply-To: <4F2A94FA.30603@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_32FA5604-C524-429B-9458-5FBBB1640BB6";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_32FA5604-C524-429B-9458-5FBBB1640BB6
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1


On Feb 2, 2012, at 8:51 AM, Bryan Schumaker wrote:

> On 02/01/12 18:07, Adamson, Dros wrote:
>=20
>> On Feb 1, 2012, at 5:44 PM, Boaz Harrosh wrote:
>>=20
>>> On 02/01/2012 09:06 PM, Weston Andros Adamson wrote:
>>>> Don't allow invalid 'vers' and 'minorversion' combinations in mount =
options,
>>>> such as "vers=3D3,minorversion=3D1".
>>>>=20
>>>=20
>>> Just my $0.017 I don't see the point in this.=20
>>>=20
>>> If vers=3D=3D3 then minorversion is ignored, just like today.
>>> What kind  of extra protection does it buy us?
>>=20
>> No, minorversion is not ignored when vers=3D3. =20
>=20
>=20
> But after mounting, does setting vers=3D3, minorversion=3D1 cause any =
change in NFS v3 behavior?
>=20

No it doesn't.  Past the parsing of options, minorversion is ignored for =
versions other than 4.

I just don't understand how anyone can have problem with this patch.  =
Why would we want to validate minorversion in some cases, but not all =
cases?  How would this patch be a bad thing?

It's about usability -- if this can confuse NFS developers, how are end =
users going to handle it?

-dros=

--Apple-Mail=_32FA5604-C524-429B-9458-5FBBB1640BB6
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDIxNzAzMjBaMCMGCSqGSIb3DQEJBDEWBBQOqStzolKuG7FM
AFtVv98sOiEtFDANBgkqhkiG9w0BAQEFAASCAQBF+S4wiBBPCwkrczhLJ0Tty+0RH3eRHOON80tn
cMlzicuyYRr6KG14bTveDohBdUjHjLepoirOP/RuBbY1A3m2yfAdunfcqWOz6PqDortifrllXB+D
xt4xvVRO/faNDstGJzdQZNKWA5pigeVm5P1Pp5W+qjYNufxXbfy4jelhTtyKFLcuNmKiWQm8vqcw
sSJCkr6b/sBaJXSU8x7z5eLKlc4ELFLVhu8iCuu+Sa4gEQ4lwRTZbj9VDdf5RWcBcozoGTaBEIpd
kRdNcI23osln2DEy43QdfTpRme/T6iZsTGmphUfOcFpKVTvY1OQbn7St2evUwR66vQGEmpdwxeDN
AAAAAAAA

--Apple-Mail=_32FA5604-C524-429B-9458-5FBBB1640BB6--

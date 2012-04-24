Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3740 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755770Ab2DXQUp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 12:20:45 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Jim Rees <rees@umich.edu>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<chuck.lever@oracle.com>" <chuck.lever@oracle.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs4: fix referrals on mounts that use IPv6 addrs
Date: Tue, 24 Apr 2012 16:20:43 +0000
Message-ID: <9B2A7080-EE63-4EE7-B13C-50B51655EDDE@netapp.com>
References: <1335279471-46782-1-git-send-email-dros@netapp.com>
 <20120424151924.GA13191@umich.edu>
In-Reply-To: <20120424151924.GA13191@umich.edu>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_1FCCD454-132B-42D1-985D-6ABDF54BEB51";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_1FCCD454-132B-42D1-985D-6ABDF54BEB51
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Apr 24, 2012, at 11:19 AM, Jim Rees wrote:

> Weston Andros Adamson wrote:
>=20
>  diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
>  index 9c8eca3..307743d 100644
>  --- a/fs/nfs/nfs4namespace.c
>  +++ b/fs/nfs/nfs4namespace.c
>  @@ -52,6 +52,35 @@ Elong:
>   }
>=20
>   /*
>  + * parse the path component of an nfs path ("<server>:<path>").
>  + *  nfspath - the "<server>:<path>" string
>  + *  end - pointer to end of devname component of 'nfspath'
>  + * returns NULL on failure
>  + */
>=20
> The comment seems odd to me.  You're not parsing the path component, =
you're
> parsing the nfspath to return the path.  And the term "devname =
component"
> hasn't been defined anywhere.  How about this:
>=20
> Return the path component of an nfs path ("<server>:<path>").

Yeah, OK.

> nfspath - the "<server>:<path>" string
> end - pointer to end of nfspath

Well, that's not really true.  "end" comes from the call to nfs_path() =
and points to the end of the devname component of the nfs_path, i.e.:

if "[fc00::10]:/export" is mounted:

[fc00::10]:/export/foo/bar
                  ^end

> returns NULL on failure

-dros=

--Apple-Mail=_1FCCD454-132B-42D1-985D-6ABDF54BEB51
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA0MjQxNjIwNDNaMCMGCSqGSIb3DQEJBDEWBBR19I2W1D9meT4P
l+G81R/muUHC6DANBgkqhkiG9w0BAQEFAASCAQCuaISAAiNe4Y6IXbWqf5ihNQI6gENEbJayjCtP
n4gcVMtJTjaGS8YWe4QW4TVL9gGHTnHdfeZIpppnrasfvds7GPlsgfff8ZY2mS7W64ftnkncCLQs
uY4VWjtbDUnXCbigxIRORKNquZ1TzDt+792zVr5qiTSWZPwlS9F7pMQ60QHY5eBO3wMSzu58I8UV
QQkqfH5kBj/XIEoGkqQYLfp2SEPjNHY+peOEPItDqhHJpBrb1S/Sj9OLvSQ+6rRYKAFMfrqLiSka
Pioa9S1O0cUPJsJdOO4ZaKhBhsE6YRzkEBfuslMJoH3uVVj/SodpisKHT3kOBGV4dT79VVVR1Kj5
AAAAAAAA

--Apple-Mail=_1FCCD454-132B-42D1-985D-6ABDF54BEB51--

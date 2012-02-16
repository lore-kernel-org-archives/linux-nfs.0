Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1585 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752967Ab2BPRhK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 12:37:10 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Jim Rees <rees@umich.edu>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4: Send implementation id with exchange_id
Date: Thu, 16 Feb 2012 17:37:03 +0000
Message-ID: <A63ABD4E-F7EA-4B7A-9866-D22363F216F8@netapp.com>
References: <1329409026-20466-1-git-send-email-dros@netapp.com>
 <20120216173022.GA29158@umich.edu>
In-Reply-To: <20120216173022.GA29158@umich.edu>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_199BAA78-8B5B-43E9-A32F-50715A5F1B42";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_199BAA78-8B5B-43E9-A32F-50715A5F1B42
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 16, 2012, at 12:30 PM, Jim Rees wrote:

> Weston Andros Adamson wrote:
>=20
>  Send the nfs implementation id in EXCHANGE_ID requests unless the =
module
>  parameter nfs.send_implementation_id is 0.
>=20
>  This adds a CONFIG variable for the nii_domain that defaults to =
"kernel.org".
>=20
>  Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>=20
>  @@ -271,7 +273,12 @@ static int nfs4_stat_to_errno(int);
>   				1 /* flags */ + \
>   				1 /* spa_how */ + \
>   				0 /* SP4_NONE (for now) */ + \
>  -				1 /* zero implemetation id array */)
>  +				1 /* implemetation id array of size 1 */ =
+ \
>=20
> implemetation -> implementation
> Might as well fix this typo while you're at it.
>=20
> General comment... If this is going to be configurable, I'd rather =
make it a
> sysctl, and be able to set the id to whatever I want at run time.  But
> that's because I like to be able to break things.  I suspect Trond =
will
> disagree.

Hrm my ispell pass missed this.

Yes, Trond was against using a sysctl.  This is how he wants it.

-dros=

--Apple-Mail=_199BAA78-8B5B-43E9-A32F-50715A5F1B42
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTYxNzM3MDRaMCMGCSqGSIb3DQEJBDEWBBTEcqx/4OGlWFxI
q3aG0Q+kNQxc/TANBgkqhkiG9w0BAQEFAASCAQBy7lfBCoHfY73cUfAJHyz/nywL2kU6XEEEwFwl
8mvzDoOujh0YJm0GJSmDKteRRiTUXqcAWGQkGw1PWn/RLxGSr0jZ0FRFbUoB+XHGi21/yNTIUVpx
Z1PyMUcBASgIQZYvJ2u8GLIlCLcJMPutJPQ3UotgYSd47VDo9gxJXj3CyxMmrpNJuyufHboBKyty
yXibnQu/4QXDwfudM2iNuCj3tbuDKr19NJ+C9litb/vbZ4mc62MTVKWM3aGbaY8H/H6Kx09nOxKO
XH6h3neSZqsLZF+Whtn/MKfANORJralGf4ocsF2sgP6I5ZVXyWt/TZuALBh6m+VJR324PJAjIt0S
AAAAAAAA

--Apple-Mail=_199BAA78-8B5B-43E9-A32F-50715A5F1B42--

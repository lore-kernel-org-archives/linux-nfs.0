Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:49173 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752799Ab2DTT5Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 15:57:24 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Jim Rees <rees@umich.edu>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Date: Fri, 20 Apr 2012 19:57:22 +0000
Message-ID: <EA178ED0-5813-4235-A0CF-CF9D54AFB04F@netapp.com>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
 <20120420194504.GA10259@umich.edu>
In-Reply-To: <20120420194504.GA10259@umich.edu>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_47008F9A-7E84-4B25-9745-98F924F68498";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_47008F9A-7E84-4B25-9745-98F924F68498
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 20, 2012, at 3:45 PM, Jim Rees wrote:

> Weston Andros Adamson wrote:
>=20
>  nfs4_path() was parsing the path component by splitting on the first =
colon.
>  This is wrong when an IPv6 address is used to mount a server.
>=20
>  For example, having mounted 'fc00::10:/export', nfs4_path() returned
>  ':10:/export'.  This causes referrals (using IPv4 or IPv6 addresses) =
to fail
>  in nfs4_validate_fspath().
>=20
>  Parsing the path component by using the *last* colon works with
>  IPv6 as well as IPv4 addrs.
>=20
> What if your mount is:
>=20
> server.edu:/export/:I-like-colons:
>=20
> It seems to me something has to give.  Either we require v6 addresses =
be
> enclosed in [], export dirs start with "/", or exports have no ":".


Yeah, you're right.

Although IPv6 addrs must be enclosed in [] to work with mount, it's =
always displayed in the kernel without the [].

I suppose the correct fix is to always display IPv6 addresses enclosed =
in [], which might touch a *lot* of places.

Thoughts?  I'll wait for others to chime in before I go fixing this. I =
have a set of nfsd and mountd patches that deal with similar issues on =
the server side.  I'll clean those up and submit them before getting =
back to this.

Who the hell thought it was a good idea for IPv6 to use ':' as a =
delimiter!?  Is it paranoid to think they designed it that way to make =
our lives harder? ;)

-dros


--Apple-Mail=_47008F9A-7E84-4B25-9745-98F924F68498
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA0MjAxOTU3MjVaMCMGCSqGSIb3DQEJBDEWBBRCawlFpcGi1WoA
iY1n+32AikKvPjANBgkqhkiG9w0BAQEFAASCAQCY7Ewz3KnJIeXXtDZLosLjgVCBNJC/120R1IYZ
KUznFk6Db9XXJn1X3l+aDbBMZR4ehE5oJC5Gq2qfJnQvxZHnRPcC2PoFV6c459wMUhkPCJcUxipx
ngiq1PdkH1oMp/c7xWNfVXA35qxZ1Xw4c1Wn7EvzV/3nEF7dV0AkqulhqVI2dUhHXakFP/Ct+z/W
Hk6An+eRHKjAWm316I43Rh8wV7O3iJLJV4bsiI4tE2gHd1PwTpJ8kciWLiPM5MyTjQJX3i81MB11
7CBwg/JnMCaT3H7d2+nlhB6uIhZC6yXUO45vsNVlyAip/QO/81CdbZmX8gIhBWOyBN+KbvqV6BmB
AAAAAAAA

--Apple-Mail=_47008F9A-7E84-4B25-9745-98F924F68498--

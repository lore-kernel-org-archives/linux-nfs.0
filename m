Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45183 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964869Ab2FAWBV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 18:01:21 -0400
Received: from vmwexceht04-prd.hq.netapp.com (vmwexceht04-prd.hq.netapp.com [10.106.77.34])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q51M1L0x005593
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jun 2012 15:01:21 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [[PATCH resend] 2/6] PYNFS fix rpcgen
Date: Fri, 1 Jun 2012 22:01:20 +0000
Message-ID: <F7A8AF1E-5F24-44DF-AFD8-25C4501B2FC2@netapp.com>
References: <1338329489-29178-1-git-send-email-andros@netapp.com>
 <1338329489-29178-3-git-send-email-andros@netapp.com>
In-Reply-To: <1338329489-29178-3-git-send-email-andros@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_4334DF92-0CE4-4853-947D-54BD262FE5CB";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_4334DF92-0CE4-4853-947D-54BD262FE5CB
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Fred -

I don't know where the commit message body went, but I can resubmit if =
you want.

commit 54976c74821316cdc21b80a886699b8f9c60bf9a
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Tue Mar 6 22:15:17 2012 -0500

    pynfs: Fix bug in xdrgen __repr__ generation
   =20
    If an enum type is defined as opaque the generated __repr__ function =
raises
    an exception trying to use the list as a key for a dict.get() =
lookup.

-dros

On May 29, 2012, at 6:11 PM, <andros@netapp.com>
 <andros@netapp.com> wrote:

> From: Weston Andros Adamson <dros@netapp.com>
>=20
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> xdr/xdrgen.py |    2 ++
> 1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/xdr/xdrgen.py b/xdr/xdrgen.py
> index 0148f96..72954d1 100755
> --- a/xdr/xdrgen.py
> +++ b/xdr/xdrgen.py
> @@ -786,6 +786,8 @@ class Info(object):
>             if t.type in name_dict:
>                 p =3D name_dict[t.type]
>                 if p.parent and p.type =3D=3D 'enum':
> +                    if t.array:
> +                        return "','.join([ const.%s.get(x, x) for x =
in self.%s ])" % (p.id, t.id)
>                     return "const.%s.get(self.%s, self.%s)" % (p.id, =
t.id, t.id)
>             return "repr(self.%s)" % t.id
>         indent2 =3D prefix + indent
> --=20
> 1.7.7.6
>=20


--Apple-Mail=_4334DF92-0CE4-4853-947D-54BD262FE5CB
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA2MDEyMjAxMjBaMCMGCSqGSIb3DQEJBDEWBBTY5AIhgpbURr6e
tdn1sUX77m1A2TANBgkqhkiG9w0BAQEFAASCAQAZ0yXHhLGP/v6NPS0/MwAReTrIUWbI2nG1qlTZ
6xI/guDxCi1npADMtDhT92mN1ihooN5SlK9QvKSMKLz0Thl60fi14bogzXzaT8FyeuLr0sAbzO96
1XoyNfIUaN23EXPughDPDQw8oVTDrirL0atFQspNU/hZTFif6E8O4CETd4YZNCMtnzIXRwVDIOLS
ZaA0PpklTNjxsjDwABCSBvTBqeJyZeCJrt41I+rstZ2ftYeqOMB3t2ipBelhV0kM/ht1NiicdYWg
V/p63+wlM2G5yrwC4rnfCR0Gi+kTVnNZiRc4oZhgWhqm4EK7t5omXO9PD31QamfcBUcSkkeG0fnY
AAAAAAAA

--Apple-Mail=_4334DF92-0CE4-4853-947D-54BD262FE5CB--

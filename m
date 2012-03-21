Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53026 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755715Ab2CUT41 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:56:27 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: krb5 failures in recent nfs-for-next
Date: Wed, 21 Mar 2012 19:56:24 +0000
Message-ID: <72DB89A4-DDDB-41FD-9B47-3CBECA0E5966@netapp.com>
References: <20120321192448.GB11222@fieldses.org>
 <4F6A2DE8.6060403@netapp.com> <20120321194544.GC11222@fieldses.org>
In-Reply-To: <20120321194544.GC11222@fieldses.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_D6E414B2-C41A-471E-9EA6-C8492C2A01B2";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_D6E414B2-C41A-471E-9EA6-C8492C2A01B2
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Hey Bruce,

Any more info on this?  nfs-for-next wfm with kerberos against a server =
with fedora 16 kernel 3.2.10-3.fc16.x86_64.

-dros

On Mar 21, 2012, at 3:45 PM, J. Bruce Fields wrote:

> On Wed, Mar 21, 2012 at 03:37:12PM -0400, Bryan Schumaker wrote:
>> On 03/21/2012 03:24 PM, J. Bruce Fields wrote:
>>=20
>>> Have you been doing any krb5 testing?
>>=20
>>=20
>> Not yet.  It's still on my Jenkins todo list, but I haven't gotten =
around to it yet.  Sounds like we need it, though, so I'll try working =
on it soon.
>=20
> Actually, I've since seen the failure over nfsv4 and auth_sys.  All
> that's left on the console is enough to tell me it's happening in
> nfs4_free_lock_state, called from __rpc_execute in a kthread.  (Well,
> assuming that's actually the first backtrace.)
>=20
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_D6E414B2-C41A-471E-9EA6-C8492C2A01B2
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAzMjExOTU2MzFaMCMGCSqGSIb3DQEJBDEWBBTofgl+lwwii7+N
hrKE388fTL397TANBgkqhkiG9w0BAQEFAASCAQAopjVpTD2rbhnkxVUHenQlGCwxvrD36UMCPzlv
Iw1fpTRmgLbxw7erG3KGlHXCW/B7+J1BsQVzSfIsFCfli+yFuYuWM1PtLS+ZIYRwOApS0+BvAeTb
mgKrfW318x76WK2NbtO6VVETW/TaGzKBxhEAnpybB2x9bFwmD3X/A35b1Pz92UBgyV/+EuUnFMNM
y2biev9mP2z5+1lrWoum2kk9x/IzHUz5s3wcK1x15P9junTrHTGSCdSkt6xV+GK58LcCLTSnOg3E
FpPCs8KvpaQaKt5/byGhzqvMVvnt78SvfOYMukPHrxMXDubNQMZgeTawoMt3nhKx6os25AzcuSUY
AAAAAAAA

--Apple-Mail=_D6E414B2-C41A-471E-9EA6-C8492C2A01B2--

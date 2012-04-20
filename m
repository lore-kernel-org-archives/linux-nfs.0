Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35341 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754454Ab2DTVm6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 17:42:58 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Date: Fri, 20 Apr 2012 21:42:56 +0000
Message-ID: <DA990978-9EBE-44F2-9776-DD8FBAFDCB19@netapp.com>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
 <B1E9AAB3-6739-46D5-999A-130494131031@oracle.com>
 <79682769-1052-4392-A63D-F686A81C2BBE@netapp.com>
 <41440F4B-99AC-48AC-A1F8-C9A3DED9E76E@netapp.com>
 <1334957938.3295.37.camel@lade.trondhjem.org>
In-Reply-To: <1334957938.3295.37.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_3AAFBF2C-7FC9-4EFD-9E33-042BF89E76D4";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_3AAFBF2C-7FC9-4EFD-9E33-042BF89E76D4
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 20, 2012, at 5:39 PM, Myklebust, Trond wrote:

> On Fri, 2012-04-20 at 21:31 +0000, Adamson, Dros wrote:
>> On Apr 20, 2012, at 5:25 PM, Adamson, Dros wrote:
>> To be clear: the problem is *not* with IPv6 addrs in FS_LOCATIONS =
attrs.  They work if the parent mount is IPv4/dns.  The problem is when =
the parent mount is IPv6 *no* referrals work (IPv4, IPv6 or DNS), =
because of the issue described above.
>=20
> There is a problem there too. If you don't bracket the IPv6 address =
that
> you get from fs_locations, then you'll hit the same problem if you hit =
a
> referral on the referred-to server.

Ok, but that's a moot point at this stage as [] escaping is always =
getting stripped from dentry->d_fsdata (really from dev_name passed to =
mount as far as I can tell).

-dros=

--Apple-Mail=_3AAFBF2C-7FC9-4EFD-9E33-042BF89E76D4
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA0MjAyMTQyNTZaMCMGCSqGSIb3DQEJBDEWBBSOkiIb3anUjM0Z
SSe56I9L5sj+JjANBgkqhkiG9w0BAQEFAASCAQAeXfWaG6PDRPhe1XSg293pX5t2ppWbBNXwwUXU
gpXIXVcRElCSQiVO4m3M6+tNBnCHWzGslVD7oSGm3Tf7f6nKQOlSqx68yY8dcrhSQf+D4kqB4ldz
lLV6NnqLafyZI6NjCGZ2qXW+0tAh2AK8rL8KKj+p9Cg+HLvhRzIq80xRD3OCw+9SWj+d0/np8Dx2
8xJNL4Ir3XU2eM3JwLUJGyautMXkVgU/REkDkJvR1VMehXyB3VsIpT0GdkAZmhd1uDD0TNNsLoZ5
mw0Vfe1nj4JsU2pv0Vk9jHImB1o5Yom+AXV+WuZlnbA6YTyDqLJiz6R6tP1AbrpPwslQan2+ZaFq
AAAAAAAA

--Apple-Mail=_3AAFBF2C-7FC9-4EFD-9E33-042BF89E76D4--

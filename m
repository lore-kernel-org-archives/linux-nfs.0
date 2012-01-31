Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:46037 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753365Ab2AaTTo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jan 2012 14:19:44 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q0VJJgmE021920
	for <linux-nfs@vger.kernel.org>; Tue, 31 Jan 2012 11:19:43 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "AND... open list:NFS SUNRPC" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] [RFC] NFS - filelayout DS rpc mountstats support
Date: Tue, 31 Jan 2012 19:19:33 +0000
Message-ID: <B585B3B6-3859-4FF7-9A63-72A2E7B74CCE@netapp.com>
References: <1327956820-2772-1-git-send-email-dros@netapp.com>
In-Reply-To: <1327956820-2772-1-git-send-email-dros@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_84B656F9-E086-4010-90AA-F61876EB2FD0";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_84B656F9-E086-4010-90AA-F61876EB2FD0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jan 30, 2012, at 3:53 PM, Weston Andros Adamson wrote:

> go, I'll update mountstats(1) to combine them for the default output =
(much in

i meant mountstats(8) -- sorry, too much coffee!=

--Apple-Mail=_84B656F9-E086-4010-90AA-F61876EB2FD0
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAxMzExOTE5MzNaMCMGCSqGSIb3DQEJBDEWBBQjPegtJH8mfzX0
yRaJVLd0IBq4ajANBgkqhkiG9w0BAQEFAASCAQAoCw1yMIcsq5NvrulisPRQ7vXW3emwKj/0AWXW
lz7DnQ9vDIDCxuREV7mwn+8YGD9/fQ4KSAA2/T80AmK+NmVplOC0Ulpe6Z5dUmCHD5gup8B4VrKo
mm8kXkp8bZ8uRXJruPkqHlXyg0oPhpnDbdLh+54GBEpzJtyeii8iBNqkHSSMC0WaI0Li/2l8Fp1c
GOkwb1H5Jr/FGy8TPf9rupRT254ALOawYI46oh2+yPlJzcVPNvtB8E79X3r+rHxWbSkj/VPGlQNI
xBSHb3csU2x4pIjWUMzZ62maqnicxYih43qtVf8QXr8ebx5CugdSmW3ezU9+e0GICpGwECjAaYuo
AAAAAAAA

--Apple-Mail=_84B656F9-E086-4010-90AA-F61876EB2FD0--

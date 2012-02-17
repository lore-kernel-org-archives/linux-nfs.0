Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061Ab2BQTCc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 14:02:32 -0500
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1HJ2WUJ028040
	for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2012 11:02:32 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Fri, 17 Feb 2012 19:02:27 +0000
Message-ID: <9E808232-0D4C-4498-8BD8-4856C4D8190F@netapp.com>
References: <1329502524-27114-1-git-send-email-dros@netapp.com>
 <1329504423.12048.3.camel@lade.trondhjem.org>
In-Reply-To: <1329504423.12048.3.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_8470C611-8D84-4012-8672-01F556FEAF39";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_8470C611-8D84-4012-8672-01F556FEAF39
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Feb 17, 2012, at 1:47 PM, Myklebust, Trond wrote:

> On Fri, 2012-02-17 at 13:15 -0500, Weston Andros Adamson wrote:
>> Include RPC statistics from all data servers in /proc/self/mountstats =
for pNFS
>> filelayout mounts.
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> Update: don't increment tk_client stats if callback is used.
>>=20
>> This still checks task->tk_client !=3D NULL -- I'm not convinced it's =
unneeded
>> as it existed in rpc_count_iostats.
>=20
> I'll remove it before applying.

I can repost the patch, if that's easier.

-dros=

--Apple-Mail=_8470C611-8D84-4012-8672-01F556FEAF39
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTcxOTAyMjdaMCMGCSqGSIb3DQEJBDEWBBTNHMM15UaGMIcf
ImaVSqlN/LqW3DANBgkqhkiG9w0BAQEFAASCAQAdQ/LR3X5V6hXJeP5UqXQ/xx1aIw9uNe7fQ+PW
zKLw2fBh0aG5Koa8U9P6gfMAjv+xE+P0Nl4FTfv0CbU5+bGApDF8hDm5bN+gDFsfGBtTh+u2qBis
Fo1AQAtXNDedqZV09FbA80MfpgWnsVtsY3Qu8q5oslGKsZ2Tnm1aCTezuB88xZWvQ6oibbyKfczq
77oz+HD5nWCiUAficBqQiMIR7aGe9o3EJEkwxXL4bwxWb3/tcA+EDznwd6exFVBXmPh5OD103RYI
ny5WMC4LKYa5SHODXftD1FJbLYW3MdCYz40GZc9RUYZi8mXx0n//QBYV49BEjMz1aYu5EPkgiFVT
AAAAAAAA

--Apple-Mail=_8470C611-8D84-4012-8672-01F556FEAF39--

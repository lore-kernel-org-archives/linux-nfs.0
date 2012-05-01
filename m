Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63380 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757058Ab2EAQKN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 12:10:13 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "<SteveD@redhat.com>" <SteveD@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: add IPv6 addr escaping to fs_location hosts
Date: Tue, 1 May 2012 16:09:55 +0000
Message-ID: <975131E5-DBB4-4C78-904E-EA577B748DD4@netapp.com>
References: <1335279577-46822-1-git-send-email-dros@netapp.com>
 <20120427112529.GA14973@fieldses.org>
In-Reply-To: <20120427112529.GA14973@fieldses.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_B9325932-077D-4C42-85D7-3D05052046A9";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_B9325932-077D-4C42-85D7-3D05052046A9
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Apr 27, 2012, at 7:25 AM, J. Bruce Fields wrote:

> On Tue, Apr 24, 2012 at 10:59:37AM -0400, Weston Andros Adamson wrote:
>> The fs_location->hosts list is split on colons, but this doesn't work =
when
>> IPv6 addresses are used (they contain colons).
>> This patch adds the function nfsd4_encode_components_esc() to
>> allow the caller to specify escape characters when splitting on =
'sep'.
>> In order to fix referrals, this patch must be used with the mountd =
patch
>> that similarly fixes IPv6 [] escaping.
>=20
> Thanks, looks fine, applying with one trivial change:
>=20
>> -		for (; *end && (*end !=3D sep); end++)
>> -			; /* Point to end of component */
>> +		bool found_esc =3D false;
>> +
>> +		/* try to parse as esc_start, ..., esc_end, sep */
>> +		if (*str =3D=3D esc_enter) {
>> +			for (; *end && (*end !=3D esc_exit); end++);
>=20
> I kinda like keeping the semicolon on its own line here.  Tastes may
> differ.

Yeah, as Jim pointed out checkpatch will complain if it's not -- you =
already found my updated diff.

> (Also: how did you test this?)

I testsed this patch along with the corresponding mountd patch using two =
servers:

[fc00::10] - exporting /export, /export/refer @ [fc00:41]:/export
[fc00::41] - exporting /export

On a client machine (with recently posted client-side fix), I mount =
[fc00::10]:/export on /mnt, then cd to /mnt/refer.

Without these patches, wireshark sees a list of referral locations: =
"[fc00", "", "10]", which is obviously wrong.
With these patches the cd to /mnt/refer works as [fc00::41]:/export is =
mounted at /mnt/refer.

-dros=

--Apple-Mail=_B9325932-077D-4C42-85D7-3D05052046A9
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MDExNjA5NTVaMCMGCSqGSIb3DQEJBDEWBBTS9hRXDXYkkj6v
yfXEQpvxOJ8CHjANBgkqhkiG9w0BAQEFAASCAQBxgpJ6dVX4HCHMJBMEAFDgYb/ADDSN0PL8gCWk
IgXoJzWUkafx7vij7Vy8hgv1DOHdLTvaJxSGzFxVySwPlpgb77HxsCMXBO6UCupM6gUjQ1Msi9+G
btOQc4KL6p1YHsb3LO3yghssCIkmzpatPYtAifcAnji36Xf1TI4aKa7vLLRU9NRENhJpTGWe49oL
bJ71UN3EXbHJizyDn1VTyNMg8W+OukcntcLtC4eMibOdYC/zkm/GgnPnBxo/kk9mVdPM0yBhuEsm
iJ1vDJ4tskIZJXNwvqFaFjpS3it/aHsgCN/p4Ex6jIJvFz+O/1O6IYoI2HRWQbRyaEC9TWGszExq
AAAAAAAA

--Apple-Mail=_B9325932-077D-4C42-85D7-3D05052046A9--

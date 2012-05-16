Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63774 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753244Ab2EPVut (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 17:50:49 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: return 0 on reads of fault injection files
Date: Wed, 16 May 2012 21:50:32 +0000
Message-ID: <E560542A-DCC3-4093-8B69-438783DD9451@netapp.com>
References: <1336678270-791-1-git-send-email-dros@netapp.com>
 <20120516211621.GE20487@fieldses.org>
In-Reply-To: <20120516211621.GE20487@fieldses.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_E2596B70-29D0-4238-96E0-B47EADEDA9C6";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_E2596B70-29D0-4238-96E0-B47EADEDA9C6
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252


On May 16, 2012, at 5:16 PM, J. Bruce Fields wrote:

> On Thu, May 10, 2012 at 03:31:10PM -0400, Weston Andros Adamson wrote:
>> debugfs read operations were returning the contents of an =
uninitialized u64.
>=20
> Thanks, applied.
>=20
>>=20
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> I found this while working on (forthcoming) fault injection tests for=20=

>> CB_PATH_DOWN.
>=20
> Did you ever confirm whether the latest nfsd is setting that flag when
> it should be?

No, I haven't messed with it that much - I had other tasks take a higher =
priority, but I'm back on it as of this afternoon.

I'll try nfsd-next to get CB_PATH_DOWN without fault_injection and =
report back to you.  Also, I think we need to modify nfsd =
(nfsd4_new_conn()) to set cl_cb_state to NFSD4_CB_UNKNOWN on a =
successful BIND_CONN_TO_SESSION (IFF it's CB_DOWN with the right =
direction), otherwise the CB_PATH_DOWN flag will be set on every =
sequence OP and the client will keep sending BIND_CONN_TO_SESSION.  The =
idea is that once we call nfsd4_new_conn, we won't know if the back =
channel is really up until a callback is attempted.  Setting it to =
CB_UNKNOWN stops the loop of (sequence, bind_conn, sequence, bind_conn, =
=85), but doesn't actually mark it as "UP" until a callback is =
successful.

Expect patches soon.

-dros

>=20
> --b.
>=20
>>=20
>> fs/nfsd/fault_inject.c |    1 +
>> 1 files changed, 1 insertions(+), 0 deletions(-)
>>=20
>> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
>> index 46b7696..ab81144 100644
>> --- a/fs/nfsd/fault_inject.c
>> +++ b/fs/nfsd/fault_inject.c
>> @@ -62,6 +62,7 @@ static int nfsd_inject_set(void *op_ptr, u64 val)
>>=20
>> static int nfsd_inject_get(void *data, u64 *val)
>> {
>> +	*val =3D 0;
>> 	return 0;
>> }
>>=20
>> --=20
>> 1.7.4.4
>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Apple-Mail=_E2596B70-29D0-4238-96E0-B47EADEDA9C6
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MTYyMTUwMzVaMCMGCSqGSIb3DQEJBDEWBBRGnUyiLEX3fKb2
BKCS7xYAVGOPbjANBgkqhkiG9w0BAQEFAASCAQBFvJrcKIFVhm0qTN9Xvc+Y/yg6zndrJjjBd+Ft
NmfinyihSx+K4okoXzzu5ZBhGVF0YdUt4x6eieK5T29gU9SSr74fi46mKa2mi0KW7PzbUVe6N/bH
135H7xGaJnTLNGtobq7icOIoQ9ixym9dohQ8sEHT8Vwpjrb6O/QKZiJhj4Z5aCY9tzLfVeFZuSRg
4/A5KiDskWN4vFa69FPqqIdBd6PLetIanBnXcIJ+V6+kKnLGkW2p73JAmw/mYfEAXfy2Kll0el6N
D/KcNMnjKjY2HLtH7LwYUg2V2nPP3aWht4TEDVMKw3diupb5PHl6Mc8ez2QaZkfvGwa0kyaK/yy7
AAAAAAAA

--Apple-Mail=_E2596B70-29D0-4238-96E0-B47EADEDA9C6--

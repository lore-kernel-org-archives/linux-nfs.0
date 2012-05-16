Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62350 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759335Ab2EPWK6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 18:10:58 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: return 0 on reads of fault injection files
Date: Wed, 16 May 2012 22:10:55 +0000
Message-ID: <99C4F6D8-3BBF-4502-B41C-A71B2ADB6207@netapp.com>
References: <1336678270-791-1-git-send-email-dros@netapp.com>
 <20120516211621.GE20487@fieldses.org>
 <E560542A-DCC3-4093-8B69-438783DD9451@netapp.com>
 <20120516215847.GF20487@fieldses.org>
In-Reply-To: <20120516215847.GF20487@fieldses.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_F523182B-B871-467B-A73A-93525A12C987";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_F523182B-B871-467B-A73A-93525A12C987
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252


On May 16, 2012, at 5:58 PM, J. Bruce Fields wrote:

> On Wed, May 16, 2012 at 09:50:32PM +0000, Adamson, Dros wrote:
>> No, I haven't messed with it that much - I had other tasks take a
>> higher priority, but I'm back on it as of this afternoon.
>>=20
>> I'll try nfsd-next to get CB_PATH_DOWN without fault_injection and
>> report back to you.  Also, I think we need to modify nfsd
>> (nfsd4_new_conn()) to set cl_cb_state to NFSD4_CB_UNKNOWN on a
>> successful BIND_CONN_TO_SESSION (IFF it's CB_DOWN with the right
>> direction), otherwise the CB_PATH_DOWN flag will be set on every
>> sequence OP
>=20
> That's intentional:
>=20
> 	http://www.ietf.org/mail-archive/web/nfsv4/current/msg10840.html

Right...

>=20
>> and the client will keep sending BIND_CONN_TO_SESSION.
>> The idea is that once we call nfsd4_new_conn, we won't know if the
>> back channel is really up until a callback is attempted.
>=20
> If the client hasn't given us a connection to use as the backchannel,
> then we *know* the backchannel is down, we don't need to try sending a
> callback (how could we?).

The point is that the client *has* given us a connection to use as the =
backchannel with the BIND_CONN_TO_SESSION call.
On the server, nfs4_new_conn() was called and was successful, but =
cl_cb_state is still set to CB_DOWN and will never change.

>=20
>> Setting it to CB_UNKNOWN stops the loop of (sequence, bind_conn,
>> sequence, bind_conn, =85), but doesn't actually mark it as "UP" until =
a
>> callback is successful.
>=20
> If the client is attempting to clear the CB_PATH_DOWN flag by sending =
us
> a BIND_CONN_TO_SESSION that doesn't actually give us a backchannel, =
then
> it's confused.

The client *is* giving us a backchannel by sending the server a =
BIND_CONNN_TO_SESSION! The server accepts the call, adds the "new =
connection" via nfs4_new_conn(), but the problem is the internal state =
of nfsd never changes from CB_DOWN.

-dros

> If the client really doesn't care whether the backchannel is down or =
not
> then it can ignore the flag--it's a flag, not an error.
>=20
> --b.


--Apple-Mail=_F523182B-B871-467B-A73A-93525A12C987
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
MBwGCSqGSIb3DQEJBTEPFw0xMjA1MTYyMjEwNTdaMCMGCSqGSIb3DQEJBDEWBBT+DARl9Gg3T1MA
KvYXR7FBet4UczANBgkqhkiG9w0BAQEFAASCAQAFKt/y+ddhn0poOV32pu7NS/PfGqmpeds0uMK9
VfLcf6+LMdvB22k+pFbi9C2eIRvkHV6DxH1OYNzYKNkx3U7do3Vg3PSVenkHS0aBYpOgEremV9tR
jZD7Ap/xaPDsl5cbwj+jcAihC8AWinHZ+anKSr0P/tm92SMI4uCFIoQ4iNvIgo4Ty9pTIcektxFF
O6f9pXN/b+ADHpktRT4tW0JYC1bLvz0TZIF/hz9r4HvOofq1Eu0rKWMLXRXU5ijMvSuAcMidnlRh
WPwii/qPikkp+HvDFxMJuPcxSUv0YZCzzjZtLqq21268sVjIzIJ1+6jget24P5ZynkL/XKK5D410
AAAAAAAA

--Apple-Mail=_F523182B-B871-467B-A73A-93525A12C987--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23215 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757814Ab2BIUrz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Feb 2012 15:47:55 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Thu, 9 Feb 2012 20:47:46 +0000
Message-ID: <E2B07A96-5E11-4C2F-91AF-18CD7C731944@netapp.com>
References: <1328805686-19559-1-git-send-email-dros@netapp.com>
 <1328811417.13180.51.camel@lade.trondhjem.org>
 <39752416-3EE2-4E32-944C-4F75672C2872@netapp.com>
 <1328815664.13180.60.camel@lade.trondhjem.org>
 <BAC7F881-0F2D-423D-92FB-DE0F579CC6D6@netapp.com>
 <1328817534.13180.65.camel@lade.trondhjem.org>
 <F13A10AE-EECE-4CB9-B31B-D9163E3B48D0@netapp.com>
 <1328819862.13180.72.camel@lade.trondhjem.org>
In-Reply-To: <1328819862.13180.72.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_D361EDBB-959F-4371-9640-CC3A7A33F601";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_D361EDBB-959F-4371-9640-CC3A7A33F601
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Feb 9, 2012, at 3:37 PM, Myklebust, Trond wrote:

> On Thu, 2012-02-09 at 20:23 +0000, Adamson, Dros wrote:
>> On Feb 9, 2012, at 2:58 PM, Myklebust, Trond wrote:
>>=20
>>> On Thu, 2012-02-09 at 19:48 +0000, Adamson, Dros wrote:
>>>>>=20
>>>>>> I do have an implementation that doesn't need to walk the =
deviceid list by allowing a shared rpc_iostats struct between multiple =
rpc_clients (in addition to the current rpc_iostats structure), but that =
required adding locking and reference counting -- all for printing stats =
(obviously not what we want).
>>>>>=20
>>>>> This might be more in line with what we want. Note that it should =
be
>>>>> easy to clone an rpc_client and then replace its rpc_iostats =
struct. I
>>>>> don't think that needs any extra locking. We're already ignoring =
locking
>>>>> here between different rpc_tasks, so throwing in different =
rpc_clients
>>>>> to the mix will make no difference.
>>>>=20
>>>> Yeah, that's easy enough and i guess we could ignore locking, but =
we are still left with the same problem: how is this supposed to account =
for different mount points using the same nfs_client?  nfs_client only =
has one rpc_client member.  I doubt we want to make a hash lookup on =
nfs_server to get the right rpc_client (which could all use the same =
underlying xprt).
>>>>=20
>>>> Maybe it's time to move these stats into fs/nfs/ where they really =
belong?  We could get rid of the hack that overloads procnum with opnum =
from inside the compound for v4+ and finally only show a specific =
mount's RPC stats.
>>>=20
>>> Actually, how about just adding a callback into struct rpc_call_ops
>>> that, if it is defined, would be called instead of =
rpc_count_iostats().=20
>>> If you then modify rpc_count_iostats() to take the 'stats' variable =
as a
>>> parameter, you can simply have the new callback call =
rpc_count_iostats
>>> with the right arguments.
>>=20
>> Yeah, that could work!  On my walk home from the cafe (they always =
seem to help) I came up with a slightly different strategy:
>>=20
>> - remove the cl_metrics (struct rpc_iostats) member from rpc_clnt
>> - add an *optional* rpc_iostats pointer to rpc_task (ignored if NULL)
>> - allocate one rpc_iostats structure (really array of structs, but =
you know what I mean) per nfs_server structure
>> - when setting up rpc_tasks in nfs-land, pass the correct rpc_iostats
>>=20
>> with this strategy we don't accumulate stats when they aren't ever =
used (like an rpc_client used for mount protocol).  again, only NFS uses =
the rpc stats interface.
>>=20
>> I kind of like this better than a callback, but either way is fine =
with me.  Which way would you prefer?
>=20
> I'd prefer not to have to grow the size of the rpc_task unless we =
really
> need to. That's why I suggested the callback instead.

Good to know!  I'll do the callback method.

Also, I'm going to go ahead with removing the cl_metrics member from =
rpc_clnt -- once we have the callback it'll never be used.

Thanks for pointing me in the right direction.  Expect a patch soon!

-dros=

--Apple-Mail=_D361EDBB-959F-4371-9640-CC3A7A33F601
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDkyMDQ3NDZaMCMGCSqGSIb3DQEJBDEWBBQWlh0kDbxA1HMB
8QmPztX/KZbQATANBgkqhkiG9w0BAQEFAASCAQC521SUIgKKS8aKyYdIRoH+Atdkm0sS4fSwXKpP
L431vNP0WkkR0Mn8D+ZJk+kev3HwExsaLGIMgEyHDAUpR9l/dBYtv23xXxy0BrhAu9qWLPZ8qJNa
r6OX5e64f9KURnSgoc7ObLgg7F7844BJ2tSc8b0SOdaK9dZeNeAZHXehddHVDrVOFNIzRtsbDMEl
2oTOYzyzP8ViWnJBvxtIrSucMn3kw1nL0Hd2MBK0zbENa2+HTEVMVCSZARTqIyB2VdiiPybhCtyy
9cWgcePl2uA50c792id4ajTeBM4BNatxBoSJIlWcar0Emv78ApIKmXFdeuc/OniZ4Koaf0Y/4O7K
AAAAAAAA

--Apple-Mail=_D361EDBB-959F-4371-9640-CC3A7A33F601--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22334 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753981Ab2BIUXg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Feb 2012 15:23:36 -0500
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Thu, 9 Feb 2012 20:23:28 +0000
Message-ID: <F13A10AE-EECE-4CB9-B31B-D9163E3B48D0@netapp.com>
References: <1328805686-19559-1-git-send-email-dros@netapp.com>
 <1328811417.13180.51.camel@lade.trondhjem.org>
 <39752416-3EE2-4E32-944C-4F75672C2872@netapp.com>
 <1328815664.13180.60.camel@lade.trondhjem.org>
 <BAC7F881-0F2D-423D-92FB-DE0F579CC6D6@netapp.com>
 <1328817534.13180.65.camel@lade.trondhjem.org>
In-Reply-To: <1328817534.13180.65.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_679D7BED-39D4-4239-96AC-3EF743498049";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_679D7BED-39D4-4239-96AC-3EF743498049
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 9, 2012, at 2:58 PM, Myklebust, Trond wrote:

> On Thu, 2012-02-09 at 19:48 +0000, Adamson, Dros wrote:
>>>=20
>>>> I do have an implementation that doesn't need to walk the deviceid =
list by allowing a shared rpc_iostats struct between multiple =
rpc_clients (in addition to the current rpc_iostats structure), but that =
required adding locking and reference counting -- all for printing stats =
(obviously not what we want).
>>>=20
>>> This might be more in line with what we want. Note that it should be
>>> easy to clone an rpc_client and then replace its rpc_iostats struct. =
I
>>> don't think that needs any extra locking. We're already ignoring =
locking
>>> here between different rpc_tasks, so throwing in different =
rpc_clients
>>> to the mix will make no difference.
>>=20
>> Yeah, that's easy enough and i guess we could ignore locking, but we =
are still left with the same problem: how is this supposed to account =
for different mount points using the same nfs_client?  nfs_client only =
has one rpc_client member.  I doubt we want to make a hash lookup on =
nfs_server to get the right rpc_client (which could all use the same =
underlying xprt).
>>=20
>> Maybe it's time to move these stats into fs/nfs/ where they really =
belong?  We could get rid of the hack that overloads procnum with opnum =
from inside the compound for v4+ and finally only show a specific =
mount's RPC stats.
>=20
> Actually, how about just adding a callback into struct rpc_call_ops
> that, if it is defined, would be called instead of =
rpc_count_iostats().=20
> If you then modify rpc_count_iostats() to take the 'stats' variable as =
a
> parameter, you can simply have the new callback call rpc_count_iostats
> with the right arguments.

Yeah, that could work!  On my walk home from the cafe (they always seem =
to help) I came up with a slightly different strategy:

- remove the cl_metrics (struct rpc_iostats) member from rpc_clnt
- add an *optional* rpc_iostats pointer to rpc_task (ignored if NULL)
- allocate one rpc_iostats structure (really array of structs, but you =
know what I mean) per nfs_server structure
- when setting up rpc_tasks in nfs-land, pass the correct rpc_iostats

with this strategy we don't accumulate stats when they aren't ever used =
(like an rpc_client used for mount protocol).  again, only NFS uses the =
rpc stats interface.

I kind of like this better than a callback, but either way is fine with =
me.  Which way would you prefer?

-dros

>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer
>=20
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>=20


--Apple-Mail=_679D7BED-39D4-4239-96AC-3EF743498049
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMDkyMDIzMjdaMCMGCSqGSIb3DQEJBDEWBBShCFl0/ZLrNKQ2
utcjn4UhC7woUTANBgkqhkiG9w0BAQEFAASCAQBIMQStuqHD0JRaCl3blnajfhU5TlSFZKJk+ieG
ETd8N65cd2YAOUxRfQRRecpQfdFr2eMObvRZDZISLggRpZk9k2BH5/9Xpy/WE9S3ItlxtL7/NZvj
j2L2ku9+GRyVfIfu8Q7P9pWDHSIN6HwdnTCfnaJhqfQTWx7OxGCk30L83w7MQZMkPoZ7x1aT8EjP
NNxRAhdLTRMm/YPoMZiVgPJd25SsJ79uylXqwz5ow9Q4B6+QKdpRfw8jbC4lTkbI/BEUxjIGRtht
7UHJh+uyfcI3nJ4J8YQcyYSfDuJk/ML6WuuFam/ApxiMZs8M3WDUznbtAYAYsIByqauV12rdveUd
AAAAAAAA

--Apple-Mail=_679D7BED-39D4-4239-96AC-3EF743498049--

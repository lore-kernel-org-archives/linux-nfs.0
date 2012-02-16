Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33811 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755399Ab2BPVI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 16:08:26 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1GL88Ma011062
	for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 13:08:11 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Thu, 16 Feb 2012 21:08:01 +0000
Message-ID: <413CB059-B530-499E-A90B-BA3154FA1D04@netapp.com>
References: <1329171728-3980-1-git-send-email-dros@netapp.com>
 <1329421700.4279.21.camel@lade.trondhjem.org>
 <0A71914B-99D6-49C4-A2CE-18CBFF9384F7@netapp.com>
 <1329426071.19793.21.camel@lade.trondhjem.org>
In-Reply-To: <1329426071.19793.21.camel@lade.trondhjem.org>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_DE2C6734-321A-42AC-B21D-42E4FB7383A5";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_DE2C6734-321A-42AC-B21D-42E4FB7383A5
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 16, 2012, at 4:01 PM, Myklebust, Trond wrote:

> On Thu, 2012-02-16 at 20:44 +0000, Adamson, Dros wrote:
>> On Feb 16, 2012, at 2:48 PM, Myklebust, Trond wrote:
>>>    2. Shouldn't we be calling _either_ rpc_count_iostats(), _or_
>>>       task->tk_ops->rpc_count_stats()? As far as I can see, the
>>>       nfsstat output will now be double-counting and pNFS reads,
>>>       writes and commits that are sent to the DS.
>>=20
>>=20
>> No, this doesn't double count with nfsstats.  nfsstats uses =
rpc_clnt::cl_stats (and not rpc_clnt::cl_metrics).
>>=20
>> I probably should have done an if/else for this patch -- with the =
current code, the DSs' rpc_clnt:cl_metrics will never be used.
>> I left it accumulating here because we want to have per-DS stats =
eventually and my plan was to print out stats in /proc/fs/nfsfs per =
*client* (so not separated by mountpoint).
>>=20
>> I can repost with if/else, but looking at this some more made me =
realize that we are *still* doing this wrong :)
>>=20
>> The callback method in this patch fails to accumulate stats for =
operations to the DS other than read/write/commit -- that seems right, =
but what about null, exchange_id, session heartbeats, etc?
>>=20
>> In order to properly accumulate those we are back to two obvious =
choices:
>>  1) add a count_iostats callback to the ~25 other rpc_call_ops in =
nfs-land (yuck)
>>  2) add an 'additional stats' pointer to the rpc_task structure =
(trond already said you don't want to add to task struct)
>>=20
>> Or do we just not care about displaying those operations?  For my =
purposes (nfsometer perf testing), it'd be nice to have *all* of the =
operations.
>=20
> As far as I'm concerned, the administrative traffic to the DS should =
not
> be accounted for in the mountstats: that would be wrong since DSes can
> be shared not only by different filesystems but even by different =
MDSes.
>=20
> So the performance overhead of lease and session setup to the DSes =
needs
> to be accounted for by some other mechanism.

Fair enough.  The per-client stats should help me with that.

I'll repost with if/else and change it back with the next stats patch.

-dros=

--Apple-Mail=_DE2C6734-321A-42AC-B21D-42E4FB7383A5
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTYyMTA4MDFaMCMGCSqGSIb3DQEJBDEWBBT+XHWnUDrEorVK
ya6LEE2Peo0i2jANBgkqhkiG9w0BAQEFAASCAQBwfvzioMHolRR5tG210/z0eEnnLZg02PT0d72X
0n14cq/w2D4Jw/AA2PlF69rcr9pH0ENuLa1Wtu5es7S19JD7U1hKyPXETdS4Lb3cKiSPHPAKG3iA
IMumQXTZgtWnvIqZ3I2/akeU3i1PZ0G9sBbPPsK+VBnSbR1uidnLWZSowqF9sZX5RJKd8Xqhku3x
PSnAhxd5U1zH9OlHgn01SN10jkjHvD0WUyjFWKiT2CgiemexjFYizsa7oUphTMGrXxpU9cHYiAb1
jPpaCscef9ohdIKnGBvCf3ldSp0tSUVkGCgYswnHpDh+iNkml4KiYG1YoeeXPJ80gNJ2YNa7jzrc
AAAAAAAA

--Apple-Mail=_DE2C6734-321A-42AC-B21D-42E4FB7383A5--

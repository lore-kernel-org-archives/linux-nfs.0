Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57331 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753640Ab2BPU4N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 15:56:13 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q1GKuBgt003450
	for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 12:56:13 -0800 (PST)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>
Subject: Re: [PATCH] NFS: include filelayout DS rpc stats in mountstats
Date: Thu, 16 Feb 2012 20:56:03 +0000
Message-ID: <EF244298-D7DE-4574-9EF2-A78106F9E67F@netapp.com>
References: <1329171728-3980-1-git-send-email-dros@netapp.com>
 <1329421700.4279.21.camel@lade.trondhjem.org>
 <0A71914B-99D6-49C4-A2CE-18CBFF9384F7@netapp.com>
In-Reply-To: <0A71914B-99D6-49C4-A2CE-18CBFF9384F7@netapp.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_F07C1B8D-0D05-4BD9-AE6A-CB296EEE5EC7";
	protocol="application/pkcs7-signature"; micalg=sha1
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Apple-Mail=_F07C1B8D-0D05-4BD9-AE6A-CB296EEE5EC7
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Feb 16, 2012, at 3:44 PM, Adamson, Dros wrote:

>=20
> On Feb 16, 2012, at 2:48 PM, Myklebust, Trond wrote:
>=20
>> On Mon, 2012-02-13 at 17:22 -0500, Weston Andros Adamson wrote:
>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>> index efe5495..ab7a28f 100644
>>> --- a/net/sunrpc/xprt.c
>>> +++ b/net/sunrpc/xprt.c
>>> @@ -1132,7 +1132,10 @@ void xprt_release(struct rpc_task *task)
>>> 		return;
>>>=20
>>> 	xprt =3D req->rq_xprt;
>>> -	rpc_count_iostats(task);
>>> +	if (task->tk_client)
>>> +		rpc_count_iostats(task, task->tk_client->cl_metrics);
>>> +	if (task->tk_ops->rpc_count_stats !=3D NULL)
>>> +		task->tk_ops->rpc_count_stats(task, task->tk_calldata);
>>> 	spin_lock_bh(&xprt->transport_lock);
>>> 	xprt->ops->release_xprt(xprt, task);
>>> 	if (xprt->ops->release_request)
>>=20
>> 2 nits:
>>=20
>>    1. Aren't we guaranteed that task->tk_client !=3D NULL in
>>       xprt_release()?
>=20
> I wasn't sure -- there is no other reference to tk_client in the =
xprt_release() path.
> It worked fine for *me* without the if statement, but the old =
rpc_count_iostats (of which this was the only caller) checked if =
tk_client was NULL and I didn't want to break anything.
>=20
>>    2. Shouldn't we be calling _either_ rpc_count_iostats(), _or_
>>       task->tk_ops->rpc_count_stats()? As far as I can see, the
>>       nfsstat output will now be double-counting and pNFS reads,
>>       writes and commits that are sent to the DS.
>=20
>=20
> No, this doesn't double count with nfsstats.  nfsstats uses =
rpc_clnt::cl_stats (and not rpc_clnt::cl_metrics).
>=20
> I probably should have done an if/else for this patch -- with the =
current code, the DSs' rpc_clnt:cl_metrics will never be used.
> I left it accumulating here because we want to have per-DS stats =
eventually and my plan was to print out stats in /proc/fs/nfsfs per =
*client* (so not separated by mountpoint).
>=20
> I can repost with if/else, but looking at this some more made me =
realize that we are *still* doing this wrong :)
>=20
> The callback method in this patch fails to accumulate stats for =
operations to the DS other than read/write/commit -- that seems right, =
but what about null, exchange_id, session heartbeats, etc?
>=20
> In order to properly accumulate those we are back to two obvious =
choices:
>  1) add a count_iostats callback to the ~25 other rpc_call_ops in =
nfs-land (yuck)

^^ i guess it wouldn't have to be all of them, but this gets ugly quick.

>  2) add an 'additional stats' pointer to the rpc_task structure (trond =
already said you don't want to add to task struct)
>=20
> Or do we just not care about displaying those operations?  For my =
purposes (nfsometer perf testing), it'd be nice to have *all* of the =
operations.
>=20
> -dros


--Apple-Mail=_F07C1B8D-0D05-4BD9-AE6A-CB296EEE5EC7
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
MBwGCSqGSIb3DQEJBTEPFw0xMjAyMTYyMDU2MDNaMCMGCSqGSIb3DQEJBDEWBBTIAgVhWo4s6IXV
s3Kv3oT0k1H+9zANBgkqhkiG9w0BAQEFAASCAQAg5Cgl6/LiKVWYuVUhWgzxCl9sACRdmfoU4WrI
QY+o/+4ONrOoObw2NlOXmJDnFGXxqS7iIW0Ik1igLEGCvEwxGJZdgN9b1jspI6BiD/pDD64rZ7Mk
PiAA5keLcl2yBW/Pr8L+PD422rSnL4brQnEETpLOhtfXs1GRTRd5X4vTdVxFvfSLohma6YLLbIA2
G96XiXqbF/D7EfFA+Bo2r/Ud1xRjBUTsPcboMJ/BvUtnN9OmpjljpUwfFhZAcqCfjeCtn4UZ5FN+
1Gmu/Yz6bDcF99ammk17z6SFElvl0wianvG1mzyXJzbzoTWU71/ptqfSOO2MnLJuimnynU6B5Gbd
AAAAAAAA

--Apple-Mail=_F07C1B8D-0D05-4BD9-AE6A-CB296EEE5EC7--

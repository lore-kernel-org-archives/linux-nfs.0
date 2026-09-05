Received: from smtp-o-3.desy.de (smtp-o-3.desy.de [131.169.56.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C02431D72E
	for <linux-nfs@vger.kernel.org>; Sat,  5 Sep 2026 14:42:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788619373; cv=none; b=pTspH48/rXR8BqlyZMLRmNtuVyeorG62qPGFFL6l5H21i7KvOb25EQm6qBPur1z1UaeX/QfVgrt++UlWoz7eIgOZGrI4Wr5Q0ORjJw2vGLiigxmROn4YhXZ9X6DSx2l4HuQiP7AoJaKqPtv/zU9OZHMgTQY/Xr0KjchGw3Fl5W0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788619373; c=relaxed/simple;
	bh=ZOUVY1knb2L6YQzafaenn8BIdhXzBd+ebTgcY/+eC8s=;
	h=Date:From:To:Cc:Message-ID:In-Reply-To:References:Subject:
	 MIME-Version:Content-Type; b=G+3zsnuQu0Rue9PSeUU4aTAxaH/QIYttR6xkcd9uxW5yiGh/3a2Kf4KAqfvZkUUj7xm+meAWIHH/+mbK8iuXBnYr1qNDG4Y2WaMmkQAueYce6e6rE6J1VT+hWEEEr+QDZ+Fok3H/VBTlQeNT2pEJRq1i0T9tcXfwFh9aCmAd2Lo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=ZpHzZFh2; arc=none smtp.client-ip=131.169.56.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="ZpHzZFh2"
Received: from smtp-o-1.desy.de (smtp-o-1.desy.de [IPv6:2001:638:700:1038::1:9a])
	by smtp-o-3.desy.de (Postfix) with ESMTP id C719811FA87
	for <linux-nfs@vger.kernel.org>; Sat,  5 Sep 2026 16:37:14 +0200 (CEST)
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [131.169.56.166])
	by smtp-o-1.desy.de (Postfix) with ESMTP id B450811F744
	for <linux-nfs@vger.kernel.org>; Sat,  5 Sep 2026 16:37:06 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-1.desy.de B450811F744
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1788619026; bh=IJLZab2I2PVon6ToarSblskmLwJoguiKb1VvW8Dw2rs=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=ZpHzZFh2QmDsycoEfqeKzT3gDjdw2axR0NEc5Ky1V0M4tuIUGYWWu+uF5humuLSVY
	 NRDxmb5DNld8+V2o7Gy7yRspxW2DdahHWzJ93MGCZXMiEgR1z8Ev5dJdhSkKKysc7w
	 OCKuwscbDWAKuwTgrsVnQTfK9TrsusFdwQfi20JQ=
Received: from smtp-m-1.desy.de (smtp-m-1.desy.de [IPv6:2001:638:700:1038::1:81])
	by smtp-buf-3.desy.de (Postfix) with ESMTP id 9E698C0040;
	Sat,  5 Sep 2026 16:37:06 +0200 (CEST)
Received: from b1722.mx.srv.dfn.de (b1722.mx.srv.dfn.de [IPv6:2001:638:d:c302:acdc:1979:2:e7])
	by smtp-m-1.desy.de (Postfix) with ESMTP id 884EF40045;
	Sat,  5 Sep 2026 16:37:06 +0200 (CEST)
Received: from smtp-intra-1.desy.de (smtp-intra-1.desy.de [IPv6:2001:638:700:1038::1:52])
	by b1722.mx.srv.dfn.de (Postfix) with ESMTP id 100CE160060;
	Sat, 05 Sep 2026 16:37:03 +0200 (CEST)
Received: from z-mbx-3.desy.de (z-mbx-3.desy.de [131.169.55.141])
	by smtp-intra-1.desy.de (Postfix) with ESMTP id 9EEBA8004E;
	Sat,  5 Sep 2026 16:37:03 +0200 (CEST)
Date: Sat, 5 Sep 2026 16:37:03 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Rick Macklem <rick.macklem@gmail.com>
Cc: Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>, 
	NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Tom Haynes <thomas.haynes@hammerspace.com>, 
	linux-nfs <linux-nfs@vger.kernel.org>, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	Benji Wiebe <itsme@benjiwiebe.com>
Message-ID: <1805277599.19343755.1788619023447.JavaMail.zimbra@desy.de>
In-Reply-To: <CAM5tNy7Yjk=mm9rq9YUuYF6LEd2v2tp3p3unDxgEv8xU4oXO0Q@mail.gmail.com>
References: <20260904-pnfs-ff-v1-1-5f502cf25401@kernel.org> <CAM5tNy7Yjk=mm9rq9YUuYF6LEd2v2tp3p3unDxgEv8xU4oXO0Q@mail.gmail.com>
Subject: Re: [PATCH] nfsd: don't offer flexfiles layouts when NFSv3 isn't
 being served
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; 
	boundary="----=_Part_19343756_246654939.1788619023590"
X-Mailer: Zimbra 10.1.20_GA_4893 (ZimbraWebClient - FF155 (Linux)/10.1.20_GA_4894)
Thread-Topic: nfsd: don't offer flexfiles layouts when NFSv3 isn't being served
Thread-Index: Oj2HF3nIqZ3QKgLnwLGlEMO/Ts8Tdg==

------=_Part_19343756_246654939.1788619023590
Date: Sat, 5 Sep 2026 16:37:03 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Rick Macklem <rick.macklem@gmail.com>
Cc: Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>, 
	NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Tom Haynes <thomas.haynes@hammerspace.com>, 
	linux-nfs <linux-nfs@vger.kernel.org>, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	Benji Wiebe <itsme@benjiwiebe.com>
Message-ID: <1805277599.19343755.1788619023447.JavaMail.zimbra@desy.de>
In-Reply-To: <CAM5tNy7Yjk=mm9rq9YUuYF6LEd2v2tp3p3unDxgEv8xU4oXO0Q@mail.gmail.com>
References: <20260904-pnfs-ff-v1-1-5f502cf25401@kernel.org> <CAM5tNy7Yjk=mm9rq9YUuYF6LEd2v2tp3p3unDxgEv8xU4oXO0Q@mail.gmail.com>
Subject: Re: [PATCH] nfsd: don't offer flexfiles layouts when NFSv3 isn't
 being served
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Mailer: Zimbra 10.1.20_GA_4893 (ZimbraWebClient - FF155 (Linux)/10.1.20_GA_4894)
Thread-Topic: nfsd: don't offer flexfiles layouts when NFSv3 isn't being served
Thread-Index: Oj2HF3nIqZ3QKgLnwLGlEMO/Ts8Tdg==

Hi Rick,

our server runs with v4.1 DSes whenissues FF layouts.
The patch is touching server side only, so I hope the
client side still works as expected. For quite some time
I had submitted a patch[0] that decomples ff layout driver
from v3 client so that client still can use v4.1 DSes
ever if v3 client in not compiled.

[0]: a68c6fbb638a "nfs41: drop dependency between flexfiles layout driver a=
nd NFSv3 modules"

Best regards,
   Tigran.


----- Original Message -----
> From: "Rick Macklem" <rick.macklem@gmail.com>
> To: "Jeff Layton" <jlayton@kernel.org>
> Cc: "Chuck Lever" <cel@kernel.org>, "NeilBrown" <neil@brown.name>, "Olga =
Kornievskaia" <okorniev@redhat.com>, "Dai Ngo"
> <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>, "Tom Haynes" <thomas=
.haynes@hammerspace.com>, "linux-nfs"
> <linux-nfs@vger.kernel.org>, "linux-kernel" <linux-kernel@vger.kernel.org=
>, "Benji Wiebe" <itsme@benjiwiebe.com>
> Sent: Friday, 4 September, 2026 21:04:18
> Subject: Re: [PATCH] nfsd: don't offer flexfiles layouts when NFSv3 isn't=
 being served

> On Fri, Sep 4, 2026 at 9:50=E2=80=AFAM Jeff Layton <jlayton@kernel.org> w=
rote:
>>
>> The flexfiles layout driver hands out a deviceinfo that names this serve=
r
>> as an NFSv3 DS (flexfilelayout.c hardcodes da->version =3D 3). With v3
>> disabled, the client can't talk to the DS: it loops on v3 NULL calls tha=
t
>> the server answers with PROG_MISMATCH, and I/O hangs in D state.
>>
>> Skip LAYOUT_FLEX_FILES in nfsd4_setup_layout_type() unless v3 is enabled=
.
>>
>> Reported-by: Benji Wiebe <itsme@benjiwiebe.com>
>> Closes:
>> https://lore.kernel.org/linux-nfs/c734eeb8-8486-4491-bb4d-b9656cbaffbe@a=
pp.fastmail.com/
>> Fixes: 9b9960a0ca47 ("nfsd: Add a super simple flex file server")
>> Assisted-by: LLM
>> Signed-off-by: Jeff Layton <jlayton@kernel.org>
>> ---
>>  fs/nfsd/nfs4layouts.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
>> index 22bcb6d09f70..cef4d40c89a2 100644
>> --- a/fs/nfsd/nfs4layouts.c
>> +++ b/fs/nfsd/nfs4layouts.c
>> @@ -127,10 +127,12 @@ nfsd4_set_deviceid(struct nfsd4_deviceid *id, cons=
t struct
>> svc_fh *fhp,
>>
>>  void nfsd4_setup_layout_type(struct svc_export *exp)
>>  {
>> +       struct nfsd_net *nn =3D net_generic(exp->cd->net, nfsd_net_id);
>>         struct super_block *sb =3D exp->ex_path.mnt->mnt_sb;
>>         expfs_block_layouts_t block_supported =3D exportfs_layouts_suppo=
rted(sb);
>>
>> -       if (IS_ENABLED(CONFIG_NFSD_FLEXFILELAYOUT))
>> +       if (IS_ENABLED(CONFIG_NFSD_FLEXFILELAYOUT) &&
>> +           nfsd_vers(nn, 3, NFSD_TEST))
>>                 exp->ex_layout_types |=3D 1 << LAYOUT_FLEX_FILES;
>>         if (IS_ENABLED(CONFIG_NFSD_BLOCKLAYOUT) &&
>>             (block_supported & EXPFS_BLOCK_IN_BAND_ID))
> Although most ffv1 servers use NFSv3 DSs, it is possible for an ffv1
> layout to specify NFSv4.
>=20
> rick
> ps: I don't know how you'd check to see if the layout will be an
>      NFSv3 one. (If the server only does NFSv3 layouts, then I'd
>      guess this patch is ok?)
>=20
>>
>> ---
>> base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
>> change-id: 20260904-pnfs-ff-485ac21042a6
>>
>> Best regards,
>> --
>> Jeff Layton <jlayton@kernel.org>
>>

------=_Part_19343756_246654939.1788619023590
Content-Type: application/pkcs7-signature; name=smime.p7s; smime-type=signed-data
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCAMIIF
2zCCBEOgAwIBAgIQF4XHXEetKIAlPr4cevwe6zANBgkqhkiG9w0BAQsFADBUMQswCQYDVQQGEwJO
TDEZMBcGA1UECgwQR0VBTlQgVmVyZW5pZ2luZzEqMCgGA1UEAwwhR0VBTlQgVENTIEF1dGhlbnRp
Y2F0aW9uIFJTQSBDQSA1MB4XDTI2MDgxOTEwMjQyMloXDTI3MDkxODEwMjQyMVowgakxEzARBgoJ
kiaJk/IsZAEZFgNvcmcxFjAUBgoJkiaJk/IsZAEZFgZ0ZXJlbmExEzARBgoJkiaJk/IsZAEZFgN0
Y3MxCzAJBgNVBAYTAkRFMS4wLAYDVQQKDCVEZXV0c2NoZXMgRWxla3Ryb25lbi1TeW5jaHJvdHJv
biBERVNZMSgwJgYDVQQDDB9UaWdyYW4gTWtydGNoeWFuIHRpZ3JhbkBkZXN5LmRlMIIBojANBgkq
hkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA1eVMTvYES3GLqhn0zqaiJ3+XELMB9tHgwI+HtD3+n3V8
tmPEw6Rkoo+3WKEg/Mo1vgJrGaYROtXEaS5fGx+AAMa9vVJyfPMjumhcIjXUXl2CU5HbCAu08grX
czcniDMT5QRR/W7n17XA3aK+okPpX51RTk4sg5r3JXglII8htTr3qNLNvH1a9xF3ha79h+24H2ST
+sYiCgG4xBSmkwZiS/to00/aQ95WQ3vDbfNrPWwItWBecf7EqVuopNHLhODCfnVxdbovoGn6ro/+
dDup9DtKC6EyYT3GiNEr/1eogutQXgS5H8xNc8qnJy5XhuVi8heqQZ94gohqoR44a5QELk3znB92
PLDpW2Gl1N1+SXdXe7QnpOivsYQHIFIGsTzAsMlKP6Cdl7dfRVsymfp8ZAZCyA3fBg9K0Ir/C9rd
PHPAL4rUphHBlL6Em+GF0LO39HrJhpAFzT9n0dYVR31gQ49VsgttPdYniQ9dnIL0X5/FEOkq9zvp
ogJ9ByBlPW5/AgMBAAGjggFRMIIBTTAfBgNVHSMEGDAWgBSDrT4rvBOJjYgJHL8g3F+4MVXq8TBX
BggrBgEFBQcBAQRLMEkwRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuZ2VhbnQtcHJ2LmhhcmljYS5n
ci9HRUFOVC1UQ1MtQ2xpZW50LUF1dGgtUjUuY2VyMDUGA1UdIAQuMCwwDAYKKoZIhvdMBQICBTAN
BgsqhkiG90wFAgMDAzANBgsqhkiG90wFAgMBAjAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUH
AwQwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5nZWFudC1wcnYuaGFyaWNhLmdyL0dFQU5U
LVRDUy1DbGllbnQtQXV0aC1SNS5jcmwwHQYDVR0OBBYEFCFcUBIsi3uUE1kq670tMz37WCGaMA4G
A1UdDwEB/wQEAwIFoDANBgkqhkiG9w0BAQsFAAOCAYEAYnxTcPN9abeQXN8K8LPynNHsq08LUVDd
ROKGdsmCdVJLdDLI4VF2qxw/hyPALNb2XrjnYz6F7zpsOjGWh13IpDCN1ydcy14kurOq0XWeXPuJ
Cwh2+Q35xZX0CiMxDXVV8HbW5DLSkmMti5lAshu47KgJmQc2OqRY2Fx1A4d/eAsNfP0tmF6Z6wpW
AtTd2F0Tlv9yovu5uRWlSBrQOgzTKA4L9yELBtFwxZfRJXf7TdzJqcEmOxZqcRkA8vGMCTcaRzaQ
4az1+q6raJV8DvkKjtxrxg+CyjlY2ARFev1ofuPUXlJ2RGA1hhFuSWPIg/FFRiAUYkEkyrFSEmsx
ZhGuRFuikFrg9+lpqNv2Qnx8VHi0ZWZXRCbua2qv8bpYLv17jVSfUPT65Iha/0zVZiE9YeeE4r62
WH6cQdKylQM4vw0iVSgdbxA59um3VKi10sVGJnA076uEvCJw05tVpBb7Ac6CpIgPFJ2A/QzhFm5V
u+aRa6gZyRqPl0tGh5YNmmVkAAAxggLkMIIC4AIBATBoMFQxCzAJBgNVBAYTAk5MMRkwFwYDVQQK
DBBHRUFOVCBWZXJlbmlnaW5nMSowKAYDVQQDDCFHRUFOVCBUQ1MgQXV0aGVudGljYXRpb24gUlNB
IENBIDUCEBeFx1xHrSiAJT6+HHr8HuswDQYJYIZIAWUDBAIBBQCggc4wGAYJKoZIhvcNAQkDMQsG
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjYwOTA1MTQzNzAzWjAtBgkqhkiG9w0BCTQxIDAe
MA0GCWCGSAFlAwQCAQUAoQ0GCSqGSIb3DQEBCwUAMC8GCSqGSIb3DQEJBDEiBCDPmIHiyF8+Y5YW
SDm3iUojIVz/Nx91u18ySKS0XBe/HTA0BgkqhkiG9w0BCQ8xJzAlMAoGCCqGSIb3DQMHMA4GCCqG
SIb3DQMCAgIAgDAHBgUrDgMCBzANBgkqhkiG9w0BAQsFAASCAYBPehPDt7qEAMX9y0Vwa4XcC8gr
1F+4yVPthtuiBhNEKAYASWbfRUIeNahLwH66g2zfLf/4ZIk6J33eUoVhW25cYnUQ7BGwu1h/DwlP
8nJOwxd8/XzJ33LBr99NUZPLictNDYHiqHLgKlwSTIbZ+JGS2lXfY6/0SfMCHxDv5S0kmJ3nABn+
uykzrFpkpQtjQLqkPIQePUJT90M0RdkiFiXbM0sE53jDegc/Yv+cRw0AiZ0gPycdkHIDMNxhyjeO
P8SmmXvCuXLX5RJAM8gcqTQK4CyueRl+MGsFOR38BqRkr1BpgVSGTf+l8DMS+xMbUGNmUFh7UaWi
E4VBcNZ8UiA3coL9au9kLrVsbe48Q6ctVBtAr4uuxxpVgThAejnG0vHb25fwtrMJjInUzIC829oK
Lm9ku1ISVh4Xp7tDL2dwYWz9dSMPs4ywf1QY0RM/1AFDSiQ8ae3c+EYa8CqLQx8A1b8RGSRxsZcB
T5AFBBjEgYPpNQCwFtWAi8lHesteQoMAAAAAAAA=
------=_Part_19343756_246654939.1788619023590--

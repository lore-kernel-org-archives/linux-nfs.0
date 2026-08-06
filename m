Received: from smtp-o-3.desy.de (smtp-o-3.desy.de [131.169.56.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD3EB2673B0
	for <linux-nfs@vger.kernel.org>; Thu,  6 Aug 2026 12:25:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786019150; cv=none; b=L3sQyecj4mnAYLP09sAAuzpUghxvGpFgjbZQctwFhge/PPbJQke+tvkhHnXh54FuxKtzo5kwtiCMAhR6aN6mn6IppJOkd9ttQZIaAawhwUoqSdNXa8yJcQpNq3ZqmCCAC+yGWiTAGtsCRlJnDK0YoqV9CbRqirdzCV5g3y7CRG8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786019150; c=relaxed/simple;
	bh=5CERTNSPPw5SFJPR8AX1J4/kXejx+5Cr++/cp11X8/0=;
	h=Date:From:To:Cc:Message-ID:In-Reply-To:References:Subject:
	 MIME-Version:Content-Type; b=miE72vA7ceMNQI7iAwqP9W3UGDCCBvwZ0FEQXr5JaD6YzkoxT/b2k0c9J7rd19us+tFvl2PGJpdYLlQSVem8qE8cHoDv0Ue5GF2xHeX92pFMcCXqK9+7E3SN7KXDgZX44FX0alludYdmb4fJ3gWpv6zU5HaNX7lQAAUAPqMUpqg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=uXLfLpNW; arc=none smtp.client-ip=131.169.56.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="uXLfLpNW"
Received: from smtp-o-2.desy.de (smtp-o-2.desy.de [131.169.56.155])
	by smtp-o-3.desy.de (Postfix) with ESMTP id A482B11F97B
	for <linux-nfs@vger.kernel.org>; Thu,  6 Aug 2026 14:20:06 +0200 (CEST)
Received: from smtp-buf-1.desy.de (smtp-buf-1.desy.de [131.169.56.164])
	by smtp-o-2.desy.de (Postfix) with ESMTP id F3FF613F656
	for <linux-nfs@vger.kernel.org>; Thu,  6 Aug 2026 14:19:58 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-2.desy.de F3FF613F656
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1786018799; bh=+moBTHQk89DwEchfwKv52pedLkdLvIp/n8OqeYVMve4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=uXLfLpNW+USQA9Wk0Yk4TrpsLM4wf3Sm9hRvuLG8bwTdDrqLiXEhlmVE0urMnC45x
	 sj7gmpVyNfq0DvCZTYotl8pSDqJLOMuS5+YpSLsz95kFg60e3x5lcUvEdwQ4fVmu/1
	 5b6ME9AAYXfO3ZbkEVSnncub4ymnGylmgESt0lsc=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [131.169.56.130])
	by smtp-buf-1.desy.de (Postfix) with ESMTP id E312320056;
	Thu,  6 Aug 2026 14:19:58 +0200 (CEST)
Received: from c1722.mx.srv.dfn.de (c1722.mx.srv.dfn.de [194.95.239.47])
	by smtp-m-2.desy.de (Postfix) with ESMTP id CEC22160043;
	Thu,  6 Aug 2026 14:19:58 +0200 (CEST)
Received: from smtp-intra-3.desy.de (smtp-intra-3.desy.de [IPv6:2001:638:700:1038::1:45])
	by c1722.mx.srv.dfn.de (Postfix) with ESMTP id EC3AB100034;
	Thu, 06 Aug 2026 14:19:56 +0200 (CEST)
Received: from z-mbx-3.desy.de (z-mbx-3.desy.de [131.169.55.141])
	by smtp-intra-3.desy.de (Postfix) with ESMTP id B0DD61A0041;
	Thu,  6 Aug 2026 14:19:55 +0200 (CEST)
Date: Thu, 6 Aug 2026 14:19:55 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Jeuk Kim <jeuk20.kim@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	linux-nfs <linux-nfs@vger.kernel.org>, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	hui81 qi <hui81.qi@samsung.com>, 
	j-young choi <j-young.choi@samsung.com>, 
	peng yun <peng.yun@samsung.com>, qian01 li <qian01.li@samsung.com>, 
	xing1 he <xing1.he@samsung.com>, jeuk20 kim <jeuk20.kim@samsung.com>
Message-ID: <212778944.5657888.1786018795534.JavaMail.zimbra@desy.de>
In-Reply-To: <20260708074433.390161-1-jeuk20.kim@samsung.com>
References: <20260708074433.390161-1-jeuk20.kim@samsung.com>
Subject: Re: [PATCH 0/2] NFSv4/flexfiles: support loosely coupled data
 servers
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; 
	boundary="----=_Part_5657889_1691032884.1786018795660"
X-Mailer: Zimbra 10.1.20_GA_4893 (ZimbraWebClient - FF153 (Linux)/10.1.20_GA_4894)
Thread-Topic: NFSv4/flexfiles: support loosely coupled data servers
Thread-Index: LRGwZvKu0U3P3dYFYb+7CKXV4CSY1A==

------=_Part_5657889_1691032884.1786018795660
Date: Thu, 6 Aug 2026 14:19:55 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Jeuk Kim <jeuk20.kim@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	linux-nfs <linux-nfs@vger.kernel.org>, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	hui81 qi <hui81.qi@samsung.com>, 
	j-young choi <j-young.choi@samsung.com>, 
	peng yun <peng.yun@samsung.com>, qian01 li <qian01.li@samsung.com>, 
	xing1 he <xing1.he@samsung.com>, jeuk20 kim <jeuk20.kim@samsung.com>
Message-ID: <212778944.5657888.1786018795534.JavaMail.zimbra@desy.de>
In-Reply-To: <20260708074433.390161-1-jeuk20.kim@samsung.com>
References: <20260708074433.390161-1-jeuk20.kim@samsung.com>
Subject: Re: [PATCH 0/2] NFSv4/flexfiles: support loosely coupled data
 servers
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Mailer: Zimbra 10.1.20_GA_4893 (ZimbraWebClient - FF153 (Linux)/10.1.20_GA_4894)
Thread-Topic: NFSv4/flexfiles: support loosely coupled data servers
Thread-Index: LRGwZvKu0U3P3dYFYb+7CKXV4CSY1A==

----- Original Message -----
> From: "Jeuk Kim" <jeuk20.kim@gmail.com>
> To: "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "linux-kernel" <linux-kernel@vger.kernel.org>, "Tigran Mkrtchyan"
> <tigran.mkrtchyan@desy.de>, "hui81 qi" <hui81.qi@samsung.com>, "j-young choi" <j-young.choi@samsung.com>, "peng yun"
> <peng.yun@samsung.com>, "qian01 li" <qian01.li@samsung.com>, "xing1 he" <xing1.he@samsung.com>, "jeuk20 kim"
> <jeuk20.kim@samsung.com>
> Sent: Wednesday, 8 July, 2026 09:44:31
> Subject: [PATCH 0/2] NFSv4/flexfiles: support loosely coupled data servers

> RFC 8435 allows a flexfiles data server to be loosely coupled, i.e. an
> NFS server that does not advertise EXCHGID4_FLAG_USE_PNFS_DS via
> EXCHANGE_ID. The client currently ignores the ffdv_tightly_coupled flag
> and treats every DS as tightly coupled, so NFSv4.1+ I/O to a loosely
> coupled DS fails during DS setup.
> 
> Patch 2 threads the decoded tightly_coupled flag down to the DS connect
> path and, when it is false, skips the NFS_CS_PNFS flag and the
> is_ds_client() check.
> 
> Patch 1 fixes pre-existing NFSv4.0 DS crashes on the same path (the DS
> client has no session).
> 
> Jeuk Kim (2):
>  NFSv4/flexfiles: fix NULL dereference for NFSv4.0 data servers
>  NFSv4/flexfiles: support loosely coupled data servers
> 
> fs/nfs/filelayout/filelayoutdev.c         |  2 +-
> fs/nfs/flexfilelayout/flexfilelayout.c    |  3 ++-
> fs/nfs/flexfilelayout/flexfilelayoutdev.c |  3 ++-
> fs/nfs/internal.h                         |  3 ++-
> fs/nfs/nfs4client.c                       |  5 +++--
> fs/nfs/nfs4session.c                      | 21 ++++++++++++++-------
> fs/nfs/nfs4session.h                      |  3 ++-
> fs/nfs/pnfs.h                             |  3 ++-
> fs/nfs/pnfs_nfs.c                         | 14 +++++++++-----
> 9 files changed, 37 insertions(+), 20 deletions(-)
> 
> --
> 2.43.0


Just checked that the tightly coupled servers configuration is still ok.

Tested-by: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>

------=_Part_5657889_1691032884.1786018795660
Content-Type: application/pkcs7-signature; name=smime.p7s; smime-type=signed-data
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCAMIIF
2zCCBEOgAwIBAgIQBBL/+bEcDC3Q01JGn3M5ITANBgkqhkiG9w0BAQsFADBUMQswCQYDVQQGEwJO
TDEZMBcGA1UECgwQR0VBTlQgVmVyZW5pZ2luZzEqMCgGA1UEAwwhR0VBTlQgVENTIEF1dGhlbnRp
Y2F0aW9uIFJTQSBDQSA1MB4XDTI1MTIxMjE0MDk0MloXDTI3MDExMTE0MDk0MVowgakxEzARBgoJ
kiaJk/IsZAEZFgNvcmcxFjAUBgoJkiaJk/IsZAEZFgZ0ZXJlbmExEzARBgoJkiaJk/IsZAEZFgN0
Y3MxCzAJBgNVBAYTAkRFMS4wLAYDVQQKDCVEZXV0c2NoZXMgRWxla3Ryb25lbi1TeW5jaHJvdHJv
biBERVNZMSgwJgYDVQQDDB9UaWdyYW4gTWtydGNoeWFuIHRpZ3JhbkBkZXN5LmRlMIIBojANBgkq
hkiG9w0BAQEFAAOCAY8AMIIBigKCAYEArfnI6mD8MyGhRXT544OuIOATR0q0ViKjZWMjNO0PYJ7b
WrA2ahLCMyOw18kaAhArvmyhASlCZGHAeHjMPQAcRWoBQyLXkbusXBqxPQbApGXcXERNGXja00Xk
MrZCGe198EcRgn52hDbmcOhQPlyY/fKp3ukpPDLyQEeZFDDz4KeKFrZ6Qc3ps/yZqjQ2bXY8l93W
G+0DVbP6e2AM0DW4fWDYoafLvnMyl2J5yhYjYXtFkcV7iiDUuQH/lZvYvRQTzlir0jczribIPpss
zxcctqleZRX646qBT+lI0nP+EgdGPCXNteJGbwGHw7DQqXDk+0AIYShiiTMayRODX65uCwRG9iO5
mtibWMeFTzGOy8HG09PFlc8VG8+2pZtIYLPIof65dykviDm0vI0A36iaw7gI5RRy1K6dGpJscKU2
V5d+LlhVu5qjBayUfJQhy4jykZplaeXvQThZ9rg9ngz+FwlEz7tlM5U1hepzD7s1snyVaOGtRiQt
yWSUKcMB0DPJAgMBAAGjggFRMIIBTTAfBgNVHSMEGDAWgBSDrT4rvBOJjYgJHL8g3F+4MVXq8TBX
BggrBgEFBQcBAQRLMEkwRwYIKwYBBQUHMAKGO2h0dHA6Ly9jcnQuZ2VhbnQtcHJ2LmhhcmljYS5n
ci9HRUFOVC1UQ1MtQ2xpZW50LUF1dGgtUjUuY2VyMDUGA1UdIAQuMCwwDAYKKoZIhvdMBQICBTAN
BgsqhkiG90wFAgMDAzANBgsqhkiG90wFAgMBAjAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUH
AwQwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5nZWFudC1wcnYuaGFyaWNhLmdyL0dFQU5U
LVRDUy1DbGllbnQtQXV0aC1SNS5jcmwwHQYDVR0OBBYEFDxIMH6YFtPoOHuwqAzVWAjUq9klMA4G
A1UdDwEB/wQEAwIFoDANBgkqhkiG9w0BAQsFAAOCAYEAM3+V2E77QHQaDQSi0RRpdct0OrebGrBQ
1UZHmxhwyy1LaTERW/8J70lDP9FxYJlk77whB853mwW/LukNXzRNW/mgpuIlVQH+uooys5NbIgl2
zVuIhQ/7CWO3xYbKyxk8pUwvk43qR/hVprL0djOGm9Wr31AmryK9KMXpod95pv3hydpAPZi+4Kux
GtsmX69ggbcB518och4jij+KCtGCaFHjLbek40VYwAjIRSfwpVTKgFefkTEo+/G9KiJiT3p8Z/RL
6VDc+pB+GFNAW/+Z6nAkRWJKZFrVAEFqX2by2v+CTu9oLPUKiRTCEuSXCqwsMO40qzYT8Tjp9+sq
KfeGDPzRxd/J4G6JSsLpRrCesQnKRTwqEF6yUfvNyrqKe9fImt/UriOFjXcdPqAkhFWIr0d/fZQp
1upqYQ1PnuyfdOU4Ct6NN9PGopyB4i+iKWaECe4W4iPZsF+qWUmynQpbAwDu/UvBN3U4wdrDdeO6
XZ3HQ0q/aG67FOeLCkhOgnvqAAAxggLkMIIC4AIBATBoMFQxCzAJBgNVBAYTAk5MMRkwFwYDVQQK
DBBHRUFOVCBWZXJlbmlnaW5nMSowKAYDVQQDDCFHRUFOVCBUQ1MgQXV0aGVudGljYXRpb24gUlNB
IENBIDUCEAQS//mxHAwt0NNSRp9zOSEwDQYJYIZIAWUDBAIBBQCggc4wGAYJKoZIhvcNAQkDMQsG
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjYwODA2MTIxOTU2WjAtBgkqhkiG9w0BCTQxIDAe
MA0GCWCGSAFlAwQCAQUAoQ0GCSqGSIb3DQEBCwUAMC8GCSqGSIb3DQEJBDEiBCAhcgPRqjMlSYcK
u4WUYaEZCsbzlXWYC9kaOxnhJCcX/zA0BgkqhkiG9w0BCQ8xJzAlMAoGCCqGSIb3DQMHMA4GCCqG
SIb3DQMCAgIAgDAHBgUrDgMCBzANBgkqhkiG9w0BAQsFAASCAYB5SC8h5usMtYAw1rSRio3iEEyU
3j13VxhYb/zXfzudcktfc9CmTuLQsqW3C6/AL2T3dvnsME1yUXEBAiyvBIL4ut1qUkQr6FFGjGZI
CJmBHtEtO0X/QhOnDVDFsA3E0UJbLNdri4VEIk6rqATWNYcxwAWoSzIaZtVCuCitZsMjNs0JCO42
rMXyM1G1laaeH3m7Wu3Xka6eypLhIlyVdzvEnU3BFvjkbD9dOh+9NLaetPu3pU/JQzn/cgJrpAvP
zN4YZmb6DPbAf3A+ySoKE9wJczdIwa3GycHF+J31wcvLnrIAIZdpnewRcuTeqLoXfp9geHbiQKGL
vgVKb2aj1yHZSa4BIhcHb+01580TfRGsYspqMvDNOl/w/fpaJzyPtA/c1c2ha7dcnBjw3lsh3Qki
N8as1w3EzAtEohlvrf6H+EjbR2Kin4YCQFC8HpJnx9+Ia467U+wRxZuRMttwxUn/dfACo/GMrhkB
OUlLr5PLVPQviDxq5UuBwq7Bo272wK8AAAAAAAA=
------=_Part_5657889_1691032884.1786018795660--

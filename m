Received: from smtp-o-1.desy.de (smtp-o-1.desy.de [131.169.56.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C723231842
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 09:58:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792058301; cv=none; b=fmYZ3VGWVhTWtqyv3PDeHVIqohYCYRvJVQTri1DbllsIZXVDj5TdRHCDC6V3vV2Bs+A307LOMHnBOOthlqrp7f6bpdfR2LwgPcxHusw38XcRXQBtRdDl5P0MBaDSB/Ac3cmoSAChg7H+CqikO2wR8LWdRwBbeK/IMptIkaAMLGM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792058301; c=relaxed/simple;
	bh=RMYxru2h89UntrjZ1JsOCXlAeJM5EMvGpuBOLWSAAo8=;
	h=Date:From:To:Cc:Message-ID:In-Reply-To:References:Subject:
	 MIME-Version:Content-Type; b=PE8tpYCeaHkiQ2UJY6N+egyjnwFDm75zASe2MoSjJWDS3pUs/LxoWG39xbu4yE2DZxPYIlWoNieOYtIBs2ZrwW3Rqj1MvRPE1bcDPubdkcA+dg0qL39/0NroQK+QMugmQ8yaHIfvzIsinoPgvVPJTPbrSWXkXLofJeiBpfp6KIo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=XC68FoKm; arc=none smtp.client-ip=131.169.56.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="XC68FoKm"
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [131.169.56.166])
	by smtp-o-1.desy.de (Postfix) with ESMTP id 3DD9311F746
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 11:58:09 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-1.desy.de 3DD9311F746
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1792058289; bh=Zno1aOZVAdvmFozVVMTfaa+S7QnrcF/kL8FfHahc0yU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=XC68FoKmn6eCjjdbP/EtV0KNJgjNWGDRCnANw5U0IePDWaBErRGjQdsyV2b81g437
	 dNdHDmnJfp2Q0Ufq29P+b1cAa4PVbg1B2ixs56T6+oB7wmaHmqgFuq6EsjyOwEWbyH
	 qbUBaMdOYB6AD7JxSytIWLT5BoSxDo+jj6KMWrxg=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [131.169.56.130])
	by smtp-buf-3.desy.de (Postfix) with ESMTP id 314CBC0040;
	Thu, 15 Oct 2026 11:58:09 +0200 (CEST)
Received: from b1722.mx.srv.dfn.de (b1722.mx.srv.dfn.de [IPv6:2001:638:d:c302:acdc:1979:2:e7])
	by smtp-m-2.desy.de (Postfix) with ESMTP id 276C5160043;
	Thu, 15 Oct 2026 11:58:09 +0200 (CEST)
Received: from smtp-intra-2.desy.de (smtp-intra-2.desy.de [IPv6:2001:638:700:1038::1:53])
	by b1722.mx.srv.dfn.de (Postfix) with ESMTP id 7BF9016005F;
	Thu, 15 Oct 2026 11:58:08 +0200 (CEST)
Received: from z-mbx-3.desy.de (z-mbx-3.desy.de [131.169.55.141])
	by smtp-intra-2.desy.de (Postfix) with ESMTP id 4C07720044;
	Thu, 15 Oct 2026 11:58:08 +0200 (CEST)
Date: Thu, 15 Oct 2026 11:58:08 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Mike Snitzer <snitzer@kernel.org>, trondmy <trondmy@kernel.org>, 
	anna <anna@kernel.org>
Message-ID: <1376472961.6381734.1792058288217.JavaMail.zimbra@desy.de>
In-Reply-To: <20261010221839.42172-1-tigran.mkrtchyan@desy.de>
References: <20261010221839.42172-1-tigran.mkrtchyan@desy.de>
Subject: Re: [PATCH 0/2] pnfs/flexfiles: make DS connect application
 interrupt resistent
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; 
	boundary="----=_Part_6381735_1122327683.1792058288234"
X-Mailer: Zimbra 10.1.21_GA_4899 (ZimbraWebClient - FF158 (Linux)/10.1.21_GA_4899)
X-Zimbra-Message-Verification: hash=SHA256;guid=OGFiMWRkYmUwNDdlYzM4ZTg1NGZkYzJmZDI2ZWVmNjIwMmVjYTEwYWUzOGIwMTM3MjJkZmMyY2Q2MDZmYjYxYg==
Thread-Topic: pnfs/flexfiles: make DS connect application interrupt resistent
Thread-Index: j3LdEzMcBautDIN3mgO7O2wESPtKog==

------=_Part_6381735_1122327683.1792058288234
Date: Thu, 15 Oct 2026 11:58:08 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Mike Snitzer <snitzer@kernel.org>, trondmy <trondmy@kernel.org>, 
	anna <anna@kernel.org>
Message-ID: <1376472961.6381734.1792058288217.JavaMail.zimbra@desy.de>
In-Reply-To: <20261010221839.42172-1-tigran.mkrtchyan@desy.de>
References: <20261010221839.42172-1-tigran.mkrtchyan@desy.de>
Subject: Re: [PATCH 0/2] pnfs/flexfiles: make DS connect application
 interrupt resistent
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Mailer: Zimbra 10.1.21_GA_4899 (ZimbraWebClient - FF158 (Linux)/10.1.21_GA_4899)
X-Zimbra-Message-Verification: hash=SHA256;guid=OGFiMWRkYmUwNDdlYzM4ZTg1NGZkYzJmZDI2ZWVmNjIwMmVjYTEwYWUzOGIwMTM3MjJkZmMyY2Q2MDZmYjYxYg==
Thread-Topic: pnfs/flexfiles: make DS connect application interrupt resistent
Thread-Index: j3LdEzMcBautDIN3mgO7O2wESPtKog==


Dear NFS fellows,

I will appreciate comments on this series, including the separate krb5i handshake patch.

Thanks in advance,
   Tigran.

----- Original Message -----
> From: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> To: "trondmy" <trondmy@kernel.org>, "anna" <anna@kernel.org>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "Mike Snitzer" <snitzer@kernel.org>, "Tigran Mkrtchyan"
> <tigran.mkrtchyan@desy.de>
> Sent: Sunday, 11 October, 2026 00:18:37
> Subject: [PATCH 0/2] pnfs/flexfiles: make DS connect application interrupt resistent

> In our testing we hit a situation where the pNFS flexfiles client
> goes into an infinite loop. The application spawns one reader process
> per CPU core to read multiple files in parallel, and kills the readers
> once a fixed time budget expires. The killed processes never exit.
> 
> We have identified three issues:
> 
> - Concurrent connections to data servers are serialized in
>  nfs4_discover_server_trunking() (not addressed yet).
> 
> - Regardless of the configured security flavor, the client always
>  tries krb5i first, addressed in a separate patch:
>  https://lore.kernel.org/linux-nfs/20261009155802.540179-1-tigran.mkrtchyan@desy.de/T/#u
> 
> - ff_layout_pg_init_read() and ff_layout_pg_init_write() retry in a
>  loop with ssleep() when no data server is available. Since ssleep()
>  is uninterruptible and the loop does not check for fatal signals,
>  a task with SIGKILL pending never leaves the loop.
> 
> These two patches address the last issue.
> 
> The patches tested on 7.3-rc3 and RHEL 5.14.0-757 kernels (with
> backport).
> 
> Tigranve  Mkrtchyan (2):
>  pNFS/flexfiles: make pg_init retry loops killable
>  pNFS/flexfiles: don't report an interrupted DS connect as a DS error
> 
> fs/nfs/flexfilelayout/flexfilelayout.c    | 23 ++++++++++++++++++++---
> fs/nfs/flexfilelayout/flexfilelayoutdev.c |  5 +++++
> 2 files changed, 25 insertions(+), 3 deletions(-)
> 
> --
> 2.56.0

------=_Part_6381735_1122327683.1792058288234
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
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjYxMDE1MDk1ODA4WjAtBgkqhkiG9w0BCTQxIDAe
MA0GCWCGSAFlAwQCAQUAoQ0GCSqGSIb3DQEBCwUAMC8GCSqGSIb3DQEJBDEiBCCXynHDRNY85DnQ
LwMlqryg2kLM+lKmRw582jYWpQ9H8TA0BgkqhkiG9w0BCQ8xJzAlMAoGCCqGSIb3DQMHMA4GCCqG
SIb3DQMCAgIAgDAHBgUrDgMCBzANBgkqhkiG9w0BAQsFAASCAYBz8bcoYkcurJtN+stm2NNZotDW
MvV2cFF9TYNNFWQCAnZX8jNlcJMDB0mBma9azXFeie3daL4zN26XMwrNKGqsdCAfAKTevLxtA92x
cgObreyj9ybkoTsjj2lC7EvnKZBCGOQJXaR6WyMHuF4FzSWH+8A33uD6e+Yide160QSkK5MQJ3dx
4RgVDWx2Axn6BhDejZhGbvy6waV0uZqgi3+6Ikrr1lk823WJT5CuWXn6U0IgVaP3FiNqB/BwA13Z
6boxJuDDLqHtSfYLXM5gPGr7uQSx9nhRSsaRJPLh7zbE+srznfn4Fono7BC/0+Lu2nqRcPr3Tzzc
WevlLqwUfGeTfuPRaGVfBdO7h8TGacmN0/6gLwDqjdOLLTZI3MFvv66Of0C063XbJM4FpX/ueosg
/PB68IgLa5AYHA4Z0R6w8VgxKcvUL+lMnj5RwugpBIg9pnyr7K/xDNbk1rvPjhJwa7KdFRXbfU2f
mBa2M3FiNee/mbRqf7/82pKy54N1OEEAAAAAAAA=
------=_Part_6381735_1122327683.1792058288234--

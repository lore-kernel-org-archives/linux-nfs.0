Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=131.169.56.154
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792766137;
	b=JgToiP8tX6eKm4pSHzBETV90LiIRxH4xy/zU6ZbmJ0+TFAe2IqUs+KMmOAykIVBEyCY6
	 VCiZcuIUWR9gCY1LWvFkqSVhrsFoVei8k3u9ddyk2gTQhvm99yXoUwQ8G30neZOUGkbuj
	 tydIlGMwQ7gSSYFljDy79DcJY0TSCOnV8fkcFc3zL17139pk56kKswjccjy/R+Sbw7nPN
	 hH78xvJsgxAntbbijdxV4MLTdRj8+pW5cYM+FFmXcB1bZT0/eYh4YdxiUutYrrExLJcVO
	 Uu/78SiHyDnNYZnwwvLc8r4E23NwQ+whzFe/TwdTFzPYBziDPv4ugk6OmIwle07NUnA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792766137;
	h=DMARC-Filter:Received:DKIM-Filter:DKIM-Signature:Received:Received:
	 Received:Received:Date:From:To:Cc:Message-ID:In-Reply-To:References:
	 Subject:MIME-Version:Content-Type:X-Mailer:
	 X-Zimbra-Message-Verification:Thread-Topic:Thread-Index;
	bh=kkYbkRyhS2ImnyNcoNCVU1neMXsmc0r7AzOu31Po2+w=;
	b=eMamAzIC+Ra7tiWKLBM5gzsVNkk1vurFGIFPzHetf6GN+EWqRb/ypEHFJDI7gPyruUFK
	 neRHIGi1HpniwKVWCKWar/p2Xtz7k3qKFNkB8imeIqKIX8fCvYg4V8Dpc1QcCj1MYx8O3
	 cyjBA4bcndF3L/0PEoLQD4quak3g3e+YHER7U8O8Uj8Ahdv9GCVOfL0VHuig43nFObw4N
	 sAPp9Ly9+DxhTDFUeuZ12In9/DIOsnBw9OfQbcrGJRvzGq+H8dEgQJ6garwdhTiVs2Mnb
	 aqBCmc7m16TXc1Uou1eE6nv+R5v4YUexfpx2+d6IURSdFxHi3Ldy0noeqA05f7SSX2A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=desy.de;
	spf=pass smtp.mailfrom=desy.de;
	dkim=pass header.d=desy.de header.i=@desy.de header.a=rsa-sha256 header.s=default header.b=T+SH1rSm;
	arc=none smtp.remote-ip=131.169.56.154
Received: from smtp-o-1.desy.de (smtp-o-1.desy.de [131.169.56.154])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56511606A321
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 14:35:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 56511606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=desy.de header.i=@desy.de header.a=rsa-sha256 header.s=default header.b=T+SH1rSm
Received: from smtp-buf-2.desy.de (smtp-buf-2.desy.de [IPv6:2001:638:700:1038::1:a5])
	by smtp-o-1.desy.de (Postfix) with ESMTP id 27BEC11F74C
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 16:35:27 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-1.desy.de 27BEC11F74C
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1792766127; bh=kkYbkRyhS2ImnyNcoNCVU1neMXsmc0r7AzOu31Po2+w=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=T+SH1rSmWhOKadVtOfXlz/+jkGCgON7sb+PkFWqysL+9dJjibBDEC9s7OI/NAn6oH
	 vdpL/zU8A54BX8xhiY4w+Xp0dBtoxFSIEyVCW3MKtg2TamAp3DA9xvip5EO1IG4Jf2
	 FrwmFBuq2rQv2vTLYpSvte4NF+R7rXrulxST4kiI=
Received: from smtp-m-3.desy.de (smtp-m-3.desy.de [IPv6:2001:638:700:1038::1:83])
	by smtp-buf-2.desy.de (Postfix) with ESMTP id 17189120043;
	Fri, 23 Oct 2026 16:35:27 +0200 (CEST)
Received: from b1722.mx.srv.dfn.de (b1722.mx.srv.dfn.de [194.95.235.47])
	by smtp-m-3.desy.de (Postfix) with ESMTP id 02F3A1A004F;
	Fri, 23 Oct 2026 16:35:27 +0200 (CEST)
Received: from smtp-intra-2.desy.de (smtp-intra-2.desy.de [131.169.56.83])
	by b1722.mx.srv.dfn.de (Postfix) with ESMTP id A3A3E160059;
	Fri, 23 Oct 2026 16:35:25 +0200 (CEST)
Received: from z-mbx-3.desy.de (z-mbx-3.desy.de [131.169.55.141])
	by smtp-intra-2.desy.de (Postfix) with ESMTP id 3B1F220044;
	Fri, 23 Oct 2026 16:35:25 +0200 (CEST)
Date: Fri, 23 Oct 2026 16:35:24 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Roberto Bergantinos Corpas <rbergant@redhat.com>, 
	Mike Snitzer <snitzer@kernel.org>, 
	Antonio Alvarez Feijoo <antonio.feijoo@suse.com>, 
	linux-nfs <linux-nfs@vger.kernel.org>, 
	Anna Schumaker <anna.schumaker@hammerspace.com>, 
	Trond Myklebust <trond.myklebust@hammerspace.com>
Message-ID: <1015823097.11117914.1792766124992.JavaMail.zimbra@desy.de>
In-Reply-To: <1925D89E-8A84-4FE3-95BC-93061E6578BC@hammerspace.com>
References: <20260902133554.28863-1-antonio.feijoo@suse.com> <CACWnjLzVeXAfVWgg_YTqtNTDd7LXSkM9dA0znwdPLY=4226bbQ@mail.gmail.com> <1925D89E-8A84-4FE3-95BC-93061E6578BC@hammerspace.com>
Subject: Re: [PATCH] NFSv4/flexfiles: add a soft dependency on nfsv3
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; 
	boundary="----=_Part_11117915_928664516.1792766125110"
X-Mailer: Zimbra 10.1.21_GA_4899 (ZimbraWebClient - FF158 (Linux)/10.1.21_GA_4899)
X-Zimbra-Message-Verification: hash=SHA256;guid=YzcyZjkyMTQ4ODU3NjgyZDQ0Mzg2ODI5YmVjNWZiNzEyODI0NWNhNDE3MGFjMGI1MGZlMzQ0M2JkZTFlMTNjZQ==
Thread-Topic: NFSv4/flexfiles: add a soft dependency on nfsv3
Thread-Index: QsMUdekVKcbujfwHvBvUj/1OP7bVcw==

------=_Part_11117915_928664516.1792766125110
Date: Fri, 23 Oct 2026 16:35:24 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Roberto Bergantinos Corpas <rbergant@redhat.com>, 
	Mike Snitzer <snitzer@kernel.org>, 
	Antonio Alvarez Feijoo <antonio.feijoo@suse.com>, 
	linux-nfs <linux-nfs@vger.kernel.org>, 
	Anna Schumaker <anna.schumaker@hammerspace.com>, 
	Trond Myklebust <trond.myklebust@hammerspace.com>
Message-ID: <1015823097.11117914.1792766124992.JavaMail.zimbra@desy.de>
In-Reply-To: <1925D89E-8A84-4FE3-95BC-93061E6578BC@hammerspace.com>
References: <20260902133554.28863-1-antonio.feijoo@suse.com> <CACWnjLzVeXAfVWgg_YTqtNTDd7LXSkM9dA0znwdPLY=4226bbQ@mail.gmail.com> <1925D89E-8A84-4FE3-95BC-93061E6578BC@hammerspace.com>
Subject: Re: [PATCH] NFSv4/flexfiles: add a soft dependency on nfsv3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Mailer: Zimbra 10.1.21_GA_4899 (ZimbraWebClient - FF158 (Linux)/10.1.21_GA_4899)
X-Zimbra-Message-Verification: hash=SHA256;guid=YzcyZjkyMTQ4ODU3NjgyZDQ0Mzg2ODI5YmVjNWZiNzEyODI0NWNhNDE3MGFjMGI1MGZlMzQ0M2JkZTFlMTNjZQ==
Thread-Topic: NFSv4/flexfiles: add a soft dependency on nfsv3
Thread-Index: QsMUdekVKcbujfwHvBvUj/1OP7bVcw==


Frankly, I think this is my change that has introduced the trouble:

a68c6fbb638a ("nfs41: drop dependency between flexfiles layout driver and NFSv3 modules")

The intent was to be able to build a kernel with flexfiles support even if NFSv3 is disabled.
No objections if you want to revert it.

Best regards,
   Tigran.


----- Original Message -----
> From: "Benjamin Coddington" <ben.coddington@hammerspace.com>
> To: "Roberto Bergantinos Corpas" <rbergant@redhat.com>, "Mike Snitzer" <snitzer@kernel.org>
> Cc: "Antonio Alvarez Feijoo" <antonio.feijoo@suse.com>, "linux-nfs" <linux-nfs@vger.kernel.org>, "Mike Snitzer"
> <snitzer@kernel.org>, "Anna Schumaker" <anna.schumaker@hammerspace.com>, "Trond Myklebust"
> <trond.myklebust@hammerspace.com>
> Sent: Friday, 23 October, 2026 16:16:32
> Subject: Re: [PATCH] NFSv4/flexfiles: add a soft dependency on nfsv3

> On 23 Oct 2026, at 8:30, Roberto Bergantinos Corpas wrote:
> 
>> There is another problematic case for this problem : if an
>> unprivileged container attempts pNFS I/O, SELinux may block the
>> request_module() call, leading to a writeback hang instead of a boot hang.
>>
>> Having the module pre-loaded at mount time avoids that scenario too.
> 
> I think this is a stronger case than the nfs-root, which already requires a
> sysadmin to have knowledge and desire to configure the client a certain way,
> and can certainly apply the work-around.
> 
> Roberto's case would look functional to the admin, and the failure would
> happen later and be difficult to diagnose.
> 
> I think Fixes: 7a375cafc14e (7.2.y) is the accurate tag, though - because
> before that the -EPROTONOSUPPORT would fall back to the MDS - it gives the
> WARN, but doesn't hang the system.
> 
> I also think 7a375cafc14e also needs a follow-on fix (Cc: Mike) - because it
> now causes permanent failure cases to retry forever- we should probably just
> fail the IO.
> 
> The last thing here is that the MODULE_SOFTDEP is just informative, it only
> advises modprobe and initramfs builders.  It not going to fix
> CONFIG_NFS_V4=y with CONFIG_NFS_V3=n or m.  So - I think we should just make
> flexfiles publish a hard dependency on a v3 symbol, which fixes the module
> dependency directly, and also fixup Kconfig so that there aren't unexpected
> build failures as a result.
> 
> My 2 cents,
> 
> Ben

------=_Part_11117915_928664516.1792766125110
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
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjYxMDIzMTQzNTI1WjAtBgkqhkiG9w0BCTQxIDAe
MA0GCWCGSAFlAwQCAQUAoQ0GCSqGSIb3DQEBCwUAMC8GCSqGSIb3DQEJBDEiBCA3FJW+DFfFl+L0
Zrw6pQs8a8rRv4iOD1kbLsXMaw0dWTA0BgkqhkiG9w0BCQ8xJzAlMAoGCCqGSIb3DQMHMA4GCCqG
SIb3DQMCAgIAgDAHBgUrDgMCBzANBgkqhkiG9w0BAQsFAASCAYAF0WglUapWZiYz5dbTdMsVLgKU
+feMEUD6fTFz5DoMAeDaiXXEpwgRuDtCpVJs00U4C2iGIuw6N3kPaOmlUiqRwO4zZ5mvC38v7o0N
+gH3o7IC6n0Iibfde0jHOgrVRRDcwY636a8/tJEUT89skL29nerEa7La1Bnonaz3p712ZK2ic613
n0MslTiZxAfwt+jf4diodOLHl155rB6ksMYKU9U20z99hOIpD+ZrjPS1UV1dBk+DKkwkQ6T3dufa
/FTxIPIlhe3DFxppc0cjWoPJ24W4YGH4JOpLcP73COPpTvZsGfBUWHUoEO06bKd4l5Buzd4CpeyS
+lgZg7wE0D95aO+3/My/TenbpJSH44XILURc1sTRVgf1jpzmi2iQwiXsUFKQ+0fSVGztVBazl9Kv
UbI/STF+lPpt8FJnBt5oidD2RvfQoLHo6+5vTZWmfXnVi/u2Jd+BM1hxzkzUWZyAWCvgnIjivo3F
9RB837HCE1vEbicH7vIPPme6hBAdxlIAAAAAAAA=
------=_Part_11117915_928664516.1792766125110--

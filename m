Received: from smtp-o-3.desy.de (smtp-o-3.desy.de [131.169.56.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C0B238332A
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 12:33:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790944395; cv=none; b=asC2kIlHEnFV6LNGxRCsL4mSzEM2AimGqxoJexaXMxtSwpHe0l8eQUvQRN0BER8kFc5K0ckxYBkPTZcBOxQazWyTWzZ4vfIlWqUG4OC+Xik4ZPU9KBPOiVrT+JxqZGnZQFrDaRnXx/plHuuYRPyiSSnpV5wsIzTytNVGqalq04c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790944395; c=relaxed/simple;
	bh=pjnP+Ow2HhTLFceYyo1FomHrTOk9wzlswVMbNOUeVKM=;
	h=Date:From:To:Message-ID:Subject:MIME-Version:Content-Type; b=rGqhPsjNQSSMQr6/dPCNxs1++sacGbXHqT2OCysfPDu6QV13UBx8gSUmBO+SJ97hTSdVCCnlUL0K1lOwpb3G4QUksh++KGGiyy9G7elh7ltFf6kHaAI8rgXm6UzEKB2nY13ADld4ol0keu70iAcEoNGCOa8SPp/dXXyFZ/Kubz8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=SVkfkGBW; arc=none smtp.client-ip=131.169.56.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="SVkfkGBW"
Received: from smtp-o-2.desy.de (smtp-o-2.desy.de [IPv6:2001:638:700:1038::1:9b])
	by smtp-o-3.desy.de (Postfix) with ESMTP id 3728111F7BF
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 14:33:09 +0200 (CEST)
Received: from smtp-buf-1.desy.de (smtp-buf-1.desy.de [IPv6:2001:638:700:1038::1:a4])
	by smtp-o-2.desy.de (Postfix) with ESMTP id 1A48F13F648
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 14:33:01 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-2.desy.de 1A48F13F648
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1790944381; bh=NclaJswByo/556VxEDPj+6361wewDQIle/kpEHnSASk=;
	h=Date:From:To:Subject:From;
	b=SVkfkGBWRkH46KesMURAqptAFNeDbSv1i1boHu8iFeGgpQ2RzxzKmo0EoQaPFNvGj
	 Ny9xr8mYtJ/rtf0UfBdwtgoQP9wMRG+qmjENqSGfkZwuwWz8l5v6ipBiF+Y8PKLRZE
	 ZVBw4Y0rOx3ai5zzUdS5uHB0Ir+orLrz9Mu8loZw=
Received: from smtp-m-1.desy.de (smtp-m-1.desy.de [IPv6:2001:638:700:1038::1:81])
	by smtp-buf-1.desy.de (Postfix) with ESMTP id 12B5820056
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 14:33:01 +0200 (CEST)
Received: from a1722.mx.srv.dfn.de (a1722.mx.srv.dfn.de [IPv6:2001:638:d:c301:acdc:1979:2:e7])
	by smtp-m-1.desy.de (Postfix) with ESMTP id 0C53440045
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 14:33:01 +0200 (CEST)
Received: from smtp-intra-3.desy.de (smtp-intra-3.desy.de [IPv6:2001:638:700:1038::1:45])
	by a1722.mx.srv.dfn.de (Postfix) with ESMTP id 572C63200A2
	for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2026 14:33:00 +0200 (CEST)
Received: from z-mbx-3.desy.de (z-mbx-3.desy.de [131.169.55.141])
	by smtp-intra-3.desy.de (Postfix) with ESMTP id 3D7431A0048
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 14:33:00 +0200 (CEST)
Date: Fri, 2 Oct 2026 14:33:00 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <2038989007.1029515.1790944380174.JavaMail.zimbra@desy.de>
Subject: Duplicated RPC client initialization with flexfiles layout
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; 
	boundary="----=_Part_1029516_2015217015.1790944380188"
X-Mailer: Zimbra 10.1.21_GA_4899 (ZimbraWebClient - FF156 (Linux)/10.1.21_GA_4899)
X-Zimbra-Message-Verification: hash=SHA256;guid=MTg4YTQyMTk5NDBjM2U0ZGZiZGE3YzcxYjlmZmFjNWMxZDI5MzNmOTMxZGY4MzliZjIyNzAxYjM1MTUzNWJhNQ==
Thread-Index: 22UzsmavIDQ46bprPtkl3d10Oo3y8g==
Thread-Topic: Duplicated RPC client initialization with flexfiles layout

------=_Part_1029516_2015217015.1790944380188
Date: Fri, 2 Oct 2026 14:33:00 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <2038989007.1029515.1790944380174.JavaMail.zimbra@desy.de>
Subject: Duplicated RPC client initialization with flexfiles layout
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Mailer: Zimbra 10.1.21_GA_4899 (ZimbraWebClient - FF156 (Linux)/10.1.21_GA_4899)
X-Zimbra-Message-Verification: hash=SHA256;guid=MTg4YTQyMTk5NDBjM2U0ZGZiZGE3YzcxYjlmZmFjNWMxZDI5MzNmOTMxZGY4MzliZjIyNzAxYjM1MTUzNWJhNQ==
Thread-Index: 22UzsmavIDQ46bprPtkl3d10Oo3y8g==
Thread-Topic: Duplicated RPC client initialization with flexfiles layout


Dear NFS fellows,

Your users were able to trigger a weird bug in rpc/flexfiles/our server.
The behavior is that the pNFS flexfiles client tries to create connections
to 6 data servers in parallel. However, the initialization to each DS happe=
ns
twice; for that, the connection is dropped at the TCP level. The wireshark
packes of one of the DSes and bpftrace-based tracing of rpc_create_xprt
functions are below.

This is with REHL 5.14.0-687.52.1 (at the moment); I will check whether I c=
an reproduce it with the upstream kernel as well.

Any ideas?

Best regards,
   Tigran.

    1 0.000000000 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 76 763 =E2=86=
=92 24006 [SYN] Seq=3D0 Win=3D64240 Len=3D0 MSS=3D1460 SACK_PERM=3D1 TSval=
=3D3321872006 TSecr=3D0 WS=3D512
    2 0.000000000 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 76 [TCP Out-Of-=
Order] 763 =E2=86=92 24006 [SYN] Seq=3D0 Win=3D64240 Len=3D0 MSS=3D1460 SAC=
K_PERM=3D1 TSval=3D3321872006 TSecr=3D0 WS=3D512
    3 0.000043716 1xx.yy.50.150 =E2=86=92 1xx.yy.182.55 TCP 76 24006 =E2=86=
=92 763 [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D65160 Len=3D0 MSS=3D1460 SACK_PERM=
=3D1 TSval=3D196237843 TSecr=3D3321872006 WS=3D128
    4 0.000049947 1xx.yy.50.150 =E2=86=92 1xx.yy.182.55 TCP 76 [TCP Out-Of-=
Order] 24006 =E2=86=92 763 [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D65160 Len=3D0 M=
SS=3D1460 SACK_PERM=3D1 TSval=3D196237843 TSecr=3D3321872006 WS=3D128
    5 0.000101734 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 76 941 =E2=86=
=92 24006 [SYN] Seq=3D0 Win=3D64240 Len=3D0 MSS=3D1460 SACK_PERM=3D1 TSval=
=3D3321872006 TSecr=3D0 WS=3D512
    6 0.000101734 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 76 [TCP Out-Of-=
Order] 941 =E2=86=92 24006 [SYN] Seq=3D0 Win=3D64240 Len=3D0 MSS=3D1460 SAC=
K_PERM=3D1 TSval=3D3321872006 TSecr=3D0 WS=3D512
    7 0.000130403 1xx.yy.50.150 =E2=86=92 1xx.yy.182.55 TCP 76 24006 =E2=86=
=92 941 [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D65160 Len=3D0 MSS=3D1460 SACK_PERM=
=3D1 TSval=3D196237844 TSecr=3D3321872006 WS=3D128
    8 0.000135463 1xx.yy.50.150 =E2=86=92 1xx.yy.182.55 TCP 76 [TCP Out-Of-=
Order] 24006 =E2=86=92 941 [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D65160 Len=3D0 M=
SS=3D1460 SACK_PERM=3D1 TSval=3D196237844 TSecr=3D3321872006 WS=3D128
    9 0.000134812 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 62 763 =E2=86=
=92 24006 [RST] Seq=3D1 Win=3D0 Len=3D0
   10 0.000134812 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 62 763 =E2=86=
=92 24006 [RST] Seq=3D1 Win=3D0 Len=3D0
   11 0.000243066 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 68 941 =E2=86=
=92 24006 [ACK] Seq=3D1 Ack=3D1 Win=3D64512 Len=3D0 TSval=3D3321872006 TSec=
r=3D196237844
   12 0.000243066 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 68 [TCP Dup ACK=
 11#1] 941 =E2=86=92 24006 [ACK] Seq=3D1 Ack=3D1 Win=3D64512 Len=3D0 TSval=
=3D3321872006 TSecr=3D196237844
   13 0.000479359 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 68 941 =E2=86=
=92 24006 [FIN, ACK] Seq=3D1 Ack=3D1 Win=3D64512 Len=3D0 TSval=3D3321872006=
 TSecr=3D196237844
   14 0.000479359 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 68 [TCP Out-Of-=
Order] 941 =E2=86=92 24006 [FIN, ACK] Seq=3D1 Ack=3D1 Win=3D64512 Len=3D0 T=
Sval=3D3321872006 TSecr=3D196237844
   15 0.000595959 1xx.yy.50.150 =E2=86=92 1xx.yy.182.55 TCP 68 24006 =E2=86=
=92 941 [FIN, ACK] Seq=3D1 Ack=3D2 Win=3D65280 Len=3D0 TSval=3D196237844 TS=
ecr=3D3321872006
   16 0.000603322 1xx.yy.50.150 =E2=86=92 1xx.yy.182.55 TCP 68 [TCP Out-Of-=
Order] 24006 =E2=86=92 941 [FIN, ACK] Seq=3D1 Ack=3D2 Win=3D65280 Len=3D0 T=
Sval=3D196237844 TSecr=3D3321872006
   17 0.000688326 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 68 941 =E2=86=
=92 24006 [ACK] Seq=3D2 Ack=3D2 Win=3D64512 Len=3D0 TSval=3D3321872007 TSec=
r=3D196237844
   18 0.000688326 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 68 [TCP Dup ACK=
 17#1] 941 =E2=86=92 24006 [ACK] Seq=3D2 Ack=3D2 Win=3D64512 Len=3D0 TSval=
=3D3321872007 TSecr=3D196237844
   19 1.023913451 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 76 716 =E2=86=
=92 24006 [SYN] Seq=3D0 Win=3D64240 Len=3D0 MSS=3D1460 SACK_PERM=3D1 TSval=
=3D3321873030 TSecr=3D0 WS=3D512
   20 1.023913451 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 76 [TCP Out-Of-=
Order] 716 =E2=86=92 24006 [SYN] Seq=3D0 Win=3D64240 Len=3D0 MSS=3D1460 SAC=
K_PERM=3D1 TSval=3D3321873030 TSecr=3D0 WS=3D512
   21 1.023967704 1xx.yy.50.150 =E2=86=92 1xx.yy.182.55 TCP 76 24006 =E2=86=
=92 716 [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D65160 Len=3D0 MSS=3D1460 SACK_PERM=
=3D1 TSval=3D196238867 TSecr=3D3321873030 WS=3D128
   22 1.023976295 1xx.yy.50.150 =E2=86=92 1xx.yy.182.55 TCP 76 [TCP Out-Of-=
Order] 24006 =E2=86=92 716 [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D65160 Len=3D0 M=
SS=3D1460 SACK_PERM=3D1 TSval=3D196238867 TSecr=3D3321873030 WS=3D128
   23 1.023981641 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 76 708 =E2=86=
=92 24006 [SYN] Seq=3D0 Win=3D64240 Len=3D0 MSS=3D1460 SACK_PERM=3D1 TSval=
=3D3321873030 TSecr=3D0 WS=3D512
   24 1.023981641 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 76 [TCP Out-Of-=
Order] 708 =E2=86=92 24006 [SYN] Seq=3D0 Win=3D64240 Len=3D0 MSS=3D1460 SAC=
K_PERM=3D1 TSval=3D3321873030 TSecr=3D0 WS=3D512
   25 1.024021399 1xx.yy.50.150 =E2=86=92 1xx.yy.182.55 TCP 76 24006 =E2=86=
=92 708 [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D65160 Len=3D0 MSS=3D1460 SACK_PERM=
=3D1 TSval=3D196238867 TSecr=3D3321873030 WS=3D128
   26 1.024027734 1xx.yy.50.150 =E2=86=92 1xx.yy.182.55 TCP 76 [TCP Out-Of-=
Order] 24006 =E2=86=92 708 [SYN, ACK] Seq=3D0 Ack=3D1 Win=3D65160 Len=3D0 M=
SS=3D1460 SACK_PERM=3D1 TSval=3D196238867 TSecr=3D3321873030 WS=3D128
   27 1.024056233 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 62 716 =E2=86=
=92 24006 [RST] Seq=3D1 Win=3D0 Len=3D0
   28 1.024056233 1xx.yy.182.55 =E2=86=92 1xx.yy.50.150 TCP 62 716 =E2=86=
=92 24006 [RST] Seq=3D1 Win=3D0 Len=3D0



2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.51.163:24010 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.51.163:24010 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.50.147:24001 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.50.147:24001 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.50.150:24006 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.50.150:24006 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.51.218:24011 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.51.218:24011 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.50.59:24005 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.50.59:24005 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.52.47:24001 err=3D-512
2026-10-02 14:14:25: rpc_create_xprt failed: 1xx.yy.52.47:24001 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.51.163:24010 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.51.163:24010 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.50.147:24001 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.50.147:24001 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.50.150:24006 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.50.150:24006 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.51.218:24011 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.51.218:24011 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.50.59:24005 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.50.59:24005 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.52.47:24001 err=3D-512
2026-10-02 14:14:26: rpc_create_xprt failed: 1xx.yy.52.47:24001 err=3D-512

------=_Part_1029516_2015217015.1790944380188
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
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjYxMDAyMTIzMzAwWjAtBgkqhkiG9w0BCTQxIDAe
MA0GCWCGSAFlAwQCAQUAoQ0GCSqGSIb3DQEBCwUAMC8GCSqGSIb3DQEJBDEiBCDZD4Pzr/zTYAgc
QsQw1kzcjK4LtjkQn6+Z0/yL1L3KYjA0BgkqhkiG9w0BCQ8xJzAlMAoGCCqGSIb3DQMHMA4GCCqG
SIb3DQMCAgIAgDAHBgUrDgMCBzANBgkqhkiG9w0BAQsFAASCAYBRkow+8MWkxsullXU7NetFaD+i
mpmbPY6GHbkdoJbV+X0M75dLEg98qVJ750lKhVGdqNz+K1a4Q5JK6C1Qbkz62OkBryfpZA6mbHi4
0VC6Fpyj8G0nx/LZyLN2ug6aIt/cVlNIhUwVJ5X73Zt83drsAc3hm4ZJt9P1o9ZUSxIYq7N024kl
QSP8QVQYngCsqudyBLuEXQXcs1yKrn6BEf9t+EvodoKQK0gIKz/ZBxjRG34qXcMkDEHNqTKiCiRA
e3zkTGkE10TN21qTgtp8FETLv8ORyEpCUs2ako+9shWD7ws9mjCBYFVIJgjREgTYBduIk1mGc9/R
amJgVKc1/zfb3fpzoXoGKgXSO8fJEN/F5kvBplC13a6eKq5VvFKaGActzpQiP8GLoEuuVwDF6XdT
CwAruywCV2w/3fuvNmRtjP51lOUR7nOV9n4i/+yOFMzojXyD9WHHvdohRkp7MM2ZMuhcXKPLTeUV
SBSgAkfOuEzQ+kW7bCw0S89bjrq/a+gAAAAAAAA=
------=_Part_1029516_2015217015.1790944380188--

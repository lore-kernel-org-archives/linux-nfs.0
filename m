Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=77.238.36.76
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794237679;
	b=yOGL+FEoskmOsXy6/aBUrbS3ceO3/EDnMibNeuAHg4qD0dew5zmC91GkpkQyVAII1o/o
	 wdOZmqbb5TkpAECf3AkvR7izlI00cJJ9IBxlEx0It8JyK2X5785stnlRsZ+0JKxNi0k4b
	 czMDb6zuzMn8EBn8kaWQtN8C9HcqlGgFNSmS2ddFlzFmruj7Zjhrlqqcfpj9uELt1uokj
	 9bXFp6V97dPxGv9XjfkDp4jtXptXE1XVJEJYxX28z7oH8FeVLrQNqKDU+JNUJ+EMqaDzv
	 xZrWBNrqAvRtL48tehlAHP8yxEQ1gZ4eOEXmKzaY7sXMblRZWw/7d3a+6FQYWM08yGw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794237679;
	h=DMARC-Filter:Received:DKIM-Signature:X-Halon-ID:Received:Received:
	 Received:From:To:Subject:Thread-Topic:Thread-Index:Date:Message-ID:
	 Accept-Language:Content-Language:X-MS-Has-Attach:X-MS-TNEF-Correlator:
	 x-originating-ip:Content-Type:Content-Transfer-Encoding:MIME-Version;
	bh=7NyIN+kd6fL4g084z0NHE5PkANBPFmzRv1/2b5Yjdac=;
	b=SwaFrTDSfYT9ccRmdtcB2aJmc6ZIDs7MvzaEsgiUnXi7h0R4yrxRd4DWAhCK5m3Q2r2p
	 C6fxpvJ027iKIWHjbIrNilD0m0jE1ddr4vRhuWmtaP9IIhYfn26rX8ogRYH4k0byQYDku
	 yutmYae5IJ8sOLr2CnFjNoEsf1nKCtDbRrAkEUOMw61s9OCKWKo+Tdy5UzuacUQ8f8cVh
	 CeynX5pFESxx99e5plsKJ9l4LFye+5+J8+6pRwHa3VCOsJvpNBqCt/YLYSplqjcWET3x3
	 fJA64ImlqiWQbihLPGmBH+nKhnIeMHjYZxouW66VXt2+ZiadTzJXARSoA2I86Gs//NA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=astro.su.se;
	spf=pass smtp.mailfrom=astro.su.se;
	dkim=pass header.d=astro.su.se header.i=@astro.su.se header.a=rsa-sha256 header.s=halonv1 header.b=XcPXlKS0;
	arc=none smtp.remote-ip=77.238.36.76
Received: from mail-prod-route11.it.su.se (mail-prod-route11.it.su.se [77.238.36.76])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16F10606EE8F
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 15:21:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 16F10606EE8F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=astro.su.se
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=astro.su.se
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=astro.su.se header.i=@astro.su.se header.a=rsa-sha256 header.s=halonv1 header.b=XcPXlKS0
Received: from mailfilter-ng-1.sunet.se (mailfilter-ng-1.sunet.se [192.36.171.207])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mail-prod-route11.it.su.se (Postfix) with ESMTPS id 4jNYQY1WQyz1q4
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 16:21:09 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=astro.su.se; s=halonv1;
	h=mime-version:content-transfer-encoding:content-type:message-id:date:subject:
	 to:from:from;
	bh=7NyIN+kd6fL4g084z0NHE5PkANBPFmzRv1/2b5Yjdac=;
	b=XcPXlKS0B7RG9Y8mmppHpL68TU3d4X5n8QOVSk0Xm6fdJi0QRn49EII7gJsABnynUEGwWGAxVZZ/i
	 xVmU1aBTDcn15fNHKfg472B6AglGYqrWJ+p7PXzVbY7prVqCmbMFgE0xmksVYBJFq4Pzl4qUmaf0Li
	 wI1gmPqW+TeCXCul3h3N4eKB3tIzlzQ3WQH8ocyeI80rhO1+bmF5Xubat9e1x9A7Mp8bceZY8Qzy5q
	 f2GOk/dmE8uuxNdTzx6ngR0mppPWZ2deKEvFSLDHQEUKvdhijyMRaz0qWmJ9Gm+lKu16/cpaYbSKST
	 Xo9naCH96VAKQzg0B2HrXF16tC7dL4Q==
X-Halon-ID: 2ebcf670-dc51-11f1-aa92-0050569a42e2
Received: from mail.su.se (ebox-prod-srv28.win.su.se [130.237.162.248])
	by mailfilter-ng-1.sunet.se (Halon) with ESMTPS
	id 2ebcf670-dc51-11f1-aa92-0050569a42e2;
	Mon, 09 Nov 2026 15:21:05 +0000 (UTC)
Received: from ebox-prod-srv24.win.su.se (130.237.162.54) by
 ebox-prod-srv28.win.su.se (130.237.162.248) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.56; Mon, 9 Nov 2026 16:21:05 +0100
Received: from ebox-prod-srv24.win.su.se ([169.254.3.135]) by
 ebox-prod-srv24.win.su.se ([169.254.3.135]) with mapi id 15.02.2562.056; Mon,
 9 Nov 2026 16:21:05 +0100
From: Sergio Gelato <sergio.gelato@astro.su.se>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Documentation bug: instructions on how to report bugs
Thread-Topic: Documentation bug: instructions on how to report bugs
Thread-Index: AQHdcFp8K1jSUbRWyUmzb8QQnOYG+A==
Date: Mon, 9 Nov 2026 15:21:05 +0000
Message-ID: <3a7fbd2993f44ad8a0744b482ad3b006@astro.su.se>
Accept-Language: en-SE, sv-SE, it-IT, en-US, en-IE, ja-JP
Content-Language: aa
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

According to https://wiki.linux-nfs.org/wiki/index.php/Reporting_bugs this =
list is the official place to report bugs about nfs-utils. The list address=
 also appears as the value of the bug-report argument to AC_INIT in configu=
re.ac; as far as I can tell that is only used in utils/mount/error.c.

Various files in the nfs-utils distribution (I'm looking at version 3.1.1) =
suggest different reporting channels. This can be confusing. Here is a poss=
ibly incomplete list:

support/nfsidmap/idmapd.conf.5:Report bugs to <nfsv4@linux-nfs.org>
utils/idmapd/idmapd.man:.\"Please report any bugs to Marius Aamodt Eriksen
utils/nfsstat/nfsstat.man: Further bugs can be found or reported at http://=
nfs.sf.net/ [which has a dead link to http://www.spinics.net/lists/linux-nf=
s/]
tools/rpcdebug/rpcdebug.man: ditto

The nfsdclnts(8) man page, on the other hand, looks OK.

The README file in the distribution mentions the address of this list but d=
oesn't mention bugs. The links in section 0 may also need updating; e.g., l=
ibevent is now at https://libevent.org/ and the SourceForge page states "Ol=
d home of linux NFS development; see linux-nfs.org instead now."=

Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.53
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795428261;
	b=paYlTnPrYWwJ0Sfkdo5ph4BDHpgcvTnOWxYkj+LSH67xrzctjDIwN79gtUUvHnFbesLM
	 h8T/lgTz26GzCL5YbpHEEk1MN7cE/jbTcOAnKevFlXmvDoiLkTLcYVhdw1283FZ4ecvBL
	 7xO7jB++hrSL9KzrjnvCrp6m2yrGgqXvPFusMa1zhYyOOUZNuVhgyQS1vpHeTG0OdEU5O
	 oaJaJSZ3i2/eNlj1D9KV8grZvpYJT0ZZJw8f+3hel16uE6gEIFiYjkTbUEwl2EidjncTz
	 AwoJXYXMisnjdZ4EkkJnKirTDC+5EnilGWOF4DoATEFHZ6Dc+XuyF4eCtxGykYQTk4Q==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795428261;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Content-Type:
	 Content-Transfer-Encoding;
	bh=9EtYWA20vHFjk3oSjqw1Yh8niIKJUPjCkmcYE9ME8UU=;
	b=A89lvpe3MKRJVTYf3fTIMdHB50p9B770SwLm0rwgc6hVScujig2FyJsIODDWp958jy1d
	 hbb0iApWr/pSvFEx73iZPjJ2DembDzpMCKiZTtdYOtXYG2mxJQroqrFyLgLiiJUQ/7NQy
	 8MjN3usWa8UMvXahmaPj5waHCxNlMWNFBemWYsQM+bYnZ1ikOeiImWl5EKb/+BGr6GIaA
	 /kQZA2C1sdr8OSUJGdpbe1vonYLydZ9naC9YMzEo5pCy/VtaPZqknQCd6Ty+xOMsyzE9N
	 aumTzES1sTORZOOoX/WTcOULep2AFsH5xCGUjPgUnzg4swFINJ/2R+9hLObD0BX2oyg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=JLzvEwoM;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.53
Received: from mail-ed1-f53.google.com (mail-ed1-f53.google.com [209.85.208.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4229C606A31E
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 10:04:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4229C606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=JLzvEwoM
Received: by mail-ed1-f53.google.com with SMTP id 4fb4d7f45d1cf-6b8b20b2538so3545192a12.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 02:04:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795428259; cv=none;
        d=google.com; s=arc-20260327;
        b=HaGZm+15a3AWl3p9Ou17a0gb8d0QlRVXc2LXLWZFQ6KXvlkPI3PJbolCnNwlGAWDDK
         3dA+14F3DvcY5/ArmB0xpzA+x9r2ATAD/zP/QE2PQrl4ehf+XwqC9eHemzXN3/0gGIuE
         lCxYsG3ghZAiIKiaM7trGgyYit2pmWTj+WEWOw6DwlTy15UcmNmiltpkJYbkycNd8ioN
         r6L9cyqXFUHebImuNr+GGQZk+mFrRL4fV2t5i5zNhX616VHa5zjkuLiRNGM0JCQDf6lY
         AtOl05D4X0ekmLXVmomY6NjNah8zPKOXoAmO1QYfeJXpmukHsXzqRLcUFW+UnPyn8M5h
         5DAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:dkim-signature;
        bh=9EtYWA20vHFjk3oSjqw1Yh8niIKJUPjCkmcYE9ME8UU=;
        fh=A3pMOUK00huGibGCZBFsLekFLVbB5hHGKjUNNKwO+5E=;
        b=X1nYl28/cwnBbuRvsiNzhnKY/uEXl0JmyamhhC0becQJcurmdrQLGsGaaoCsWzCny5
         lPxHh8/92UzV5afTK165Nhb3YRFHNaf1RG4y5rNEhA2sIdSJNVDZg8OjSR7wpUzJoMup
         Vw6dEcuLyX4V10QDuWzhLGrrG1NHfkY66lbiPY+c2TOqMnG9zexzWEgbpxQrSXK7xojD
         6MmRQNiAYBMNXoREURVA4qdugWAq6tyVhpcCP6RNOwzrggD7exBeqhqK44LFB62//9So
         PBJhE2twbsqh59ShKmtG9TKKrVMil3QkonwTBzbS0xTMpJ3xsSy6zAEa2vljSI8NDjnP
         NvEw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795428259; x=1796033059; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=9EtYWA20vHFjk3oSjqw1Yh8niIKJUPjCkmcYE9ME8UU=;
        b=JLzvEwoMV9lx62cIaUBfQr6uHYEveMXDX47SG4diowGirlwuLcOm17YUr46sPLmk3e
         DmESyl3a5CYnyawyUFlLVr79wWGd981E3YIlTdlWU6KZ/kdQgkq+UnR9v31KT2pAUseQ
         dx96u4Qa7fKqIhxpMhO0GukvArhPce1hQiTiXxllBGGArbTTOIttlEyhCqfam9zh3CGG
         neXcYOaVzmRYQRWGVk46EySVnS4o/Ymu+QRJZ//pT+F/k5MdRKkt1bm7NfcNCfpzQE23
         gTvFkV50YPj6I1pmqRTNEMzJFjsqHU0ua4+EW03OCm8HJYSp9yy7A914xJ8wVow7vRrb
         UGBA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795428259; x=1796033059;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=9EtYWA20vHFjk3oSjqw1Yh8niIKJUPjCkmcYE9ME8UU=;
        b=iCUa4m9hL5cYUAKmwF22uoWd+DYiRsbL8asEI2H7DBqC+QeYBZ7CvpZOQqrvjMBZh1
         JXc25Dv7391yDsLDBQr0OkO7uO/N4AH6+rj/09E6IeXHZygB9ZX6HdMfpLPo6FDe1OUG
         /w9LOP3r2Sq2ceMdh1h91dHaFE673FqiyaCnJ4PPGtQLOxouFu2q7AwQNc/weFewY5bB
         qh4sgo7Q1WtMyua0ogO6/FSpYisy0yMZw+pUhuCPsqX1iycRam/4cEFKCzbVgSfpFl4g
         EJN4CTjeIl4h7gF5A0TVA7AmFFlu/lGomQc/gCb2eYCUPm6jcPaUZZbqTLV6Rte/cN4n
         saSw==
X-Gm-Message-State: APuU4Z9lCXMybvix+esANimNns3oukNJMZs8MiOgNfja48iqVbaqjW7+
	7cWpOFoNCRQlyZOKjeczwXeZ7A3TvaxqWMt9vveytiqCgl19Oz484X6fg1cRZLlzoJYmEvzC2NH
	Nw6e9GEJ+CjyTsyvqJEYgSX5NHDsnkjwGQ2ZJ
X-Gm-Gg: AZFdTZd1+sfIzIM9ybj3PNCMYe1aqJUEru9+uhyX6XNwxIjroEnfi95DpdZzS/JAlOF
	MvDeTD9oxOw/AkYQ8rl2eFpBfE7gMd2j16nOEcojFtL3xhbfLb0UQDIYlcrvfzEJC4pz+twQ812
	br3kSk8ElSb56F/Ebe3PCYeKl110t3hE5QOEUtlKilHBsrGdvSzFGu8xc61v3vQ8y6p9lqRGmj3
	ND9L40W3JQtDE+4VqKs6tH7bfNY8REe22uFJiQO/fNd1IkSnsjpF0ghTAv+HRZAZ6WFIKCKvX7Q
	If9N4xxzjf2//NsnXGCTw3ZUjg5wJTUnka+PFdkY3kM4t2tBh5Lq8Iz2HbsElA/ce290y1BcFo+
	iJ8/VzkcerZUyVJy0MJx0QImzWtmdqTIztY3Y83houx/Go13K7MsaunXME/nwO3uQqrpXc2CpfC
	KHmbakFhqc4MPjTsVV
X-Received: by 2002:aa7:c710:0:b0:6b8:ff75:9b45 with SMTP id
 4fb4d7f45d1cf-6ba37e8dbcbmr5160510a12.24.1795428259412; Mon, 23 Nov 2026
 02:04:19 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Mon, 23 Nov 2026 11:03:41 +0100
X-Gm-Features: Aa3M54rnIlDV7QhtVK6PZh4U1yTLmzaKYGpYpGEv7jTZXGQs179TTyEennBhuF8
Message-ID: <CA+1jF5pNXvipBz8Hh3LWn=H07JJGEJPVH_hWZYCE8GhB96kvgg@mail.gmail.com>
Subject: Which Debian version has working krb5p support in NFS server?
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Which Debian version has working krb5p support in NFS server? We tried
to start a test campaign with krb5p, but that project stalled in
September because neither Debian 12 or Debian 13 seem to have working
krb5p support.

Aur=C3=A9lien
--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast

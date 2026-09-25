Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D37C3AB28D;
	Fri, 25 Sep 2026 22:26:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790375179; cv=none; b=W/kK0sqneOxmKThpPQbg6jr94Rp9MSQWYOTaw9eCvT6arXDWSt1kkAKNWhz3LJNLiEgjI+Nujt+7JneWFIyG5lIB9eW8FwM2rURLOBt7JsvaIV/8pnM4YFd2T7tVcJtV/xww1l4tRGUeogw6t0ReH6WHt2VBCj1cLL8FjFk7hbg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790375179; c=relaxed/simple;
	bh=2cdAkbkwmOinY5NHFaOYNXn5OvvOfJ5dGhMI6s3ApCQ=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=gneXuAwF44ayyifLgPeF/oz0z1eYF9Jp9ROIaPWTqLtF4Q4E+UfctWywv47FwJvmGGCxPMKmj2apM9hQmVANzGiVGaeTujzOYv11i8Akl6f6/vSXcODxNHhnmRgAzl7cIsu4dI0DPpX82KjlPJyGrsgv0+YKSJZWWO7jissgcdk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=YEbasg4x; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=XDsA851z; arc=none smtp.client-ip=202.12.124.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="YEbasg4x";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="XDsA851z"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 7BF8A7A009B;
	Fri, 25 Sep 2026 18:26:16 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Fri, 25 Sep 2026 18:26:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790375176; x=1790461576; bh=eM+BMt2FSiybCKLmii7ljgTLaR2tPm+0hmI
	MyV08ssk=; b=YEbasg4x3i5tYzUUL25xQJlZ4Rvj9Kzy49C8cz6HG8BRNf7Cgiy
	jsJQSiOHbtm/JzNjDhJAeS3fh29TR5MHCUEzwpU2z91tXVOgcsRj/khXhYImi0ec
	JZF+rPo4C+dS/AGSd0Fy8Bz6AAHL/8MsMi0KyEsPQXm/fKsKwjmUZt+gwWEgM0do
	JCg9cfb05/9XJDpidsvdnPOZKMxf9my0ymXZDY/2l1N/XGrBkqX4aLTT66dG3fAm
	3NrgvTYb/tjaWjtmR0Ard+SJfVk3BSI4oOPIe0JOy9sOmfyAr6SQrSjqnJLrWOQe
	9QWl/zJb1yLRfRlrjCPzLG9Lrppnl62CdaA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790375176; x=
	1790461576; bh=eM+BMt2FSiybCKLmii7ljgTLaR2tPm+0hmIMyV08ssk=; b=X
	DsA851zkDNw6tLTzSD3ezMvCGpTLyRwhCn3jvjaCO8fIXkLyQkNUK1xPguG+hv6X
	HyCiQp7R3LtJMEJx+nhqR3YUOvVqbH666krHL/A8pptyFRN4gQL1qiJtvWd/hGq2
	nWDWk2eA+4quXEKiTQPCxdAoBZnmdzRh2Oqh6vAqbM2qWPd94ywFbx3bnbOk2ysn
	gbG8pnGSUg6pQeCWXV//uBGtOb/88OexZAlUHiZPSeKfZnjD/XSe+Oav7DjKq1T8
	WapwqJ3HW7lgsv8CHdGeSNNpf+jlSfPoACEZZ8ibidgKkU/FxOvOl+R7qfRRJ9FU
	slFe8EHG5t7+ZIiGszmoQ==
X-ME-Sender: <xms:B_W2ah1bEZkZZOb0ONT7_GzrbKAvlBOmEydSF15Yh0tYrGh2SUASzg>
    <xme:B_W2aoeNCrNRZf3D48zrQz4l4Ccwd8MePm0yW0p5cuw8EjTvJOZFfnVLQXeEOZ1X9
    0prH8aaQ4CHmSb1aJPZ-6dncjgH83Q0epwGcuoAu_8RsCAVfXA>
X-ME-Received: <xmr:B_W2ajCa078R1AG7c_m8A49TfpzXauiM037w9_edLMy1_22J-rTO4OXLKJv7fNhYIHzgNPzhuZmj7goTKaZ86HiRPt4UBTw>
X-ME-Proxy-Cause: dmFkZTFRG3Zzuqyr3DS9SmBRBTiYvMUd3n7IiZBb4NdxlVwYwfZdVolvoF8455wbkw4bh5
    lWkUSUthmRF2ukf7uISr3eVPiyp6XahgIXDmt8dvmZ/mLnILkjrLTI1lv6ep/yzfqktjVG
    aiUi2Wp3LQEDTVOvN9MKBOIwnVKJAio/0FFITxiCNQHm4v3YgJfyG9yluXTlzQowFwURkh
    +ET1QamP1kNig2cc/uFYZTWm3h06DVBc2xfsTsi/Kq7rzwyb6LAfrpc8DrHXJ65Pyg4oEx
    dYo2AuITpeAU9ouwcno7UUGdMv+zTReYAN2PKihRBnotSPkYWynvdKNY4BcEEP9HXHplia
    zy3MsnFbQRVt//U9w7/Oul2OnX5WrUJ0fuGSIcnzIAA9d4Lw+BkdnFQQ1bg41/38vibdrO
    LeD6zaulKKsgCW5Fc217mwzp0Ws18KVPo1KRU3WoyV7JDCM8+qxRI+h8BsibBs0NVZicXN
    wdmMRI4Q6FchKSpETI8uSG0p5pJcH/WqJrquhrTe3d47QbBoiDWbaC4ktfycK99ss8+JK0
    QwpJVDy2QPKEI9+VZ//Dj8SyzXNubS8IfCWQ4h19k2ormWCXQuvaQXi8dhJ25ZlQBnOFOv
    cEo7nafXJ///UqAVpXaXnXnogpAFPM5maeCsSx9cF04klXS93k4NrWrS2MSA
X-ME-Proxy: <xmx:CPW2aq13sStOEVTQghca0BDyqO0aFhesd8wysv6epuwLkqrO_71l3g>
    <xmx:CPW2ajNnwAAiTWiSqq1gPVsYXH3oVISkkQvvpP8DXzTHjpIg7GSAcw>
    <xmx:CPW2aodqYzY3qYF3VQNHa8VG2pHzeDI2r8E7T-lNcFWl40e_BnAmUQ>
    <xmx:CPW2avNCowaHngrKehf1ivUmTrmCLs30YcJhtc-vKixouD0YeOheeg>
    <xmx:CPW2agphkksALRaWgfrM-uIoR56cGMeh887Hn_Mp7JL9dQw36OZvyHWi>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 18:26:10 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Jori Koolstra" <jkoolstra@xs4all.nl>, "Mateusz Guzik" <mjguzik@gmail.com>,
 "Dorjoy Chowdhury" <dorjoychy111@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 "Paulo Alcantara" <pc@manguebit.org>, "Namjae Jeon" <linkinjeon@kernel.org>,
 linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 14/14] nfsd: use vfs_lookup_open() for non-creating
 open requests too.
In-reply-to: <29ccafd9-22ee-46c9-9049-e188734bc5b3@slotpi15m67>
References: <20260919022441.3305170-1-neilb@ownmail.net>
  <20260919022441.3305170-15-neilb@ownmail.net>
  <29ccafd9-22ee-46c9-9049-e188734bc5b3@slotpi15m67>
Date: Sat, 26 Sep 2026 08:26:08 +1000
Message-id: <179037516804.37859.5531331690585475529@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 21 Sep 2026, Chuck Lever wrote:
> 
> > +	/* FIXME: check session persistence and pnfs flags.
> > +	 * The nfsv4.1 spec requires the following semantics:
> > +	 *
> > +	 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
> > +	 * Reply Cache  | server |                 |
> 
> This table is only about create modes. Out of the op_create block it
> now reads as though it applies to every OPEN. Could it say "for
> creating OPENs", or move into the op_create arm of nfsd4_open_file()?

I've added that - but I wonder if this table serves any purpose.
We don't support session persistence at all, and we endeavour to support
all the create modes, so what is there to "FIX" ??

The comment was added in 2009 by 
Commit: 79fb54abd285 ("nfsd41: CREATE_EXCLUSIVE4_1")

Any objecting to me removing it as uninteresting?

Thanks,
NeilBrown

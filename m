Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63F8E3E274C
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 23:32:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788219132; cv=none; b=sZYcn4gBbVE5Id1FejYJ7Mwxm2Xy97E0gBzAHpSx7QOiOUpEyosmFUbuzgzLgu3udkU6zSr2iLKsFffj1mcin9fN7U9X1XpzjEohPVRDWEx950eW7OPq//sEkj9GuayDwbLblG4rskCOW2Qp20cXdJMrgxO/J2/DkNRr4LeSSkg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788219132; c=relaxed/simple;
	bh=O3dUzn3dGkaVAPpDFFLsE7z9koWPVrcO2nnd3UtUTRA=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=Q0joYCqN4RFGCuAR7De2HDsZivoRuMNBiIYN1T+iQrVdipK74NnA8XT71VnJ8JKIMMEpi14+75CzyrLB3t1VPKSgAj4R8mV0c7zZQy52DZs5Ryu0qrj0KpM6u6hbZoTCgz9PHXokY8pHRaWV96XP9FI7IQzQUiTwqxbTgAZf07s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hM9ggej7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hM9ggej7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0A4101F00A3D
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 23:32:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788219131;
	bh=HqSnM2Sf1MnAraFVDX5f+6TBqIzKd36nKm4xtyvhybM=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc;
	b=hM9ggej7PlPuTMCDzgOh3zYet3jaCTTtvglzC/zYWOZL6KGj0BcKod4DB2KHZmpuk
	 9Xr8E5fI7omKEWAg8npO64Q4oxaIsgjG+ROJho52pGDM0t6/3xak1DlwmCvfeLGEq2
	 QgA1Yt5/MRFPTMRaDIUjwW5YGSiC2DurJZI45p7kp3NGtY4Qjnfuwky7WXn7o9f4Z8
	 wC4Ds6R9vHRh9IGZpDif5s6pgETlC/Wre846fOo21aTGBy8Pvwtz0uK2tMm6Oadwv/
	 53QRlUMvhrjqA91WlLKbIal6dENP3blXPeG/7/rBm3eOLTTcQXLTrHKYGeIJ/eD/kO
	 gZhLRtPK2lJyg==
Received: by mail-ed1-f41.google.com with SMTP id 4fb4d7f45d1cf-6a6108734d5so6035332a12.3
        for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 16:32:10 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AKwUvBw4fePG2GCDpLMgQPyqXGMWZs7DuYPK1PjtTx+r+W2EOydP4c4b8PO8qa33INO0AAgF0R+siZvzxdM=@vger.kernel.org
X-Gm-Message-State: AFuF++kCsaI0l8mMDQJ8cIukKvRf3kNdiYDN8ShdMqMwbl6oXAzfyhNi
	8Eb1hMCsVScVT9ACRTPyKhhzGQ2vQl0yi7v3UrZ9hmUdLFRTephX61WFG3dvO6Fyf7blV75mlJ/
	JDL8Xpq5/izHD2SJfOf24mhsUfDN7WdQ=
X-Received: by 2002:a05:6402:1e90:b0:6a6:32f5:90b3 with SMTP id
 4fb4d7f45d1cf-6a663b24942mr2593080a12.21.1788219129658; Mon, 31 Aug 2026
 16:32:09 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260830041901.2668-1-willy@infradead.org> <20260830041901.2668-7-willy@infradead.org>
In-Reply-To: <20260830041901.2668-7-willy@infradead.org>
From: Namjae Jeon <linkinjeon@kernel.org>
Date: Tue, 1 Sep 2026 08:31:57 +0900
X-Gmail-Original-Message-ID: <CAKYAXd_zarKuogwNS=ZNDuyR4w_iB7yui+h+CqGvjZvzxPFpzw@mail.gmail.com>
X-Gm-Features: AcwNN1UvF-7AQZoHjsPGrrmMkPeyVFXaEcU2n-gcV41YpQO_AYBnZepzQZ06-b8
Message-ID: <CAKYAXd_zarKuogwNS=ZNDuyR4w_iB7yui+h+CqGvjZvzxPFpzw@mail.gmail.com>
Subject: Re: [PATCH 6/9] ntfs: Remove redundant FGP_NOFS from ntfs_wof_collect_dest()
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <christian@brauner.io>, Jan Kara <jack@suse.cz>, Gao Xiang <xiang@kernel.org>, 
	Chao Yu <chao@kernel.org>, Theodore Tso <tytso@mit.edu>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Phillip Lougher <phillip@squashfs.org.uk>, linux-erofs@lists.ozlabs.org, 
	linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org, 
	linux-nfs@vger.kernel.org, ntfs@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 30, 2026 at 1:19=E2=80=AFPM Matthew Wilcox (Oracle)
<willy@infradead.org> wrote:
>
> The flags already include FGP_NOWAIT which prohibits all reclaim, not
> just reclaiming from the filesystem.  Use mapping_gfp_mask() instead of
> GFP_NOFS as this will preserve flags like GFP_MOVABLE.
>
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
Reviewed-by: Namjae Jeon <linkinjeon@kernel.org>
Thanks!

Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5780440DB5B
	for <linux-nfs@vger.kernel.org>; Mon,  3 Aug 2026 15:17:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785770231; cv=none; b=DH9QDetbqt1HEtJRQ+IY/smscruIIzvIchClDbNvyTZYmXTTy85MNj42g/KY1ZF3T6bwRfOUMVtR3K927jtsZC7KaZTyrFa7vssfnDyooA827hGWnVdn+ypaPXxUGT7GwKVOWxEC+RI6S3q8Ucu2H0dkNEbno5JwGxo5Z+LiHDY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785770231; c=relaxed/simple;
	bh=Bel9577sAnhWGVrKBWQppNzhHdQY05XskAD7CAYfS34=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=C8hW6T0P+UeaYu4YWaOppuchEOvs4un3DQQ1+Gf0PJ+pOnv77vtdM+GH7wG+eWSP4dfvkhKFRZTvwYWG+DTVsSu7Wvm7LQniOzs3FWX4oGhrBVhX9jLTNY2x7icDbuTrAv3++MOjWoIGuwTt7S26pQZgLg1oHXIwOp+T7/tudZA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=g7KGCUN2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="g7KGCUN2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7DD141F000E9;
	Mon,  3 Aug 2026 15:17:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785770229;
	bh=c6ROo8KdXg0U9TwoyShFmyoYT2N77tEC1oFXTx8vBDE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=g7KGCUN2pKxWLc8xBmm1Fu/fhipcLcnT1GamAlKwMunyLtB0hFsR3dZpUCvW4ftYu
	 8aqjMy5FdYoIwmawSBVqIWBhr4Y3aOX+nJItZe7g2cSnvI1dssk+uwuUHz2GOiad2b
	 LdF9gm/w5KuxZDj1g5r0Ew4LK8qaujVnB5wET6wixINdMdA0g4E8TITuZ1ITnQOq4h
	 7kMVP1C/wiKiUhiumaSCkea4G75GwCchG2cZz9eAs4d+wuk6XU1GpuYHBeZvNFo664
	 kH6ZbTA9IvjOwVWqoN3hSFQq+nkZEPrjIW7y22xZOJOQh3gC574N2yrW7TC12XluFb
	 E/sHvSiFH2XrQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 9858DF40066;
	Mon,  3 Aug 2026 11:17:08 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 03 Aug 2026 11:17:08 -0400
X-ME-Sender: <xms:9LBwamYN-4W7Dz05CbF4P5vAkHZigAx2jntLbntNvhcttJbHMATwlQ>
    <xme:9LBwakMshUONxjTuB_oqeElYP6NztSMN4NCYIgHvkDkHtE1X5MOFoIRCCr3tmjB67
    j9m2pcOwu4vjkIfpsC0HgGwovW3iJ_I_b3drjqWXNOvgKvZ4ju7XOOW>
X-ME-Proxy-Cause: dmFkZTGNcsW4qKhZ1a+JG+SkIKn7SbZPbTFMG7jw9vd8XwSb6/BweZIhHxPVU/FVI4MGEE
    QzWcEvc6fp1cIWo/C3fwx5Z0cCvWae+0Tt9SOniTkGBJwGPpDP14ohLDdHi0YqmETNwnE5
    cLnVyRKM3UIq1mOHMPujA3a66SqW1vHGL9TX1GI0y/o16qRiY6ZOoh/bNrMc7cYAmy5jDS
    i9BkWRFs2ZzF1kxdXooMRAm4xJgzvjefIGAXh1lpVWVChw6SEK42Oj8u7vrOu9KbTLOwKz
    6exhzC09JLSrehsFLLBAALSzlckoVeCZ4MCOm4bMhlyM5gX4RvrviREFIjumJAwaW5oOhq
    Ae+hZSpkTBmd/jYuiSkGHE3QSmyQTUMRpRmbdFY1cuNO1z1clOwy1JJxguKDj8ICndfJfe
    Wb2dkxVs7fOpnO57LsclBTn9QLcMcRXqXVG8FCia9tZdsxxK8gp/6CnosnVqV4LyKhNtHw
    okKR54BsJGZ5YoRynfrvnZZ5b93Xec1hpEiIMQYJLqQJpw/koOO/CoqrnACcN0Cd6Hgu/s
    raiZcvRWdC8IO9nR6Kc8WI6gfmtGpyYZTv7CzHTyRfxhKR2ydvyE7zokt5gz8wv0g73gLi
    uxMtQzFlj5R1XnoHT0zYUT1Wyr3Di80414HZQbb2Ln9HWg3QxUdt3Fsdxvdw
X-ME-Proxy: <xmx:9LBwagnbTe_HE1klDn33MdZx0xdJbm-XR2vX-_9Z7v3q--eBAzuFyQ>
    <xmx:9LBwane0FgX5EyBrKvVtUNCNwJL0hUyT5FjsdrWJgftbx-3nP0Tcxg>
    <xmx:9LBwasS76q5tWHFw0QZa2-azt9eYnIElCAYCtWmxdzb92xPOZpM04Q>
    <xmx:9LBwamvI4AKW2tb2SJHh2yynv4UIRSnRgNLbAMlpiC0nke34o8La9w>
    <xmx:9LBwaleVUi9UTWpzp39egl3yf931scqgJ4oiEG1tT1Tg8yyfaQJ9Sfel>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 77B6F780070; Mon,  3 Aug 2026 11:17:08 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A5jYTd2TqER-
Date: Mon, 03 Aug 2026 11:16:48 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <a728649f-0503-48de-be6c-0947e70137f9@app.fastmail.com>
In-Reply-To: <20260803-dir-deleg-v1-2-51be76861821@kernel.org>
References: <20260803-dir-deleg-v1-0-51be76861821@kernel.org>
 <20260803-dir-deleg-v1-2-51be76861821@kernel.org>
Subject: Re: [PATCH 2/2] nfsd: fix nfserr type in nfsd_lookup_dentry()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Aug 3, 2026, at 10:49 AM, Jeff Layton wrote:
> Both nfsd_lookup_dentry() and nfsd_cross_mnt() return __be32.
>
> Fixes: cf78c5a7d742 ("nfsd: move check_nfsd_access() call into 
> nfsd_cross_mnt()")
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/vfs.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index edb08c006a23..807e09521e0c 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -287,7 +287,7 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct 
> svc_fh *fhp,
>  		if (IS_ERR(dentry))
>  			goto out_nfserr;
>  		if (nfsd_mountpoint(dentry, exp)) {
> -			int nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp);
> +			__be32 nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp);
> 
>  			if (nfserr) {
>  				dput(dentry);
>
> -- 
> 2.55.0

Folded into "nfsd: move check_nfsd_access() call into nfsd_cross_mnt()".

-- 
Chuck Lever

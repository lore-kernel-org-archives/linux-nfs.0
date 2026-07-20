Received: from mail-qt1-f172.google.com (mail-qt1-f172.google.com [209.85.160.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B2053BE155
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 13:52:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784555552; cv=none; b=Vq8BkCV9Kr0OoLqeakYfvxSyZ+kFuOL/DoEEkRtDWG+bvJRzfPjH4QV9x4gs2zcfmjLEvFMGieLYVKoCAs94Y/fIseimRXZXlEXDNbpeEA4WAiPDpBeNMUR+CUNJYg8wDP6W32oyo3A8L0asxrMjbm1866BKByAsQ6Zc00at12s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784555552; c=relaxed/simple;
	bh=8NPcPX4VGMeFf788LoU11J1w5DXTi+oJnAW8j3ghSEk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Vmm1gaQH7QC7dYpRd62iuc3L1dWj+myIAmZiaim5IyCFManWWJT2h980Bav1yXJC8ywmX606Y9ArGw+XEU0jHF2nGKTwyJcMuug/GgkyDC1W4kD0PKi/9FfPcs31w0r0IsnZ++i1p+9DrA2TIa2SqrzHFfyozi2exYyk5IfDyHU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=YcLOK6ed; arc=none smtp.client-ip=209.85.160.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YcLOK6ed"
Received: by mail-qt1-f172.google.com with SMTP id d75a77b69052e-51c10ed63c0so861311cf.1
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 06:52:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784555550; x=1785160350; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=UgD9bXXwSeM0164tZRI/2maKOOM1j5/MTHlzcI24yvE=;
        b=YcLOK6edcDgDMraLEk2hRLTiWx9CcMO5wHhz4ltS/LgHi41Xr/q+dlsdVzLZ7hGTiA
         Z5HrIwzXykoqMd/33zoKExEE6EFzC4Jpo/nww/MGH+Juv1ivE0CviYLbFV64jNLAFIhA
         +dv7Ww57RGCrhVd8iB7eJAWOeygd+alTWVMdOnaQaILl7IXfwYLlNQOnZOWFpe2v3i4r
         Yqd0BvzS4gLhaEc35XNnTnerjAwyW9hPJKm/lpelRa6ppJWohSwVpYHA8PEX8IERwz0a
         qAB5eQsY8faGzZXJCh+EkmUHx0b6iEVvRDVv7+DIVpA8Eg4GzuSoy0ln8/HtSQF0kjp2
         tpDw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784555550; x=1785160350;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=UgD9bXXwSeM0164tZRI/2maKOOM1j5/MTHlzcI24yvE=;
        b=tP7XWpnsx+sMGBOXCZyTS0D4qE5zWFT2cGIMKLldOY0O2DtXeApyqYMdnh/SmANVWD
         ZhHY5niGqC8oTKRNImnZof/hQtrVBMiPDdE/IXqVOrg8BObFrfdZLHSYavEGok5/lmb0
         7VLB2ls6TGW1pNhY3UG+4c+2K8aAQP+8EMFiVDYUBJ6Qqj3sKn0Xv4j0qJW4ylpJpYJC
         LYD3Gy6opsqHIaLfU9ro37pOgXCs2Tj42fcwNiK/6zqkgXuENGh5vaBw/Jx86jW+4e2k
         2XszQk3BGsUnoga6NX/6uJFCe2RQyMbDxjcnrsldFaFce66YUOnMtRrH3LumWi4oqgG2
         QxBg==
X-Forwarded-Encrypted: i=1; AHgh+RrsQTThlHCHZ8lUicfS/Xgw8JhbznH8iakz511r67lRZ/Fzbxy5+U5+tvUPZ++QtigZkV9qPUwMkFI=@vger.kernel.org
X-Gm-Message-State: AOJu0YynmKIpVf87DwwUeOHuGtP3A2NR49w/EQ6h5QkBcfvV4DqBEgGt
	pilHxspEH11b13H7gblvDN1dwwfXiDqlTrATWJa/pGx3FYfmur7yOddxbgTFuWsoFw==
X-Gm-Gg: AfdE7clWJrRoOHUDLPQn3s2xkvhfxMHJsvLV2zJTw25Qbz+rN6ssYFvS5vMqJjIANlp
	lUXwdAWzqk5yZqd4C6QTHJ4CWqgdBG/9KWG4GMJISuQ6c4FqPQNU6KfNURs0abRUQyWkzFTM0JW
	sT1SW3R+ofBITDBmGlt1J9zkUY6PNDzrUIV4bneIJxugk0PWfpHbyLCKt3Tlo+PfyIXr2xjSdIb
	EU21Ft1kcrnMsS5I7chBF4DrsGr11PuK1Oa4+PPq2tc4BUodq2qFE4tPgAq7zPKcLBv9UE4JQZ0
	lb52bbyNITx4R6FqhORjhY4i7lCcaHZAsjQ6H1D8Qs8gnewTWc09xfay6vUA2GIMQA744MP5Nvo
	Dfbd9NaxgItpaaiGumvyyx8CsZ8NN6DfSBSvfFvulYP8SejpRhDRJcNSQkuzHsRiv1vodLR58TM
	RS4SQY29S/gXmZKB2Sl5fZTg5wcXq07RPi+MMn
X-Received: by 2002:a05:622a:5e88:b0:517:5e32:2d14 with SMTP id d75a77b69052e-52600a85199mr1590141cf.10.1784555549780;
        Mon, 20 Jul 2026 06:52:29 -0700 (PDT)
Received: from google.com (10.129.124.34.bc.googleusercontent.com. [34.124.129.10])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-81ef42acf2esm50683247b3.33.2026.07.20.06.52.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 20 Jul 2026 06:52:29 -0700 (PDT)
Date: Mon, 20 Jul 2026 13:52:22 +0000
From: Pranjal Shrivastava <praan@google.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>
Subject: Re: [PATCH v3 1/5] nfs: make nfs_page pin-aware
Message-ID: <al4oFjOLaF3LDeyB@google.com>
References: <20260715143540.3597616-1-praan@google.com>
 <20260715143540.3597616-2-praan@google.com>
 <20260720091322.GA24298@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260720091322.GA24298@lst.de>

On Mon, Jul 20, 2026 at 11:13:22AM +0200, Christoph Hellwig wrote:
> It would be nice to avoid the overly long lines, but otherwise this
> looks good.
> 

Ack, I'll trim the long lines and post a v4 quickly.

Thanks!
Praan

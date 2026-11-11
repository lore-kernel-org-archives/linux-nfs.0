Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=82.195.75.108
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794390418;
	b=Nhg17AHd9HIsgif4fVjmYtD/xKXR+uvPcs3IYUG3gJChisY2yxpIKMyBa6l0T1/NbsSq
	 EYYJGywpl7EdxgBl8jYPljIws1lM368Pqk9GPcDVGGI67G44dCXiSZFGmgdVgWoShTCRP
	 wIrtM6S0f/VLX+QQSIXgFVzoyeoglxgdJRyjtGFjGoZ1SG+Hrr9gjHPlRDNzktmrCt95J
	 8bBRmZYy2HeXjR+QxNau+0VzK9STPFreHMv90uwyI7klW1CopIxlfUPgEViqIxj1EhRnH
	 U94oxaU/dZIdfz4QWzSSg1O69Wt6cexCjRZFKveTyhZKPD+rxl+g/HPH8za6UmRWJqw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794390418;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Debian-User;
	bh=g4FJ8o8UQUtyD0eGI0sUCpicqPvdI4Vdc4LMM0bmn0w=;
	b=Hswx4nOcAxEn2mYXM+ZJr7H/uWd6tZV0QzCT4hYr1fl+14rNU9s+/ViqQ9z1Ugna1oRS
	 BFkTk1j+MqQiagMQvynOawuKEKyONjBiV18uaMTwiPLVAq7qzB8keqRfSSA42kc6ODfXz
	 i1+GfJfXQwnp8403YtvM1/TYnjXvY21mSx2W/lDKVBjpVKjMcIfgQdOpTRQe1RmRd7ZaQ
	 bXcnFeiSpsBlotq3RK0uh3T+hRiWbt4uovHA8I7iYaz1An7qvtsK2GXwM4oWNwVjWkjHF
	 06u2vbn8KvnfDrbtUbRfIimbv4xggVXvUlwGDZG1XSbiMUrd1DLUsP0sDl3FiaimEdg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=debian.org;
	spf=pass smtp.mailfrom=debian.org;
	dkim=pass header.d=debian.org header.i=@debian.org header.a=rsa-sha256 header.s=smtpauto.stravinsky header.b=cmZW0raJ;
	arc=none smtp.remote-ip=82.195.75.108
Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (prime256v1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A60BA606A332;
	Wed, 11 Nov 2026 09:46:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A60BA606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.a=rsa-sha256 header.s=smtpauto.stravinsky header.b=cmZW0raJ
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=g4FJ8o8UQUtyD0eGI0sUCpicqPvdI4Vdc4LMM0bmn0w=; b=cmZW0raJpZImC504fK0B0kMd2h
	XJQXfLj15TrbtRxuoXIll7+dYj88ZVAl2AayT9vhDBlAQ57+Eho/cFEk5It94wIbKS4EH4G+cdutI
	0K9jgabrgunrLX95HA3KOWeYRz+hLh5iGe5EyD3w5xx8w9MzCtlstOcNUcfrAtIPd3RxiWEjnELaD
	hbo41pU2e/eygmvhOngKp7971UVKKEY71/mIvuWf0WfaOur34IyUdpGFowB9/oVJFRm81ZxsZDxLw
	5M54Kif6OKPedXxyOCO9YpK4/4uqCIxZE2p81NHj3kV9mf9cnMGZSmbBCsLntHmPvgWT1OTOymjci
	CwvzesXA==;
Received: from authenticated-user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.96)
	(envelope-from <leitao@debian.org>)
	id 1xR4up-00D5nW-2D;
	Wed, 11 Nov 2026 09:46:51 +0000
Date: Wed, 11 Nov 2026 01:46:43 -0800
From: Breno Leitao <leitao@debian.org>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>, 
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, 
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
	driver-core@lists.linux.dev, linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, apparmor@lists.ubuntu.com, 
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
	linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev, 
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
	Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC 16/41] configfs: use fc_init_pseudo()
Message-ID: <avQ5dv0747H-XKmD@gmail.com>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-16-4c998976c6c7@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261110-work-loop-pseudo-v1-16-4c998976c6c7@kernel.org>
X-Debian-User: leitao

On Tue, Nov 10, 2026 at 10:14:32AM +0100, Christian Brauner wrote:
> Initialize configfs as a pseudo filesystem. This raises SB_I_PSEUDO and
> also SB_I_NOEXEC and SB_I_NODEV. configfs never holds executables or
> device nodes.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Acked-by: Breno Leitao <leitao@debian.org>

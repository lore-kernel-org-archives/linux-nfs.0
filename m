Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794409553;
	b=a98VbCSweoMuDzOilXcRP6H8B9Txe6lovHCuohkUYx2TJEEqYZn+tbisRwlVBOtLNAUT
	 a9WVxDMy5jbMLefeL/Ba4Rj+iWz2oKZ/qwxX1KD9s7PyE6xJuwQ3/4Ot+VKbLigfEmK37
	 VNW0Vrd+QEjMGYcw6DnuxVc3AK/cLkkIywk0hDWB+n5soVcjeHce8Bc5PjjRT+5FSJujQ
	 DenoFZb8+fOPI5jwbTGFiq0I3YF6F3clzoqjO8d410I0qV6xJ2ffcgETHe38NrXBAmoFx
	 tEzd0tntC2zMqBy4809l/BBQ+C8csXJQh2FLbyS0ufsBmmfQqjgzkNtDGytPao3Qzyg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794409553;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=eTh/pZjfcHNyaYvHc1i0brd4au2XXqBxglcFJNmjPBo=;
	b=wpqIzQVkIgmYE9aVDf3nfPyyGV4BKmoQkAGOj3yaB37Z3jIIzqiKZ3ir2OSO99h8IslJ
	 kXll9q+KTm/L6nPG3egLsGAHkj/WT+zTBb3Q8+pVjNs7n1k3Fmkq6mJ71Nv6KPkB6N1Z5
	 Y+slkMfsECZFQln40mhb8eAIJwGyVbXYypVY2EryehuAvpDvtoaP/diJsgDPbzF6B4FmT
	 FSnpbD7CCaWj/MjLiDEKBCnNCL2keXa0GpLvOXOSRPKt1+vLc9WQSKbdX39g/5Gymc/8v
	 tv9Gh4KFMIdFS/AfbS64D1eQpHkkLqQxwakW37lQS7zPauOV/AkwSn8uqYzsuMQE7OA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 877AC60A261B;
	Wed, 11 Nov 2026 15:05:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 877AC60A261B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 484DC68D15; Wed, 11 Nov 2026 16:05:49 +0100 (CET)
Date: Wed, 11 Nov 2026 16:05:48 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>,
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>,
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-mm@kvack.org,
	bpf@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@vger.kernel.org, apparmor@lists.ubuntu.com,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org,
	xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev,
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC 11/41] failfs: use fc_init_pseudo()
Message-ID: <20261111150548.GG10644@lst.de>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org> <20261110-work-loop-pseudo-v1-11-4c998976c6c7@kernel.org>
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
In-Reply-To: <20261110-work-loop-pseudo-v1-11-4c998976c6c7@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Nov 10, 2026 at 10:14:27AM +0100, Christian Brauner wrote:
> Initialize failfs as a pseudo filesystem instead of raising
> SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>


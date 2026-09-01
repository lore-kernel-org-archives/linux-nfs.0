Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 12C614CCDDA;
	Tue,  1 Sep 2026 05:56:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788242172; cv=none; b=T35RYxcdbItE1SgqAJzuFG9mde8FRRpgDrsr5QDhVwUjqpd8hUMCvPP/syGJNGwVlv7BBXMkSZJk6DtochVOs9gmVi+EbYkubLHOve8KFtfaKy0bHns1JCQFBVZL3+J/E8lv2LM9db7zJxFj2uLCB5dKctF0bVYbkSh/nNu/8L0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788242172; c=relaxed/simple;
	bh=LkbQnBSJdNkMGaC3eCjTS5kmvOrXhJ6A+gBOsGc98mk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=tKgNwpFSNpF2Ey6TLm9yQQjdwqqrYOLC16YzESheBmWScv2T2f4Q2EYP1I2b5+XfLrpF3Vn+Y9HL6GXSeChFxm4G6kujLHcUnzg10tf5QlxuDSqmNTp9eNeB+7xNtFn7u6pLGILmtpn/OkfKHH3hIXYBgGKvKyoi9azd7PqKZHY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ou7BODbI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ou7BODbI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 494581F000E9;
	Tue,  1 Sep 2026 05:56:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788242170;
	bh=3Mnj837MmtIz++Lx3CjViaHZJuFNdZX481goDRHR5Jo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Ou7BODbIZicrSpeSM00EfOJQrJABefs9Kuf2EhFYV6gK2dq64CXKdSuL3RyZbLucK
	 TPg17Tyz0+5ncdV6c1HL6WGWK3QRh4+wm6tY9EoV1ldMeb65SaokB3SYllaBh+BMU+
	 k3fxxYQqKpob1eGKNeK6NERFb4+ExYOKE40Jru2B8rYntpuKlNuC0j8YO4qOVeoRfS
	 0Gai2YDP4tJxaz3XlpWyH0B+gdt6KErKtSPMpBpFla9M4/VF7fFDFR9rb7sXCytJmv
	 hvNVEuFK2QwrR66uR+fQsxbPPuwkUO9XsB0pubH/TfXp4lry7WXlo5qdiAM9FijGEM
	 OmAyFu0d6q/4A==
Date: Tue, 1 Sep 2026 13:55:42 +0800
From: Gao Xiang <xiang@kernel.org>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <christian@brauner.io>, Jan Kara <jack@suse.cz>,
	Gao Xiang <xiang@kernel.org>, Chao Yu <chao@kernel.org>,
	Theodore Tso <tytso@mit.edu>, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Hyunchul Lee <hyc.lee@gmail.com>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	linux-erofs@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
	ntfs@lists.linux.dev, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 3/9] erofs: Remove redundant FGP_NOFS
Message-ID: <apZo3lDaDp3hQhRq@XiangdeMacBook-Pro.local>
Mail-Followup-To: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Christian Brauner <christian@brauner.io>, Jan Kara <jack@suse.cz>,
	Gao Xiang <xiang@kernel.org>, Chao Yu <chao@kernel.org>,
	Theodore Tso <tytso@mit.edu>, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Hyunchul Lee <hyc.lee@gmail.com>,
	Phillip Lougher <phillip@squashfs.org.uk>,
	linux-erofs@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
	ntfs@lists.linux.dev, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
References: <20260830041901.2668-1-willy@infradead.org>
 <20260830041901.2668-4-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20260830041901.2668-4-willy@infradead.org>

On Sun, Aug 30, 2026 at 05:18:50AM +0100, Matthew Wilcox (Oracle) wrote:
> The flags already include FGP_NOWAIT which prohibits all reclaim, not
> just reclaiming from the filesystem.
> 
> Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>

Reviewed-by: Gao Xiang <xiang@kernel.org>

Thanks,
Gao Xiang

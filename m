Received: from ewsoutbound.kpnmail.nl (ewsoutbound.kpnmail.nl [195.121.94.185])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F79D3B42D7
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 13:18:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.121.94.185
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789478318; cv=none; b=t24tps7hvN2QC8ur794FygGy4R25kwdecTcXWLCbGO58IFrevE2h3FKSyiYNHbwqpk5xYbPOQVQ/u3yc/uLsHinI9hqKTYusmYSQJUkgjN6QDLTNJzpqV7qZxZm5a/+RSRL8TrkvMf58Fs9u0NvXNn0kVghKOwrRAoFh9stMqTw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789478318; c=relaxed/simple;
	bh=C85AxaI2KKqPIO1eZUj7tU5xfApIIKnN+SlmpFxVzaM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lEHBDlsAxKLx2EmcMTem4P8BFVVvJef3DYlIbZ7IyXkfDoURwHysjDShwM71DA1945zmRjeKMo0VGj0KEEnb7BIVhhhhpE8ZSAy46QyyFGjsVEuCl39qOrrrSHwm47orkK94krf8+t+O4wBscdAn94H4eh/Gc746p6U/fo599c0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl; spf=pass smtp.mailfrom=xs4all.nl; dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b=ZCMfxcIE; arc=none smtp.client-ip=195.121.94.185
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b="ZCMfxcIE"
X-KPN-MessageId: c8f241b3-b107-11f1-9e92-005056999439
Received: from smtp.kpnmail.nl (unknown [10.31.155.5])
	by ewsoutbound.so.kpn.org (Halon) with ESMTPS
	id c8f241b3-b107-11f1-9e92-005056999439;
	Tue, 15 Sep 2026 15:17:21 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=xs4all.nl; s=xs4all01;
	h=content-type:mime-version:message-id:subject:to:from:date;
	bh=9Z03RuXEi8a/JpV6tVitUAYgKsoXy7L10aHolgRHyME=;
	b=ZCMfxcIELYP+YvN1usUIbp+DN6zQBo/eWw16xkx6wmmSL9OzhAZWeYse2QHqaNJ4mFAWLzZHWXPk0
	 cetEpqO0B2qxQo/Pmgwcdl5wP/1/apEMN+gzGm6XIl6jA7Nbc9jPe8qbjOj75NpASi66cCgSI5xOZZ
	 M6Dggpjc4QHJahmhFs/+N8jWbEkvEzKTSL/qSdv/bcAhFh7uSGFagEvoHGkCrg2IUn8vuuvaqtqQvc
	 mW1ioTZwiNGfmemQi+1Q7b2rKJmFq3fE54FFlPrwY63yaRVlP+BDRBbAuZQ1CZROYQFTvWd5POdnZi
	 6C3SPz80i4yfbgVSL5fCx5tdQCBF2lg==
X-KPN-MID: 33|pecNOwnZRGodLUIR7cgAA8b23tYG1k2YFG/98fWul3IU5PPH9e0T4KvRa3QcHu3
 Jv1SOT7PmptkozDQHaptOGevsAa5R+WUYC6iy5ZgnCm8=
X-KPN-VerifiedSender: Yes
X-CMASSUN: 33|hQ7tDhQuPKbSK3JQGVSeNwViOFm7SunQshzsLTl986HffIopVIo4AKrAz73gQLk
 qMUDtFl26svgZFMuUa8KgsQ==
Received: from localhost (unknown [178.226.150.234])
	by smtp.xs4all.nl (Halon) with ESMTPSA
	id c8d223e9-b107-11f1-8804-00505699b758;
	Tue, 15 Sep 2026 15:17:21 +0200 (CEST)
Date: Tue, 15 Sep 2026 15:17:15 +0200
From: Jori Koolstra <jkoolstra@xs4all.nl>
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] vfs: add some allowed open flags to vfs_lookup_open()
Message-ID: <aqlCL3yl5p9kTrjt@lt-jori.localdomain>
References: <20260910002934.192979-1-neilb@ownmail.net>
 <20260910002934.192979-2-neilb@ownmail.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260910002934.192979-2-neilb@ownmail.net>

On Thu, Sep 10, 2026 at 10:20:47AM +1000, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
> 
> vfs_lookup_open() must allow:
>   O_LARGEFILE so that large files can be opened.
>   O_NONBLOCK so that break_lease() can be asked to return -EWOULDBLOCK.
> 
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/namei.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index d95249dd527c..c9ac703110f8 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -4632,7 +4632,8 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
>  	int error = 0;
>  
>  	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
> -	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR),
> +	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|
> +				O_NONBLOCK|O_LARGEFILE),
>  		  "open_flag has unsupported flags");
>  
>  	mode |= S_IFREG;
> 
> base-commit: 9189e6a6f89e32d3a604b221ea64e67e1a35957c
> -- 
> 2.50.0.107.gf914562f5916.dirty
> 

Reviewed-by: Jori Koolstra <jkoolstra@xs4all.nl>

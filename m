Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8B1238D6B5
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 06:14:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788761701; cv=none; b=fA9X7As/5Q7t0FjQDljPCQdvZ6IvsP7pGEa2/cKPQsqxC8FlexEMd8flv3qr5kPaU3SLSgXTEIV7cfl9Wz5Nut51YvKppPshYyZ1vG+hOFkrcQMwW+MxaizmnX/RJr7QHMLNhUuQ90OhXY2lw6EyYEof6eFze83LDtLEwl6z5WQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788761701; c=relaxed/simple;
	bh=zAMM3vEbDBISwB6UydnFAceeVzKLfZHWlY9Pio8hbmo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=RDWFJcrSiBy5gKChZC1QWy5YUJDyPyLqg9mUC056+PvSLWaohQ+dyv1DxNnkeT3PO4OdTPKUIkE1qvSqNGg/kCEkaYlhHzKkF074+lYh4ZnUea+JJzkQBFg71fwW39YNs0lUWorCf7cCOCQeXdWZPl6+0FPNxInTsuGuCuMIrcU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=a4Hgz+ej; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="a4Hgz+ej"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=4fA10CrLCC+VWZwQM9C6adN24oc9Ojpf2WnVfEFKh8c=; b=a4Hgz+ejNHfLc7FJOgUU65pCI/
	CJIqHsAlLf4oLAdtnEq/UisHAqNzEglc6B7TwJUBROX6kwNZz4XIpOzMebHSS/Uqxns16uug8t7yk
	QBpEF6I9Xd/NUDf/EpSn4KICkclN2uBVmdxvHXL5LHEByjOkPySfK7Vgd4/KrKc/SfIw+UHFYzE1v
	8QD+E5JeFaALjnNHzUnKgUIiLfHMjVZXS46AeeAhPST49mDD2+pAL693IwP52WiToSynNCnnf0yKc
	EktflBH+bq3wkYIR+BB+Q0N4VWX6sM354bat8rDo5nkapsyxWMcJhQVyuQlD3BvUxOOr43/34QhNB
	w7f1h8qQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1x3Sd8-000000060En-1Fmf;
	Mon, 07 Sep 2026 06:14:58 +0000
Date: Sun, 6 Sep 2026 23:14:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: trondmy@kernel.org, anna@kernel.org, hch@infradead.org,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs: split up block layout and SCSI layout support
Message-ID: <ap5WYtPbQYD0oPvW@infradead.org>
References: <20260904172627.1347637-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260904172627.1347637-1-smayhew@redhat.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Fri, Sep 04, 2026 at 01:26:27PM -0400, Scott Mayhew wrote:
> Add two new config options PNFS_BLOCK_LAYOUT and PNFS_SCSI_LAYOUT so
> that SCSI layouts can be enabled without requiring block layouts.
> Since block layouts are considered deprecated, PNFS_BLOCK_LAYOUT
> defaults to n.
> 
> The original PNFS_BLOCK config is now invisible and gets set whenever
> either of PNFS_BLOCK_LAYOUT or PNFS_SCSI_LAYOUT are enabled.

Much better, thanks!

>  config PNFS_BLOCK
>  	tristate
> +	default NFS_V4 if PNFS_BLOCK_LAYOUT || PNFS_SCSI_LAYOUT

This is only used in the two Makefiles, where we could just build
the objects for both symbols.  But if you stick to the extra symbol,
I'd not use default but instead select it from the other two options.

> +config PNFS_BLOCK_LAYOUT
> +	bool "NFS client support for pNFS block layouts"
>  	depends on NFS_V4 && BLK_DEV_DM
> +	default n

n is the default default, so you can remove this line.

> @@ -470,17 +470,21 @@ static struct pnfs_layout_hdr *__bl_alloc_layout_hdr(struct inode *inode,
>  	return &bl->bl_layout;
>  }
>  
> +#ifdef CONFIG_PNFS_BLOCK_LAYOUT
>  static struct pnfs_layout_hdr *bl_alloc_layout_hdr(struct inode *inode,
>  						   gfp_t gfp_flags)
>  {
>  	return __bl_alloc_layout_hdr(inode, gfp_flags, false);
>  }
> +#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
>  
> +#ifdef CONFIG_PNFS_SCSI_LAYOUT
>  static struct pnfs_layout_hdr *sl_alloc_layout_hdr(struct inode *inode,
>  						   gfp_t gfp_flags)
>  {
>  	return __bl_alloc_layout_hdr(inode, gfp_flags, true);
>  }
> +#endif /* CONFIG_PNFS_SCSI_LAYOUT */

Let's move the alloc_layout_hdr helpers down next to the ops, to remove
the number of ifdef blocks.

> +#ifdef CONFIG_PNFS_BLOCK_LAYOUT
>  	ret = bl_init_pipefs();
>  	if (ret)
>  		goto out;
> @@ -1016,18 +1025,31 @@ static int __init nfs4blocklayout_init(void)
>  	ret = pnfs_register_layoutdriver(&blocklayout_type);
>  	if (ret)
>  		goto out_cleanup_pipe;
> +#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
>  
> +#ifdef CONFIG_PNFS_SCSI_LAYOUT
>  	ret = pnfs_register_layoutdriver(&scsilayout_type);
>  	if (ret)
> +#ifdef CONFIG_PNFS_BLOCK_LAYOUT
>  		goto out_unregister_block;
> +#else
> +		return ret;
> +#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
> +#endif /* CONFIG_PNFS_SCSI_LAYOUT */
>  	return 0;
>  
> +#ifdef CONFIG_PNFS_SCSI_LAYOUT
> +#ifdef CONFIG_PNFS_BLOCK_LAYOUT
>  out_unregister_block:
>  	pnfs_unregister_layoutdriver(&blocklayout_type);
> +#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
> +#endif /* CONFIG_PNFS_SCSI_LAYOUT */
> +#ifdef CONFIG_PNFS_BLOCK_LAYOUT
>  out_cleanup_pipe:
>  	bl_cleanup_pipefs();
>  out:
>  	return ret;
> +#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
>  }

This is a bit of a mess still.  I think the best is to have separate init
and exit helper for block vs scsi in the ifdef block above that have
stubs and then call them here and in the exit handler without all the
micro-ifdefs.

> +#ifdef CONFIG_PNFS_BLOCK_LAYOUT
>  MODULE_ALIAS("nfs-layouttype4-3");
> +#endif /* CONFIG_PNFS_BLOCK_LAYOUT */
> +#ifdef CONFIG_PNFS_SCSI_LAYOUT
>  MODULE_ALIAS("nfs-layouttype4-5");
> +#endif /* CONFIG_PNFS_SCSI_LAYOUT */

Please also move this into existing ifdef blocks.

> +#ifdef CONFIG_PNFS_BLOCK_LAYOUT
>  #include <linux/sunrpc/rpc_pipe_fs.h>
> +#endif /* CONFIG_PNFS_BLOCK_LAYOUT */

Extract unused includes are generall harmless and preferred over
conditional ones.

>  
>  #include "../nfs4_fs.h"
>  #include "../pnfs.h"
> @@ -46,7 +48,9 @@
>  
>  struct pnfs_block_dev;
>  
> +#ifdef CONFIG_PNFS_BLOCK_LAYOUT
>  #define PNFS_BLOCK_MAX_UUIDS	4
> +#endif /* CONFIG_PNFS_BLOCK_LAYOUT */

There is no point in hiding defines (or union arms below).

This still looks like overzealous agent work.  Please try to use your
own brain cells, the output tends to be much better than that from
stupud machines.


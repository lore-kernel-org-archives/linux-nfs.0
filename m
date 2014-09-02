Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44166 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbaIBP55 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 11:57:57 -0400
Date: Tue, 2 Sep 2014 08:57:55 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/6] NFSD: Put file after ima_file_check fail in
 nfsd_open()
Message-ID: <20140902155755.GA14472@infradead.org>
References: <5405CFE4.9060407@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5405CFE4.9060407@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	file = dentry_open(&path, flags, current_cred());
> +	if (IS_ERR(file)) {
> +		host_err = PTR_ERR(file);
>  	} else {

The is_err case should have a

	goto out_nfserr;

which would allow you to drop the following indentation if you
change the whole function anyway.

>  		if (may_flags & NFSD_MAY_64BIT_COOKIE)
> -			(*filp)->f_mode |= FMODE_64BITHASH;
> +			(file)->f_mode |= FMODE_64BITHASH;
>  		else
> -			(*filp)->f_mode |= FMODE_32BITHASH;
> +			(file)->f_mode |= FMODE_32BITHASH;

no need for the braces around file here.


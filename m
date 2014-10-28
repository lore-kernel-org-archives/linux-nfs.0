Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50576 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755768AbaJ1IlJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 04:41:09 -0400
Date: Tue, 28 Oct 2014 01:41:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna.Schumaker@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] nfsd: Add ALLOCATE support
Message-ID: <20141028084108.GC25532@infradead.org>
References: <1414161705-26617-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1414161705-26617-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414161705-26617-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	error = vfs_fallocate(file, flags, offset, len);
> +	if (error == -ENODEV)
> +		return nfserr_inval;
> +	else if (error < 0)
> +		return nfserrno(error);
> +	return nfserrno(commit_metadata(fhp));


Shouldn't this be something like:

	error = vfs_fallocate(file, flags, offset, len);
	if (!error)
		error = commit_metadata(fhp);

	if (error == -ENODEV)
		return nfserr_inval;
	return nfserrno(error);

I think we really should move the ENODEV mapping to nfserrno, but
this patch isn't the right place for that.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38436 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbbG3Pvh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 11:51:37 -0400
Date: Thu, 30 Jul 2015 08:51:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: do nfs4_check_fh in nfs4_check_file instead of
 nfs4_check_olstateid
Message-ID: <20150730155135.GB1073@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438264341-18048-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438264341-18048-2-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  		return status;
> @@ -4628,6 +4625,10 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
>  	struct file *file;
>  	__be32 status;
>  
> +	status = nfs4_check_fh(fhp, s);
> +	if (status)
> +		return status;
> +

This means we check the file handle for all stateids now, not just
open and lock stateids.  That seems reasonable to me but should be
mentioned in the changelog.

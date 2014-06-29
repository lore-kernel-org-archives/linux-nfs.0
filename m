Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33180 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbaF2MRf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jun 2014 08:17:35 -0400
Date: Sun, 29 Jun 2014 05:17:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 025/117] nfsd: Convert nfs4_check_open_reclaim() to
 work with lookup_clientid()
Message-ID: <20140629121734.GF16150@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-26-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403810017-16062-26-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -	return nfsd4_client_record_check(clp) ? nfserr_reclaim_bad : nfs_ok;
> +	return nfsd4_client_record_check(cstate->clp) ?
> +		nfserr_reclaim_bad : nfs_ok;

This would be more readanble with an good old if statement.

Otherwise looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

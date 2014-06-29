Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33135 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbaF2MQB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jun 2014 08:16:01 -0400
Date: Sun, 29 Jun 2014 05:16:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 023/117] nfsd: Convert nfsd4_process_open1() to work
 with lookup_clientid()
Message-ID: <20140629121600.GD16150@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-24-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403810017-16062-24-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +static __be32 lookup_clientid(clientid_t *clid,
> +		struct nfsd4_compound_state *cstate,
> +		struct nfsd_net *nn);

This hunk should have been in the previous patch.  Or given that
lookup_clientid was mostly rewritten it make sense to just move it to
avoid the forward declaration entirely.

Otherwise looks good to me,

Reviewed-by: Christoph Hellwig <hch@lst.de>

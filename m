Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47595 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174AbaF3SDq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 14:03:46 -0400
Date: Mon, 30 Jun 2014 11:03:45 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 015/114] nfsd: Allow struct nfsd4_compound_state to
 cache the nfs4_client
Message-ID: <20140630180345.GC20028@infradead.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-16-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404143423-24381-16-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2014 at 11:48:44AM -0400, Jeff Layton wrote:
> We want to use the nfsd4_compound_state to cache the nfs4_client in
> order to optimise away extra lookups of the clid.
> 
> In the v4.0 case, we use this to ensure that we only have to look up the
> client at most once per compound for each call into lookup_clientid. For
> v4.1+ we set the pointer in the cstate during SEQUENCE processing so we
> should never need to do a search for it.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

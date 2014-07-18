Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36752 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbaGRP5K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 11:57:10 -0400
Date: Fri, 18 Jul 2014 08:57:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 05/10] nfsd: ensure that clp->cl_revoked list is
 protected by clp->cl_lock
Message-ID: <20140718155708.GC23745@infradead.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
 <1405696416-32585-6-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405696416-32585-6-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  static void destroy_revoked_delegation(struct nfs4_delegation *dp)
>  {
> -	list_del_init(&dp->dl_recall_lru);
> +	WARN_ON(!list_empty(&dp->dl_recall_lru));
>  	nfs4_put_delegation(dp);
>  }

Is there any point in keeping destroy_revoked_delegation and not just
calling nfs4_put_delegation directly?

From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] NFS: Run COMMIT as an asynchronous RPC call when
	wbc->for_background is set
Date: Thu, 7 Jan 2010 10:32:10 +0800
Message-ID: <20100107023210.GE9475@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain> <20100106205110.22547.31434.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10227 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752251Ab0AGCcP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 21:32:15 -0500
In-Reply-To: <20100106205110.22547.31434.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 07, 2010 at 04:51:10AM +0800, Trond Myklebust wrote:
> @@ -1423,7 +1423,7 @@ int nfs_commit_unstable_pages(struct address_space *mapping,
>  		mark_inode_unstable_pages(inode);
>  		return 0;
>  	}
> -	if (wbc->nonblocking)
> +	if (wbc->nonblocking || wbc->for_background)
>  		flags = 0;
>  	ret = nfs_commit_inode(inode, flags);
>  	if (ret > 0)

Acked-by: Wu Fengguang <fengguang.wu@intel.com>


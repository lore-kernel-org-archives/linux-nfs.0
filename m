From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/6] Re: [PATCH] improve the performance of large
 sequential write NFS workloads
Date: Wed, 6 Jan 2010 22:44:56 +0100
Message-ID: <20100106214456.GE22781@quack.suse.cz>
References: <20100106200928.GB22781@quack.suse.cz>
 <20100106205110.22547.85345.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:51677 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932626Ab0AFVo7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 16:44:59 -0500
In-Reply-To: <20100106205110.22547.85345.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 06-01-10 15:51:10, Trond Myklebust wrote:
> Peter Zijlstra (1):
>       VM: Split out the accounting of unstable writes from BDI_RECLAIMABLE
> 
> Trond Myklebust (5):
>       NFS: Run COMMIT as an asynchronous RPC call when wbc->for_background is set
>       VM: Use per-bdi unstable accounting to improve use of wbc->force_commit
>       VM: Don't call bdi_stat(BDI_UNSTABLE) on non-nfs backing-devices
>       VM/NFS: The VM must tell the filesystem when to free reclaimable pages
>       VFS: Ensure that writeback_single_inode() commits unstable writes
  I think the series would be nicer if you made Peter's patch #2 and join
your patches
"VM/NFS: The VM must tell the filesystem when to free reclaimable pages"
and
"VM: Use per-bdi unstable accounting to improve use of wbc->force_commit"

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

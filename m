From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] VM: Split out the accounting of unstable writes
	from BDI_RECLAIMABLE
Date: Thu, 7 Jan 2010 09:48:15 +0800
Message-ID: <20100107014815.GA9475@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain> <20100106205110.22547.93554.stgit@localhost.localdomain>
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
Received: from mga01.intel.com ([192.55.52.88]:55396 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754699Ab0AGBsY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 20:48:24 -0500
In-Reply-To: <20100106205110.22547.93554.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  	seq_printf(m,
>  		   "BdiWriteback:     %8lu kB\n"
> -		   "BdiReclaimable:   %8lu kB\n"
> +		   "BdiDirty:         %8lu kB\n"
> +		   "BdiUnstable:      %8lu kB\n"
>  		   "BdiDirtyThresh:   %8lu kB\n"
>  		   "DirtyThresh:      %8lu kB\n"
>  		   "BackgroundThresh: %8lu kB\n"

This also reduces one synthetic concept ;) Thanks!

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

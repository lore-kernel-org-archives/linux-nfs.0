From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/6] VM: Don't call bdi_stat(BDI_UNSTABLE) on non-nfs
	backing-devices
Date: Thu, 7 Jan 2010 09:56:00 +0800
Message-ID: <20100107015600.GB9475@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain> <20100106205110.22547.88263.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar@nec-labs.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100106205110.22547.88263.stgit@localhost.localdomain>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 07, 2010 at 04:51:10AM +0800, Trond Myklebust wrote:
  
>  	avail_dirty += bdi_stat(bdi, BDI_DIRTY) +
> -		bdi_stat(bdi, BDI_UNSTABLE) +
>  		bdi_stat(bdi, BDI_WRITEBACK);
> +	if (bdi_cap_account_unstable(bdi))
> +		avail_dirty += bdi_stat(bdi, BDI_UNSTABLE);

It seems that not changing the bdi_stat()s makes more readable code,
otherwise looks OK to me.

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>


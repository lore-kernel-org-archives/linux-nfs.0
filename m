From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2] NFS: introduce writeback wait queue
Date: Mon, 5 Oct 2009 15:39:59 +0800
Message-ID: <20091005073959.GA23398@localhost>
References: <20091004030153.GA20327@localhost> <20091005071026.GA19262@localhost> <20091005073551.GA23102@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Mason <chris.mason@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: "jens.axboe@oracle.com" <jens.axboe@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:52483 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758331AbZJEHku (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Oct 2009 03:40:50 -0400
In-Reply-To: <20091005073551.GA23102@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 05, 2009 at 03:35:51PM +0800, Wu Fengguang wrote:
> Trond, I see this trace on linux-next. There are no more dirty pages
> when `cp' aborts after filling up the partition:
> 
>         cp: writing `/mnt/test/zero3': No space left on device
> 
> I noticed that since then nr_writeback is decreased very slowly
> (~100 pages per second). Looks like an interesting behavior.

In the mean time, there are constant 7-8MB/s writes in the NFS server.
The network flow is much smaller ~400K/s. How can I debug this issue?

Thanks,
Fengguang

>      nr_writeback         nr_dirty      nr_unstable
>             41230            36284             8764
>             41230            37307             7755
>             40009            42812             3818
>             32619            42812            11198
>             32314            42812            11503
>             31894            42812            11862
>             31832            42812            11871
>             31770            42812            11871
>             31721            42812            11871
>             31653            42812            11871
>             40789            33754            11871
>             40713            33754            11871
>             40638            33754            11871
>             40566            33754            11871
>             43901            30313            11871
>             74164                0            11871
>             74062                0            11871
>             73978                0            11871
>             73904                0            11871
>             73858                0            11871
>             73798                0            11871
>             73688                0            11871
>             73580                0            11871
>             73477                0            11871
> 
> Thanks,
> Fengguang

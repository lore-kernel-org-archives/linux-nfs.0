From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH v2] NFS: introduce writeback wait queue
Date: Mon, 5 Oct 2009 07:01:10 -0400
Message-ID: <86DD3A52-EE5C-4378-BEB6-6336E17CFCD5@netapp.com>
References: <20091004030153.GA20327@localhost> <20091005071026.GA19262@localhost>
Mime-Version: 1.0 (iPhone Mail 7C144)
Content-Type: text/plain;
	format=flowed;
	delsp=yes;
	charset="us-ascii"
Cc: <jens.axboe@oracle.com>, "Chris Mason" <chris.mason@oracle.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	<linux-fsdevel@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
To: "Wu Fengguang" <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2855 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932612AbZJELBx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Oct 2009 07:01:53 -0400
In-Reply-To: <20091005071026.GA19262@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 5, 2009, at 3:11, "Wu Fengguang" <fengguang.wu@intel.com> wrote:

> Hi all,
>
> This version makes two standalone functions for easier reuse.
>
> Before patch, nr_writeback is near 1G on my 2GB laptop:
>
>     nr_writeback         nr_dirty      nr_unstable
>           203994                2           154469
>           203994                2           154469
>
> After patch, nr_writeback is limited to nfs_congestion_kb=42MB.
>
>     nr_writeback         nr_dirty      nr_unstable
>            11180            34195            11754
>             9865            36821             8234
>            10137            36695             9338
>
> One minor problem I noticed is, NFS writeback is not very smooth.
> This per 0.1s sampled trace shows that it can sometimes stuck for
> up to 0.5s:
>
>     nr_writeback         nr_dirty      nr_unstable
>            11055            37408             9599
>            10311            37315            10529
>            10869            35920            11459
>            10869            35920            11459
>            10869            35920            11459
>            10869            35920            11459
>            10869            35920            11459
>            10838            35891            10042
>            10466            35891            10414
>            10900            34744            11437
>            10249            34744            12088
>            10249            34744            12088
>            10249            34744            12088
>            10249            34744            12088
>            10249            34744            12088
>            10249            34744            12088
>            10133            34743            10663
>            10505            34743            11035
>            10970            34991            11345
>            10691            34991            11593
>            10691            34991            11593
>            10691            34991            11593
>            10691            34991            11593
>            10691            34991            11593
>
> Trond, I guess nr_writeback/nr_unstable are decreased in async RPC
> "complete" events. It is understandable that nr_dirty can sometimes
> stuck on local waits, but the "local determined" nr_dirty and "remote
> determined" nr_writeback/nr_unstable tend to stuck at the same time?
> Did I miss something (that could be obvious to you)?

It looks (at 7am in the morning after getting up at 4:30am) as though  
the number of unstable pages is remaining constant, which would mean  
that we're sending a lot of COMMIT requests (see nfsstat). Since  
COMMIT is essentially an fsync call, it means that the server is going  
to be slower.

Cheers
     Trond

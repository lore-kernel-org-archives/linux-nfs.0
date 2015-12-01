Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28747 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbbLAPeD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Dec 2015 10:34:03 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add ro_unmap_sync method for FMR
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20151124071215.GC23597@obsidianresearch.com>
Date: Tue, 1 Dec 2015 10:33:18 -0500
Cc: Christoph Hellwig <hch@infradead.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Tom Talpey <tom@talpey.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Sagi Grimberg <sagig@mellanox.com>,
        santosh shilimkar <santosh.shilimkar@oracle.com>
Message-Id: <AE86B182-6000-4437-8502-9D2C5EC3B09D@oracle.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net> <20151123221430.32702.86114.stgit@manet.1015granger.net> <5653B606.3070700@talpey.com> <20151124065225.GB29141@infradead.org> <20151124071215.GC23597@obsidianresearch.com>
To: Linux RDMA Mailing List <linux-rdma@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 24, 2015, at 2:12 AM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
> 
> On Mon, Nov 23, 2015 at 10:52:26PM -0800, Christoph Hellwig wrote:
>> 
>> So at lest for 4.5 we're unlikely to be able to get rid of it alone
>> due to the RDS issue.  We'll then need performance numbers for mlx4,
>> and figure out how much we care about mthca.
> 
> mthca is unfortunately very popular in the used market, it is very
> easy to get cards, build a cheap test cluster, etc. :(

Oracle recently announced Sonoma, which is a SPARC CPU with
an on-chip IB HCA. Oracle plans to publish an open-source
GPL device driver that enables this HCA in Linux for SPARC.
We’d eventually like to contribute it to the upstream
Linux kernel.

At the moment, the device and driver support only FMR. As
you might expect, Oracle needs it to work at least with
in-kernel RDS. Thus we hope to see the life of in-kernel
FMR extended for a bit to accommodate this new device.


--
Chuck Lever





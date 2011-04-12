Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57387 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755947Ab1DLQ0N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Apr 2011 12:26:13 -0400
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1302625032.3877.69.camel@badari-desktop>
References: <1302622335.3877.62.camel@badari-desktop>
	 <1302623369.4801.28.camel@lade.trondhjem.org>
	 <1302625032.3877.69.camel@badari-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 12 Apr 2011 12:26:09 -0400
Message-ID: <1302625569.4801.38.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-04-12 at 09:17 -0700, Badari Pulavarty wrote:
> On Tue, 2011-04-12 at 11:49 -0400, Trond Myklebust wrote:
> > On Tue, 2011-04-12 at 08:32 -0700, Badari Pulavarty wrote:
> > > Hi,
> > > 
> > > We recently ran into serious performance issue with NFS client.
> > > It turned out that its due to lack of readv/write support for
> > > NFS (O_DIRECT) client.
> > > 
> > > Here is our use-case:
> > > 
> > > In our cloud environment, our storage is over NFS. Files
> > > on NFS are passed as a blockdevices to the guest (using
> > > O_DIRECT). When guest is doing IO on these block devices,
> > > they will end up as O_DIRECT writes to NFS (on KVM host).
> > > 
> > > QEMU (on the host) gets a vector from virtio-ring and
> > > submits them. Old versions of QEMU, linearized the vector
> > > it got from KVM (copied them into a buffer) and submits
> > > the buffer. So, NFS client always received a single buffer.
> > > 
> > > Later versions of QEMU, eliminated this copy and submits
> > > a vector directly using preadv/pwritev().
> > > 
> > > NFS client loops through the vector and submits each
> > > vector as separate request for each IO < wsize. In our
> > > case (negotiated wsize=1MB), for 256K IO - we get 64 
> > > vectors, each 4K. So, we end up submitting 64 4K FILE_SYNC IOs. 
> > > Server end up doing each 4K synchronously. This causes
> > > serious performance degrade. We are trying to see if the
> > > performance improves if we convert IOs to ASYNC - but
> > > our initial results doesn't look good.
> > > 
> > > readv/writev support NFS client for all possible cases is
> > > hard. Instead, if all vectors are page-aligned and 
> > > iosizes page-multiple - it fits the current code easily.
> > > Luckily, QEMU use-case fits these requirements.
> > > 
> > > Here is the patch to add this support. Comments ?
> > 
> > Your approach goes in the direction of further special-casing O_DIRECT
> > in the NFS client. I'd like to move away from that and towards
> > integration with the ordinary read/write codepaths so that aside from
> > adding request coalescing, we can also enable pNFS support.
> > 
> 
> I completely agree. But its a major under-taking :(

Sure, but it is one that I'm working on. I'm just explaining why I'd
prefer not to include more stop-gap O_DIRECT patches at this point. We
can afford to wait for one more release cycle if it means fixing
O_DIRECT once and for all.

Cheers,
  Trond


From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
Date: Tue, 12 Apr 2011 09:17:12 -0700
Message-ID: <1302625032.3877.69.camel@badari-desktop>
References: <1302622335.3877.62.camel@badari-desktop>
	 <1302623369.4801.28.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:47293 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758065Ab1DLQPG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Apr 2011 12:15:06 -0400
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3CFnBp5004244
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2011 11:49:11 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 94DA038C8038
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2011 12:14:55 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3CGF5DG312086
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2011 12:15:05 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3CGF3YX012912
	for <linux-nfs@vger.kernel.org>; Tue, 12 Apr 2011 12:15:04 -0400
In-Reply-To: <1302623369.4801.28.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-04-12 at 11:49 -0400, Trond Myklebust wrote:
> On Tue, 2011-04-12 at 08:32 -0700, Badari Pulavarty wrote:
> > Hi,
> > 
> > We recently ran into serious performance issue with NFS client.
> > It turned out that its due to lack of readv/write support for
> > NFS (O_DIRECT) client.
> > 
> > Here is our use-case:
> > 
> > In our cloud environment, our storage is over NFS. Files
> > on NFS are passed as a blockdevices to the guest (using
> > O_DIRECT). When guest is doing IO on these block devices,
> > they will end up as O_DIRECT writes to NFS (on KVM host).
> > 
> > QEMU (on the host) gets a vector from virtio-ring and
> > submits them. Old versions of QEMU, linearized the vector
> > it got from KVM (copied them into a buffer) and submits
> > the buffer. So, NFS client always received a single buffer.
> > 
> > Later versions of QEMU, eliminated this copy and submits
> > a vector directly using preadv/pwritev().
> > 
> > NFS client loops through the vector and submits each
> > vector as separate request for each IO < wsize. In our
> > case (negotiated wsize=1MB), for 256K IO - we get 64 
> > vectors, each 4K. So, we end up submitting 64 4K FILE_SYNC IOs. 
> > Server end up doing each 4K synchronously. This causes
> > serious performance degrade. We are trying to see if the
> > performance improves if we convert IOs to ASYNC - but
> > our initial results doesn't look good.
> > 
> > readv/writev support NFS client for all possible cases is
> > hard. Instead, if all vectors are page-aligned and 
> > iosizes page-multiple - it fits the current code easily.
> > Luckily, QEMU use-case fits these requirements.
> > 
> > Here is the patch to add this support. Comments ?
> 
> Your approach goes in the direction of further special-casing O_DIRECT
> in the NFS client. I'd like to move away from that and towards
> integration with the ordinary read/write codepaths so that aside from
> adding request coalescing, we can also enable pNFS support.
> 

I completely agree. But its a major under-taking :(

Thanks,
Badari


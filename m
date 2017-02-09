Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:59437 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751682AbdBIOIn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2017 09:08:43 -0500
Date: Thu, 9 Feb 2017 05:43:19 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS server regression in v4.10-rc7
Message-ID: <20170209134319.GA29873@infradead.org>
References: <1485246161-20874-1-git-send-email-hch@lst.de>
 <60D0607E-7D01-4F68-A447-071B7DEC6F23@gmail.com>
 <20170208213914.GA1863@infradead.org>
 <BF7B504A-A68C-45CB-8CA9-990F3AB2F1D6@gmail.com>
 <20170209132136.GA23906@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170209132136.GA23906@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 09, 2017 at 05:21:36AM -0800, Christoph Hellwig wrote:
> On Wed, Feb 08, 2017 at 04:54:02PM -0500, Chuck Lever wrote:
> > I see this with my tmpfs export.
> 
> The tests passes fine for me with latests mainline on either tmpfs
> or xfs.  This is on a 64-bit x86 VM.

But that was running as root, I've now reproduced it running as a
regular user.

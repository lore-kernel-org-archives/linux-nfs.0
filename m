Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:43874 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751377AbdBINlN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2017 08:41:13 -0500
Date: Thu, 9 Feb 2017 05:21:36 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chucklever@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS server regression in v4.10-rc7
Message-ID: <20170209132136.GA23906@infradead.org>
References: <1485246161-20874-1-git-send-email-hch@lst.de>
 <60D0607E-7D01-4F68-A447-071B7DEC6F23@gmail.com>
 <20170208213914.GA1863@infradead.org>
 <BF7B504A-A68C-45CB-8CA9-990F3AB2F1D6@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BF7B504A-A68C-45CB-8CA9-990F3AB2F1D6@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 08, 2017 at 04:54:02PM -0500, Chuck Lever wrote:
> I see this with my tmpfs export.

The tests passes fine for me with latests mainline on either tmpfs
or xfs.  This is on a 64-bit x86 VM.

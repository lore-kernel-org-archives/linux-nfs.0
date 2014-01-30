Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52093 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbaA3OcK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 09:32:10 -0500
Date: Thu, 30 Jan 2014 06:32:08 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org
Subject: Re: NFS client broken in Linus' tip
Message-ID: <20140130143208.GB9573@infradead.org>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk>
 <20140130141405.GA23985@infradead.org>
 <20140130142752.GX15937@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140130142752.GX15937@n2100.arm.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 30, 2014 at 02:27:52PM +0000, Russell King - ARM Linux wrote:
> Yes and no.  I still end up with an empty /etc/mtab, but the file now
> exists.  However, I can create and echo data into /etc/mtab, but it seems
> that can't happen at boot time.

Odd.  Can you disable CONFIG_NFSD_V3_ACL for now to isolate the issue?

I'll be out for a long weekend soon, so I have very limited time to
debug things until Monday.


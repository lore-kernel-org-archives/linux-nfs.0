Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:53051 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753137AbaA3PiT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 10:38:19 -0500
Date: Thu, 30 Jan 2014 15:38:12 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org
Subject: Re: NFS client broken in Linus' tip
Message-ID: <20140130153812.GA15937@n2100.arm.linux.org.uk>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk> <20140130141405.GA23985@infradead.org> <20140130142752.GX15937@n2100.arm.linux.org.uk> <20140130143208.GB9573@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140130143208.GB9573@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 30, 2014 at 06:32:08AM -0800, Christoph Hellwig wrote:
> On Thu, Jan 30, 2014 at 02:27:52PM +0000, Russell King - ARM Linux wrote:
> > Yes and no.  I still end up with an empty /etc/mtab, but the file now
> > exists.  However, I can create and echo data into /etc/mtab, but it seems
> > that can't happen at boot time.
> 
> Odd.  Can you disable CONFIG_NFSD_V3_ACL for now to isolate the issue?

Unfortunately, that results in some problem at boot time, which
ultimately ends up with the other three CPUs being stopped, and
hence the original reason scrolls off the screen before it can be
read... even at 1920p.

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:45255 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260AbbCQKag (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 06:30:36 -0400
Date: Tue, 17 Mar 2015 11:30:33 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150317103033.GA22472@lst.de>
References: <20150303221033.GB19439@fieldses.org> <20150315125821.GA10655@lst.de> <20150316142721.GA12231@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150316142721.GA12231@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2015 at 10:27:21AM -0400, J. Bruce Fields wrote:
> > I've been trying ot get a baseline, but even withotu CONFIG_NFSD_PNFS set
> > I start to run into other prolems early on, so I suspect the reproducer might
> > be something else?
> 
> What other problems?

See the "nfsd use after free in 4.0-rc" thread on linux-nfs.

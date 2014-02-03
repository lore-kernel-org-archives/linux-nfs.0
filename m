Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37567 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142AbaBCUyk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 15:54:40 -0500
Date: Mon, 3 Feb 2014 12:54:35 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org
Subject: Re: NFS client broken in Linus' tip
Message-ID: <20140203205435.GA6383@infradead.org>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk>
 <20140130141405.GA23985@infradead.org>
 <20140130142752.GX15937@n2100.arm.linux.org.uk>
 <20140130143208.GB9573@infradead.org>
 <20140130153812.GA15937@n2100.arm.linux.org.uk>
 <1391201970.6978.1.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1391201970.6978.1.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good as the lesser evil:

Reviewed-by: Christoph Hellwig <hch@lst.de>

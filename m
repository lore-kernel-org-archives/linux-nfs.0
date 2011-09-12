Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:60255 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584Ab1ILJ2l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 05:28:41 -0400
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>,
        Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>
Date: Mon, 12 Sep 2011 11:04:45 +0200
In-Reply-To: <20110909133611.GB8155@infradead.org>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
	 <1315566054-17209-4-git-send-email-mgorman@suse.de>
	 <20110909130007.GA11810@infradead.org> <20110909131550.GV14369@suse.de>
	 <20110909133611.GB8155@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1315818285.26517.18.camel@twins>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-09-09 at 09:36 -0400, Christoph Hellwig wrote:
> The equivalent of ->direct_IO should be used for both reads and writes.

So the difference between DIO and swapIO is that swapIO needs the block
map pinned in memory.. So at the very least you'll need those
swap_{activate,deactivate} aops. The read/write-page thingies could
indeed be shared with DIO.



Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49101 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881Ab3KMQwF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 11:52:05 -0500
Date: Wed, 13 Nov 2013 08:52:04 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
Message-ID: <20131113165204.GB8676@infradead.org>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
 <20131112194529.GA26341@fieldses.org>
 <52828767.3030909@netapp.com>
 <20131112195911.GA28033@fieldses.org>
 <5283A24D.4010309@netapp.com>
 <5283A3B7.8080405@netapp.com>
 <20131113161527.GA10046@infradead.org>
 <20131113164959.GL28033@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131113164959.GL28033@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 13, 2013 at 11:49:59AM -0500, J. Bruce Fields wrote:
> This isn't a candidate for 3.13, and SEEK didn't look like the most
> problematic bit, so with a couple more months I'm hoping we'll be more
> confident about the protocol?

Wish I knew.  The ieft list seems to be at an awfully small pace, and
the actual spec seems another layer separated from that.  People who
are more familar with the process might have to chime in.


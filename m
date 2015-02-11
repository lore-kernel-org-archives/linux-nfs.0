Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42807 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbbBKMh6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 07:37:58 -0500
Date: Wed, 11 Feb 2015 04:37:57 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: default NFSv4.2 to on
Message-ID: <20150211123757.GA10532@infradead.org>
References: <20150202161557.GF22301@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150202161557.GF22301@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 02, 2015 at 11:15:57AM -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> The code seems to work.  The protocol looks stable.  The kernel's
> version defaults can be overridden by rpc.nfsd arguments.

Does it really make sense to enabled this without READ_PLUS support
or implementing the various new attributes?

Also should we add a wiki page with the 4.2 status?

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54906 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbaE1TiF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 15:38:05 -0400
Date: Wed, 28 May 2014 12:38:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: getattr for FATTR4_WORD0_FILES_AVAIL needs the
 statfs buffer
Message-ID: <20140528193802.GA13258@infradead.org>
References: <1401266773-19048-1-git-send-email-hch@lst.de>
 <20140528193555.GD22210@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140528193555.GD22210@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 28, 2014 at 03:35:55PM -0400, J. Bruce Fields wrote:
> Thanks, applying for 3.16 and stable.
> 
> But, I don't get it: we've been returning random uninitialized data in
> FILES_AVAIL since forever, and nobody's noticed till now?
> 
> Oh, I see: probably every client requests at least one other thing on
> that list at the same time it requests FILES_AVAIL.

Yeah.  I only found this when prototyping schemes to split
nfsd4_encode_fattr into easier manageable chunks.


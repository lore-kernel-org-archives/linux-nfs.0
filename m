Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39012 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbaHUQNj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:13:39 -0400
Date: Thu, 21 Aug 2014 09:13:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: pnfs block layout driver fixes V2
Message-ID: <20140821161338.GA31352@infradead.org>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For some reason the subject of the mail got lost, fixed it.

On Thu, Aug 21, 2014 at 11:09:16AM -0500, Christoph Hellwig wrote:
> This series fixes a wide range of issues with the pnfs block layout driver.
> 
> Before this we were seeing frequent silent data corruption, softlockups and
> kernel crashes when running both user applications and test cases like xfstests.
> 
> After this rewrite of the I/O path we've sorted out all issues under normal
> operations, although error handling in the block layout driver and its
> interaction with the core nfs and pnfs code still needs further work.
> 
> It was pointed out that the requirement for blocksizes smaller or equal to
> the page size conflicts with existing servers.  From the state of the code
> I'm very sure it was never used for real against those servers, but as
> soon as someone signs up to testing and fix support for these servers I'm
> happy to land a helping hand, although rock solid support probably is
> imposible.
> 
> This work was sponsored by NetApp, Inc.
> 
> Changes since V1:
>  - added two more layout stateid handling fixes
>  - change the layoutget path so that the layout driver is responsible for
>    freeing the spliced in payload.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---

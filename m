Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43038 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965792AbbD1Uuu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 16:50:50 -0400
Date: Tue, 28 Apr 2015 16:50:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/6] nfsd: take struct file setup fully into
 nfs4_preprocess_stateid_op
Message-ID: <20150428205049.GD16090@fieldses.org>
References: <1430228480-7656-1-git-send-email-hch@lst.de>
 <1430228480-7656-6-git-send-email-hch@lst.de>
 <20150428204455.GC16090@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150428204455.GC16090@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2015 at 04:44:55PM -0400, J. Bruce Fields wrote:
> On Tue, Apr 28, 2015 at 03:41:19PM +0200, Christoph Hellwig wrote:
> > This patch changes nfs4_preprocess_stateid_op so it always returns
> > a valid struct file if it has been asked for that.  For that we
> > now allocate a temporary struct file for special stateids, and check
> > permissions if we got the file structure from the stateid.  This
> > ensures that all callers will get their handling of special stateids
> > right, and avoids code duplication.
> > 
> > There is a little wart in here because the read code needs to know
> > if we allocated a file structure so that it can copy around the
> > read-ahead parameters.  In the long run we should probably aim to
> > cache full file structures used with special stateids instead.
> 
> This causes a failure on pynfs OPEN23b.
> 
> It's doing a READ using a stateid from a write open.  We previously
> returned NFS_OK, taking the "may" option from:
> 
> 	http://tools.ietf.org/html/rfc7530#page-111
> 
> 	In the case of READ, the server may perform the corresponding
> 	check on the access mode, or it may choose to allow READ on
> 	opens for WRITE only, to accommodate clients whose write
> 	implementation may unavoidably do reads (e.g., due to buffer
> 	cache constraints).
> 
> OPENMODE might also have been OK, but we're returning SERVERFAULT.  I
> guess the old code was passing preprocess_stateid_op without returning a
> file, then relying on a temporary open for the read?  Ugh.

Hm, and writes with special stateids (e.g. WRT1) are timing out, I
haven't figured that out.

--b.

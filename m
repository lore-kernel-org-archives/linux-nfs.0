Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36391 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684AbaIITAk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 15:00:40 -0400
Date: Tue, 9 Sep 2014 15:00:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] NFSD: Add ALLOCATE and DEALLOCATE support
Message-ID: <20140909190035.GA17979@fieldses.org>
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20140909181302.GA17155@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140909181302.GA17155@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 09, 2014 at 11:13:02AM -0700, Christoph Hellwig wrote:
> Sorry to hijack this thread, but talking about 4.2 server features, did
> anyone into looking into implementing the change_attr_type attribute,
> which should be fairly low hanging fruit?

I haven't seen anything.  Agreed that it should be easy (on the server
side--the client's use might be more complicated?).

--b.

> 
> Also someone with interest in btrfs might want to look into implementing
> the space_freed attribute with a call into the filesystem.
> 

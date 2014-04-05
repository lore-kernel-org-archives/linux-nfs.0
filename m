Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36970 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602AbaDEAUP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2014 20:20:15 -0400
Date: Fri, 4 Apr 2014 20:20:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 22/50] nfsd4: use xdr_truncate_encode
Message-ID: <20140405002006.GH17594@fieldses.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-23-git-send-email-bfields@redhat.com>
 <20140323065005.GC24465@infradead.org>
 <20140323150722.GC30644@fieldses.org>
 <20140325153632.GA5613@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140325153632.GA5613@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 25, 2014 at 08:36:32AM -0700, Christoph Hellwig wrote:
> On Sun, Mar 23, 2014 at 11:07:22AM -0400, J. Bruce Fields wrote:
> > In the splice case read increments page_len as it goes.  This leaves the
> > xdr_buf in somewhat of an inconsistent state and may confuse a later
> > xdr_truncate_encode.
> > 
> > It's a little ugly, I'm not sure what to do about it.  Currently I'm
> > thinking of just telling nfsd's splice callback to leave page_len alone.
> > That'd mean taking another look at the splice callback and at the v2/v3
> > read code.
> 
> How a about just adding a comment explaing this for now?

OK, done.--b.

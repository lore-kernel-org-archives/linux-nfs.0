Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55274 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbaCYPgf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Mar 2014 11:36:35 -0400
Date: Tue, 25 Mar 2014 08:36:32 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 22/50] nfsd4: use xdr_truncate_encode
Message-ID: <20140325153632.GA5613@infradead.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-23-git-send-email-bfields@redhat.com>
 <20140323065005.GC24465@infradead.org>
 <20140323150722.GC30644@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140323150722.GC30644@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 23, 2014 at 11:07:22AM -0400, J. Bruce Fields wrote:
> In the splice case read increments page_len as it goes.  This leaves the
> xdr_buf in somewhat of an inconsistent state and may confuse a later
> xdr_truncate_encode.
> 
> It's a little ugly, I'm not sure what to do about it.  Currently I'm
> thinking of just telling nfsd's splice callback to leave page_len alone.
> That'd mean taking another look at the splice callback and at the v2/v3
> read code.

How a about just adding a comment explaing this for now?


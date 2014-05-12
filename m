Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47561 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbaELFh1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 May 2014 01:37:27 -0400
Date: Sun, 11 May 2014 22:37:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 04/43] nfsd4: reserve head space for krb5 integ/priv info
Message-ID: <20140512053727.GE29134@infradead.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-5-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1399841568-19716-5-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 11, 2014 at 04:52:09PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Currently if the nfs-level part of a reply would be too large, we'll
> return an error to the client.  But if the nfs-level part fits and
> leaves no room for krb5p or krb5i stuff, then we just drop the request
> entirely.
> 
> That's no good.  Instead, reserve some slack space at the end of the
> buffer and make sure we fail outright if we'd come close.
> 
> The slack space here is a massive overstimate of what's required, we
> should probably try for a tighter limit at some point.

Don't we know the rpc auth scheme at this point and can at least
avoid it for non-krb setups?


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56501 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758238Ab3JKThX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Oct 2013 15:37:23 -0400
Date: Fri, 11 Oct 2013 12:37:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 21/49] nfsd: no need to unhash_stid before free
Message-ID: <20131011193721.GA4941@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220876-13642-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220876-13642-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 02:41:16PM -0400, Benny Halevy wrote:
> idr_remove is about to be called before kmem_cache_free so unhashing it
> is redundant
> 
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>

This is probably something thast should go straight to Bruce, same for
the next one in the series.


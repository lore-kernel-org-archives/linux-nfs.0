Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46267 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbaCWGuF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 02:50:05 -0400
Date: Sat, 22 Mar 2014 23:50:05 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 22/50] nfsd4: use xdr_truncate_encode
Message-ID: <20140323065005.GC24465@infradead.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-23-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1395537141-10389-23-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ah, here we got the helper for most of the error handling I asked for
earlier.  Might be worth mentioning in that patch that this gets further
improvements soons.

>  	if (nfserr) {
> -		xdr->p -= 2;
> -		xdr->iov->iov_len -= 8;
> +		xdr->buf->page_len = 0;
> +		xdr_truncate_encode(xdr, starting_len);

Why do we still need to manually set the page_len?


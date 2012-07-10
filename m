Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:47759
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753136Ab2GJRee (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jul 2012 13:34:34 -0400
Date: Tue, 10 Jul 2012 13:34:32 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, stable@kernel.org
Subject: Re: [PATCH 4/7] nfsd4: our filesystems are normally case sensitive
Message-ID: <20120710173432.GA18485@infradead.org>
References: <1341936466-3821-1-git-send-email-bfields@redhat.com>
 <1341936466-3821-5-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1341936466-3821-5-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 10, 2012 at 12:07:43PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Actually, xfs can optionally be case insensitive; we'll handle that case
> in later patches.

The same is true for jfs, btw.


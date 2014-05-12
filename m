Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11342 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894AbaELOGr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 May 2014 10:06:47 -0400
Date: Mon, 12 May 2014 10:06:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/43] nfsd4: allow space for final error return
Message-ID: <20140512140622.GA2633@pad.redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-8-git-send-email-bfields@redhat.com>
 <20140512081846.GB14194@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140512081846.GB14194@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 12, 2014 at 01:18:46AM -0700, Christoph Hellwig wrote:
> On Sun, May 11, 2014 at 04:52:12PM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > This post-encoding check should be taking into account the need to
> > encode at least an out-of-space error to the following op (if any).
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks, added Reviewed-by's for 1,2,3,7.--b.

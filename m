Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34550 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399AbaJAQ3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Oct 2014 12:29:47 -0400
Date: Wed, 1 Oct 2014 12:29:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: eliminate "to_delegation" define
Message-ID: <20141001162941.GA28623@fieldses.org>
References: <1412165122-17557-1-git-send-email-jlayton@primarydata.com>
 <20141001124257.GA14872@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141001124257.GA14872@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 01, 2014 at 05:42:57AM -0700, Christoph Hellwig wrote:
> On Wed, Oct 01, 2014 at 08:05:22AM -0400, Jeff Layton wrote:
> > We now have cb_to_delegation and to_delegation, which do the same thing
> > and are defined separately in different .c files. Move the
> > cb_to_delegation definition into a header file and eliminate the
> > redundant to_delegation definition.
> > 
> > Cc: Christoph Hellwig <hch@infradead.org>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Got it, thanks.--b.

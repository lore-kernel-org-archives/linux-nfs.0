Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51812 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756764AbcJ1UyS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Oct 2016 16:54:18 -0400
Date: Fri, 28 Oct 2016 16:54:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix error handling for clients that fail to return
 the layout
Message-ID: <20161028205417.GB11926@fieldses.org>
References: <1476980494-2984-1-git-send-email-jlayton@redhat.com>
 <20161021121759.GA17325@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161021121759.GA17325@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 21, 2016 at 02:17:59PM +0200, Christoph Hellwig wrote:
> On Thu, Oct 20, 2016 at 12:21:34PM -0400, Jeff Layton wrote:
> > Currently, when the client continually returns NFS4ERR_DELAY on a
> > CB_LAYOUTRECALL, we'll give up trying to retransmit after two lease
> > periods, but leave the layout in place.
> > 
> > What we really need to do here is fence the client in this case. Have it
> > fall through to that code in that case instead of into the
> > NFS4ERR_NOMATCHING_LAYOUT case.
> 
> Agreed.  Looks good:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks, applying for 4.10.

--b.

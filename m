Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:52154 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755244AbcJUMSB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Oct 2016 08:18:01 -0400
Date: Fri, 21 Oct 2016 14:17:59 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: bfields@fieldses.org, hch@lst.de, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix error handling for clients that fail to
        return the layout
Message-ID: <20161021121759.GA17325@lst.de>
References: <1476980494-2984-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1476980494-2984-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2016 at 12:21:34PM -0400, Jeff Layton wrote:
> Currently, when the client continually returns NFS4ERR_DELAY on a
> CB_LAYOUTRECALL, we'll give up trying to retransmit after two lease
> periods, but leave the layout in place.
> 
> What we really need to do here is fence the client in this case. Have it
> fall through to that code in that case instead of into the
> NFS4ERR_NOMATCHING_LAYOUT case.

Agreed.  Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

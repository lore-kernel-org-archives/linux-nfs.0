Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57768 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbaHXPsj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 11:48:39 -0400
Date: Sun, 24 Aug 2014 08:48:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org, hch@infradead.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/10] nfsd: fix potential lease memory leak in
 nfs4_setlease
Message-ID: <20140824154839.GB15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-3-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408804878-1331-3-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 23, 2014 at 10:41:10AM -0400, Jeff Layton wrote:
> It's unlikely to ever occur, but if there were already a lease set on
> the file then we could end up getting back a different pointer on a
> successful setlease attempt than the one we allocated. If that happens,
> the one we allocated could leak.
> 
> In practice, I don't think this will happen due to the fact that we only
> try to set up the lease once per nfs4_file, but this error handling is a
> bit more correct given the current lease API.
> 
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

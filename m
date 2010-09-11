Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:46829 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755038Ab0IKAHu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 20:07:50 -0400
Date: Fri, 10 Sep 2010 20:07:49 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, Fred Isaman <iisaman@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file
 layout driver
Message-ID: <20100911000749.GA31628@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
 <1283450419-5648-9-git-send-email-iisaman@netapp.com>
 <1284147111.10062.74.camel@heimdal.trondhjem.org>
 <20100910235600.GA11231@infradead.org>
 <1284163433.14078.102.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1284163433.14078.102.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 10, 2010 at 08:03:53PM -0400, Trond Myklebust wrote:
> So you are saying we should simply equate CONFIG_PNFS_FILE_LAYOUT and
> CONFIG_NFS_V4_1 right now? Yep, I'd be fine with that... I'm still
> working on the patches to get rid of all these CONFIG options, but
> ultimately this is what I'm working towards.

If you don't want a separate option that's up to you, but I don't think
forcing people to built the pnfs file layout just because they want nfs4.1
features is an all that smart idea.


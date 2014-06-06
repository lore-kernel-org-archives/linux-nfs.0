Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37030 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbaFFOOc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2014 10:14:32 -0400
Date: Fri, 6 Jun 2014 07:14:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, hch@infradead.org
Subject: Re: [PATCH v2 1/2] nfsd: Protect addition to the file_hashtbl
Message-ID: <20140606141431.GC9303@infradead.org>
References: <1402060026-26511-1-git-send-email-jlayton@primarydata.com>
 <1402060026-26511-2-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1402060026-26511-2-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 06, 2014 at 09:07:05AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Ensure that we only can have a single struct nfs4_file per inode
> in the file_hashtbl and make addition atomic with respect to lookup.
> 
> To prevent an i_lock/state_lock inversion, change nfsd4_init_file to
> use ihold instead if igrab. That's also more efficient anyway as we
> definitely hold a reference to the inode at that point.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

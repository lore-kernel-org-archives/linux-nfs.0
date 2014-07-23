Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32801 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932847AbaGWUrU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2014 16:47:20 -0400
Date: Wed, 23 Jul 2014 16:47:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: Re: [PATCH v2 0/4] nfsd: don't let nfs4_file pin down the inode when
 it has no open state
Message-ID: <20140723204712.GI9118@fieldses.org>
References: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 23, 2014 at 04:17:37PM -0400, Jeff Layton wrote:
> This is a port of the patches that Trond sent the other day onto the
> current tip of Bruce's for-3.17 branch. It basically changes how
> nfs4_file objects are hashed. Instead of using the inode pointer (and
> pinning down an inode in the process), it uses the filehandle. This
> allows us to avoid taking an inode reference directly for the nfs4_file.
> With this, they're only taken by virtue of the files in the fi_fds
> array.

Looks OK to me.  I'll give it a day in case Christoph or someone spots a
problem.

--b.

> 
> Jeff Layton (1):
>   nfsd: Do not let nfs4_file pin the struct inode
> 
> Trond Myklebust (3):
>   nfsd: Store the filehandle with the struct nfs4_file
>   nfsd: Use the filehandle to look up the struct nfs4_file instead of
>     inode
>   nfsd: nfs4_check_fh - make it actually check the filehandle
> 
>  fs/nfsd/nfs4state.c | 86 +++++++++++++++++++++++++++++++++--------------------
>  fs/nfsd/state.h     |  2 +-
>  2 files changed, 54 insertions(+), 34 deletions(-)
> 
> -- 
> 1.9.3
> 

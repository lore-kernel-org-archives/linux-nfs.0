Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57420 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbaGVRv4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jul 2014 13:51:56 -0400
Date: Tue, 22 Jul 2014 13:51:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: Re: [PATCH 0/4] nfsd: don't let nfs4_file pin down the inode when it
 has no open state
Message-ID: <20140722175155.GB27277@fieldses.org>
References: <1406047784-1578-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1406047784-1578-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 22, 2014 at 12:49:40PM -0400, Jeff Layton wrote:
> This is a port of the patches that Trond sent last night onto the
> current tip of Bruce's for-3.17 branch. It basically changes how
> nfs4_file objects are hashed. Instead of using the inode pointer (and
> pinning down an inode in the process), it uses the filehandle. This
> allows us to avoid taking an inode reference directly for the nfs4_file.
> It now only takes them indirectly by virtue of struct file objects in
> the fi_fds array.

Looks reasonable on a quick skim.

It might make sense to get rid of dl_fh at some point?

--b.

> 
> If this looks good, I'll resend the unmerged delegation overhaul
> patches, rebased on top of this series.
> 
> Trond Myklebust (4):
>   nfsd: Store the filehandle with the struct nfs4_file
>   nfsd: Use the filehandle to look up the struct nfs4_file instead of
>     inode
>   nfsd: nfs4_check_fh - make it actually check the filehandle
>   nfsd: Do not let nfs4_file pin the struct inode
> 
>  fs/nfsd/nfs4state.c | 68 +++++++++++++++++++++++++++++++----------------------
>  fs/nfsd/state.h     |  3 ++-
>  2 files changed, 42 insertions(+), 29 deletions(-)
> 
> -- 
> 1.9.3
> 

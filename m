Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51036 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755554AbaAFWcD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 17:32:03 -0500
Date: Mon, 6 Jan 2014 17:32:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] READ_PLUS rough draft
Message-ID: <20140106223201.GA3342@fieldses.org>
References: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 06, 2014 at 04:57:10PM -0500, Anna Schumaker wrote:
> These patches are my initial implementation of READ_PLUS.  I still have a
> few issues to work out before they can be applied, but I wanted to submit
> them anyway to get feedback before going much further.  These patches were
> developed on top of my earlier SEEK and WRITE_PLUS patches, and probably
> won't apply cleanly without them (I am willing to reorder things if necessary!).
> 
> On the server side, I handle the cases where a file is 100% hole, 100% data
> or hole followed by data.  Any holes after a data segment will be expanded
> to zeros on the wire.

I assume that for "a file" I should read "the requested range of the
file"?

hole+data+hole should also be doable, shouldn't it?  I'd think the real
problem would be multiple data extents.

> This is due to a limitation in the the NFSD
> encode-to-page function that will adjust pointers to point to the xdr tail
> after reading a file to the "pages" section.  Bruce, do you have any
> suggestions here?

The server xdr encoding needs a rewrite.  I'll see if I can ignore you
all and put my head down and get a version of that posted this week.

That should make it easier to return all the data, though it will turn
off zero-copy in the case of multiple data extents.

If we want READ_PLUS to support zero copy in the case of multiple
extents then I think we need a new data structure to represent the
resulting rpc reply.  An xdr buf only knows how to insert one array of
pages in the middle of the data.  Maybe a list of xdr bufs?

But that's an annoying job and possibly a premature optimization.

It might be useful to first understand the typical distribution of holes
in a file and how likely various workloads are to produce reads with
multiple holes in the middle.

--b.

> 
> The client side needs to punch holes after decoding page information, since
> data on pages will be aligned at the start of the page array.  So a file that
> is <HOLE><DATA> will store the hole information, decode the data, and then
> punch the hole before returning.  I think it would be better to use the
> provided offset field to decode everything to their final locations, but I'm
> struggling to come up with a clean way of doing so using the code that is
> already there.
> 
> Let me know what you all think!
> Anna
> 
> Anna Schumaker (3):
>   NFSD: Implement READ_PLUS support
>   SUNRPC: This patch adds functions for shifting page data
>   NFS: Client side changes for READ_PLUS
> 
>  fs/nfs/nfs4client.c        |   2 +-
>  fs/nfs/nfs4proc.c          |  23 +++++-
>  fs/nfs/nfs4xdr.c           | 191 +++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/Kconfig            |  14 ++++
>  fs/nfsd/nfs4proc.c         |   9 +++
>  fs/nfsd/nfs4xdr.c          | 177 ++++++++++++++++++++++++++++++++++++-----
>  include/linux/nfs4.h       |   1 +
>  include/linux/nfs_fs_sb.h  |   1 +
>  include/linux/sunrpc/xdr.h |   1 +
>  net/sunrpc/xdr.c           | 115 ++++++++++++++++++++++++++-
>  10 files changed, 511 insertions(+), 23 deletions(-)
> 
> -- 
> 1.8.5.2
> 

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44472 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935467AbaH0TjT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2014 15:39:19 -0400
Date: Wed, 27 Aug 2014 15:39:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] NFSD: Add v4.2 SEEK support
Message-ID: <20140827193917.GG13910@fieldses.org>
References: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 27, 2014 at 11:17:55AM -0400, bjschuma@netapp.com wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> These patches add server support for the NFS v4.2 operation SEEK.  The first
> two patches are error cleanups and infrastructure setup to prepare for the
> addition of new operations.
> 
> My biggest concern is that these patches freeze the v4.2 opcodes to their
> current values, which makes any future spec changes to add or remove
> operations more difficult to accomidate.

I don't think it's so bad--worst case we end up with a hole in the list
of operation numbers, but I don't think that's a big deal.

So I'd drop the warning in the config text.

Anyway, the code's simple enough.  Assuming the client patches are
ready, I'll be inclined to merge (revised versions of) these for 3.18.

--b.

> 
> Questions?  Comments?  Thoughts?
> 
> Anna
> 
> 
> Anna Schumaker (3):
>   NFSD: Update error codes
>   NFSD: Create nfs v4.2 decode ops
>   NFSD: Implement SEEK
> 
>  fs/nfsd/Kconfig      | 12 +++++++++
>  fs/nfsd/nfs4proc.c   | 47 +++++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4xdr.c    | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfsd.h       |  2 +-
>  fs/nfsd/xdr4.h       | 14 ++++++++++
>  include/linux/nfs4.h | 26 ++++++++++++++++---
>  6 files changed, 170 insertions(+), 4 deletions(-)
> 
> -- 
> 2.1.0
> 

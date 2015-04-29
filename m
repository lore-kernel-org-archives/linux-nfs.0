Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750737AbbD2UZv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2015 16:25:51 -0400
Date: Wed, 29 Apr 2015 16:25:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Define common macro NFS4_MAXTAGLEN for nfs/nfsd
Message-ID: <20150429202548.GD23980@fieldses.org>
References: <5516CCDB.4020509@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5516CCDB.4020509@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 28, 2015 at 11:46:35PM +0800, Kinglong Mee wrote:
> There are four macro defines for max tag length, 
> in fs/nfs/nfs4xdr.c,
> /* NFSv4 COMPOUND tags are only wanted for debugging purposes */
> #ifdef DEBUG
> #define NFS4_MAXTAGLEN		20
> #else
> #define NFS4_MAXTAGLEN		0
> #endif
> 
> in fs/nfs/callback_xdr.c,
> #define CB_OP_TAGLEN_MAXSZ	(512)
> 
> in fs/nfsd/xdr4.h,
> #define NFSD4_MAX_TAGLEN	128
> 
> in fs/nfsd/xdr4cb.h,
> #define NFS4_MAXTAGLEN		20
> 
> But, according to rfc3530 and rfc5661, all the length should be
> limited by opaque limited.

Neither server nor client really make any use of tags.  The client at
least is never going to send a tag.  The server does echo back the tag
the client received.

The one arguable bug here is that the spec doesn't appear to forbid the
server returning a non-zero-length tag when the client sent a
zero-length tag.  And I don't think the client would handle that?

If so, that might be better handled as a spec bug: if the most popular
client has never handled it then we know that no server's ever done it.
And it'd be annoying server behavior anyway, so, if it's de-facto
forbidden, great.

In short, maybe best to just leave all this alone unless somebody's
actually seen this cause real-world problems....

--b.

> 
> The patch site defines a common macro named NFS4_MAXTAGLEN for
> all of them, limited to opaque limited.
> 
> Kinglong Mee (4):
>   nfs: define NFS4_MAXTAGLEN to OPAQUE limits
>   nfs: use NFS4_MAXTAGLEN for cb_taglen checking
>   nfsd: use NFS4_MAXTAGLEN for nfsd taglen checking
>   nfsd: use NFS4_MAXTAGLEN defined in include/linux/nfs4.h
> 
>  fs/nfs/callback_xdr.c | 5 ++---
>  fs/nfs/nfs4xdr.c      | 7 -------
>  fs/nfsd/nfs4xdr.c     | 2 +-
>  fs/nfsd/xdr4.h        | 1 -
>  fs/nfsd/xdr4cb.h      | 3 ++-
>  include/linux/nfs4.h  | 1 +
>  6 files changed, 6 insertions(+), 13 deletions(-)
> 
> -- 
> 2.3.4

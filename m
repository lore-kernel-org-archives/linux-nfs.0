Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:32961 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932919AbbHILTf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Aug 2015 07:19:35 -0400
Received: by ykaz130 with SMTP id z130so12660006yka.0
        for <linux-nfs@vger.kernel.org>; Sun, 09 Aug 2015 04:19:35 -0700 (PDT)
Date: Sun, 9 Aug 2015 07:19:32 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 04/18] nfsd: add a new struct file caching facility
 to nfsd
Message-ID: <20150809071932.3ef4d0a2@tlielax.poochiereds.net>
In-Reply-To: <20150809071702.GD9772@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-5-git-send-email-jeff.layton@primarydata.com>
	<20150809071702.GD9772@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 9 Aug 2015 00:17:02 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Aug 05, 2015 at 05:13:22PM -0400, Jeff Layton wrote:
> > Currently, NFSv2/3 reads and writes have to open a file, do the read or
> > write and then close it again for each RPC. This is highly inefficient,
> > especially when the underlying filesystem has a relatively slow open
> > routine.
> 
> .. as do many NFSv4 reads and writes as they often get special stateids
> passed from the client.  Seems a little odd that we take more care
> of this for the legacy protocols than the current one.
> 

This is just an initial step. I'd like to see the nfs4_file cache
layered on top of this eventually. That's a bit more work though, and I
wanted to get this piece merged first before I did that part.

> I think I'd rather see a nfs4_file cache and turn v2/3 into something
> like the special stateid case.  Did you consider that?

I started looking at extending the nfs4_file cache to NFSv2/3, but it's
actually rather difficult...

We traditionally haven't dealt with share/deny modes in NFSv3, so we'd
need a mechanism to bypass all of that stuff for legacy protocols. We'd
also have to convert that cache from one that frees objects when the
last one is put to one that keeps them around for a bit.

That also means that the v2/3 opens have to keep around extra fields
that aren't really needed, and deal with the really godawful locking of
the NFSv4 code.

I really think this approach is a better one. We can still use this
cache from the NFSv4 code and wiring it in shouldn't be too hard. It's
mostly a matter of plumbing in struct nfsd_file objects where that code
is passing around struct file objects now.

-- 
Jeff Layton <jlayton@poochiereds.net>

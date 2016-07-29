Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44676 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbcG2S7f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 14:59:35 -0400
Date: Fri, 29 Jul 2016 14:59:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        Trond.Myklebust@primarydata.com
Subject: Re: [PATCH v4 0/3] NFSv4.2: Add support for the COPY operation
Message-ID: <20160729185933.GA7964@fieldses.org>
References: <1461962533-26534-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20160501173733.GA556@infradead.org>
 <20160513203135.GE5658@fieldses.org>
 <8d09611c-31c1-baca-8e8f-6dc599731c8c@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8d09611c-31c1-baca-8e8f-6dc599731c8c@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 13, 2016 at 04:58:06PM -0400, Anna Schumaker wrote:
> On 05/13/2016 04:31 PM, J. Bruce Fields wrote:
> > On Sun, May 01, 2016 at 10:37:33AM -0700, Christoph Hellwig wrote:
> >> I might sound like a broken record, but I'd feel much happier if this
> >> had extensive xfstests coverage.  Xfstests has over one hundred tests for
> >> file clones, and many of them should be easily adapatable.
> > 
> > Anna, have you looked at this yet?
> 
> Yep!  I just sent out what I came up with :)

Sorry for the lack of response.  For some reason I don't seem to have
the updated version in my mailboxes.  Do you have a more recent version?

> > I don't see any obvious problem with the nfsd code, other than the
> > obvious issue with large synchronous copies tying up server threads and
> > leaving clients waiting--but maybe we should just see how people end up
> > using it and deal with the problems as they come up.

I'm still worrying about this, though.

As a simple stopgap, could we just set *some* maximum on the size of the
copy?  Or better yet on the time?--that'd let filesystems with
clone-like features copy the whole file without blocking an nfsd thread
indefinitely in the case of other filesystems.

--b.

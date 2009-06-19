Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out3.apple.com ([17.254.13.22]:63543 "EHLO
	mail-out3.apple.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753265AbZFSC1x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 22:27:53 -0400
Date: Thu, 18 Jun 2009 19:27:54 -0700
From: Mike Mackovitch <macko@apple.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Mike Mackovitch <macko@apple.com>, Benny Halevy <bhalevy@panasas.com>,
        pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 28/44] nfsd41: use the maximum operations per compound
	in nfsd4_compoundargs
Message-ID: <20090619022754.GA19679@m3.macko.edu>
References: <1245115233-7725-1-git-send-email-bhalevy@panasas.com> <20090618221443.GH12234@fieldses.org> <20090619004936.GB19581@m3.macko.edu> <20090619010410.GC16785@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20090619010410.GC16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 18, 2009 at 09:04:10PM -0400, J. Bruce Fields wrote:
> On Thu, Jun 18, 2009 at 05:49:36PM -0700, Mike Mackovitch wrote:
> 
> > As an NFS client implementer I wouldn't expect to generate a compound
> > with anything near 100 ops.  However, I have recently composed a
> > compound consisting of up to 12 ops (attempting to be efficient in
> > some NFSv4.0 named attribute code).  And 12 is larger than 8.... so
> > I'll probably be sad if Linux isn't going to be supporting that many
> > ops in a compound.
> 
> OK.  I wanna know how you got up to 12, though! That's quite a compound.

Drat!  I was kinda hoping you wouldn't ask.  :-)

MacOSX's VFS currently has both an extended attribute interface and a
named stream (think "resource fork") interface.  I was investigating
using NFSv4(.0) named attributes to back both, and I was trying to devise
an efficient method of "getting" named attributes (and their typically-small
contents) and properly maintaining a cache of named attribute directory/file
attributes and contents.

I wanted to minimize the number of round trips to the server.  I also
wanted to minimize code duplication.  And I ended up with a common
function that sends a compound containing 5, 8, or 12 ops - depending
on what we had cached already and if we were trying to also READ data:

PUTFH       - of the file/directory we want the named attribute for
OPENATTR    - to get the named attribute directory
GETATTR(FH) - to be able to cache the attribute directory (name cache and readdir cache)
LOOKUP or OPEN(potentially with CREATE)
GETATTR(FH) - to get the named attribute file's file handle and attributes
SAVEFH      - to save it for reading the first chunk of data from it
PUTFH       - of the file/directory
OPENATTR    - to get back to its named attribute directory
GETATTR     - to get updated attributes for the named attribute directory
RESTOREFH   - get back to the (potentially new) named attribute file
NVERIFY (size==0) - don't bother trying to read if the named attribute file is empty
READ        - read the first chunk (and potentially all of) of the named attribute file

If we already have the attribute directory we don't need to do the OPENATTR's
or the first GETATTR (we just PUTFH the attribute directory's fh).  We'd
like to also fetch post-lookup/open attributes for the attribute directory.
And we want to leave the READ results for last (to simplify some of the coding).
If we're not READing we don't need to send the SAVEFH, RESTOREFH, NVERIFY, READ.

It's not necessarily pretty (some might argue it's ugly)... but it appears to
work and I don't think it's too much of an "abuse" of the protocol.  :-)

In any event, while we don't normally expect to use long compounds, we still
would like to be able to use them when we're trying to efficiently handle the
demands of an operating system that depends on certain file system features.

So, if a server is going to put a limit on the number of ops in a compound,
we'd prefer if it were higher rather than lower.  8 seems too low.  16 might
be good but I'm thinking 24 or 32 might be a safer, longer-term limit to
satisfy the needs of future "demanding" NFS clients.

Thanks
--macko

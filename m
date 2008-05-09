From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [PATCH] exportfs: fix incorrect EACCES in reconnect_path()
Date: Fri, 9 May 2008 12:11:34 +0200
Message-ID: <20080509101134.GA665@janus>
References: <20080502153439.GC7376@infradead.org> <20080502155617.GD18401@fieldses.org> <1209744293.8294.19.camel@heimdal.trondhjem.org> <20080502221216.GP21918@fieldses.org> <18462.17737.353976.999538@notabene.brown> <20080505174716.GA12814@fieldses.org> <18463.42978.531115.344884@notabene.brown> <20080506195041.GD13484@fieldses.org> <18466.28013.258338.485948@notabene.brown> <20080509043425.GD21408@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Christoph Hellwig <hch@infradead.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Christoph Hellwig <hch@lst.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:36268 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754722AbYEIKLf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 May 2008 06:11:35 -0400
In-Reply-To: <20080509043425.GD21408@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 09, 2008 at 12:34:25AM -0400, J. Bruce Fields wrote:
> On Thu, May 08, 2008 at 01:03:09PM +1000, Neil Brown wrote:
> > On Tuesday May 6, bfields@fieldses.org wrote:
> > > On Tue, May 06, 2008 at 10:35:46AM +1000, Neil Brown wrote:
> > > > 
> > > > To fix the current bug properly, reconnect_path still needs to bypass
> > > > normal permission checks even when subtree_check is in effect, so it
> > > > can be sure of getting read permission on the parent directory.
> > > 
> > > OK, but why not just forget the subtree_check case?  It would be just
> > > another item on the "reasons not to use subtree_check" list.
> > 
> > I guess so.
> > 
> > > 
> > > If a fix for the subtree checking case were easy (or if someone else had
> > > the time to do a very careful job of it), then fine, but maybe we should
> > > just fix the easy case and leave the subtree checking as is for now.
> > 
> > So is this the proposed fix?  A bit ugly, but I guess it's OK.
> 
> Something like that, yep.  (Frank, can you confirm that this does the
> job for you?)

It didn't apply on 2.6.25.1 due to indentation and context but it was
trivial to do that by hand. It survived my little testprogram so yes
it works.

-- 
Frank

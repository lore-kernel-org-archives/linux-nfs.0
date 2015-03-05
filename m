Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59630 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754977AbbCERCS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2015 12:02:18 -0500
Date: Thu, 5 Mar 2015 12:02:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@sandeen.net>,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150305170217.GC15674@fieldses.org>
References: <20150304020826.GD19439@fieldses.org>
 <20150304155421.GE1627@fieldses.org>
 <20150304220900.GX18360@dastard>
 <20150304222709.GI1627@fieldses.org>
 <20150304224557.GY4251@dastard>
 <54F78BE5.1020608@sandeen.net>
 <20150304225623.GZ4251@dastard>
 <20150305040849.GJ1627@fieldses.org>
 <20150305131731.GA16235@lst.de>
 <20150305150138.GA15674@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150305150138.GA15674@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 05, 2015 at 10:01:38AM -0500, J. Bruce Fields wrote:
> On Thu, Mar 05, 2015 at 02:17:31PM +0100, Christoph Hellwig wrote:
> > On Wed, Mar 04, 2015 at 11:08:49PM -0500, J. Bruce Fields wrote:
> > > Ah-hah:
> > > 
> > > 	static void
> > > 	nfsd4_cb_layout_fail(struct nfs4_layout_stateid *ls)
> > > 	{
> > > 		...
> > > 		nfsd4_cb_layout_fail(ls);
> > > 
> > > That'd do it!
> > > 
> > > Haven't tried to figure out why exactly that's getting called, and why
> > > only rarely.  Some intermittent problem with the callback path, I guess.
> > > 
> > > Anyway, I think that solves most of the mystery....
> > 
> > Ooops, that was a nasty git merge error in the last rebase, see the fix
> > below.
> 
> Thanks!

And with that fix things look good.

I'm still curious why the callbacks are failling.  It's also logging
"nfsd: client 192.168.122.32 failed to respond to layout recall".

I may not get a chance to debug for another week or two.

--b.

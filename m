From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: gfs2/pnfs stall
Date: Wed, 12 May 2010 11:45:09 -0400
Message-ID: <20100512154509.GA5226@fieldses.org>
References: <20100511201541.GA23321@fieldses.org> <1273662210.2884.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Olga Kornievskaia <aglo@citi.umich.edu>
To: Steven Whitehouse <swhiteho@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33746 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755954Ab0ELPpK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 11:45:10 -0400
In-Reply-To: <1273662210.2884.29.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 12, 2010 at 12:03:30PM +0100, Steven Whitehouse wrote:
> Hi,
> 
> On Tue, 2010-05-11 at 16:15 -0400, J. Bruce Fields wrote:
> > Olga ran across the following while running an iozone test (from the
> > Windows pnfs client) to a pnfs/gfs2 server built from 2.6.34-rc5-pnfs
> > commit 1ea22c6e65028535ecb62a4e00cf706fc6446b77.
> > 
> > Any ideas?
> > 
> It might well be the issue which we've been chasing down recently. Bob
> has proposed some patches which I've just pushed into the GFS2 -nmw tree
> this morning (and there is one that was pushed in a little while back
> too).
> 
> We'd need a set of glock dumps to be certain, but it does look as if it
> might be that,

OK.  Would it be useful for us to get you a glock dump or to test the
-nmw tree?  (Looks like the latter is available from:

	  git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-nmw.git

.  I didn't find instructions for the former....)

--b.

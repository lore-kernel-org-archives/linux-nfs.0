From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Sun, 3 Aug 2008 21:56:34 +1000
Message-ID: <18581.40178.976747.769343@notabene.brown>
References: <18578.21997.529551.676627@notabene.brown>
	<1217551230.3719.15.camel@shinybook.infradead.org>
	<76bd70e30807311753m2785c6d3kd82edd1fe8b5f8b7@mail.gmail.com>
	<1217552437.3719.30.camel@shinybook.infradead.org>
	<76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
	<1217597759.3454.356.camel@pmac.infradead.org>
	<1217598976.3454.359.camel@pmac.infradead.org>
	<76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com>
	<1217607571.3454.417.camel@pmac.infradead.org>
	<76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
	<20080802182644.GE30454@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, David Woodhouse <dwmw2@infradead.org>,
	viro@zeniv.linux.org.uk, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:59949 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753531AbYHCL4p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Aug 2008 07:56:45 -0400
In-Reply-To: message from J. Bruce Fields on Saturday August 2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday August 2, bfields@fieldses.org wrote:
> 
> Though really I can't see any great objection to just moving xfs's hack
> up into nfsd.  It may not do everything, but it seems like an
> incremental improvement.

Because it is a hack, and hacks have a tendency to hide deeper
problems, and not be ever get cleaned up and generally to become a
burden to future generations.

However if you do go down that path, can I suggest:

 1/ get rid of the word "hack" throughout the code.  If you think it
    is sensible, make it appear sensible.
 2/ drop the "retry malloc of a smaller size" thing. 
    In fact, you can probably use one of the set of pages that has
    been reserved for the request.  It is very rare that a readdir
    request will be as big as the largest read.
 3/ Make the new way unconditional.  That gives it broader test
    coverage which can only be a good thing.  And what is good for the
    goose is good for the gander... (not that I'm calling anyone a
    goose).


But I still prefer the O_READDIRPLUS approach.

NeilBrown

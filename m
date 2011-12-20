Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:46963 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751460Ab1LTPY2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Dec 2011 10:24:28 -0500
Received: from compute5.internal (compute5.nyi.mail.srv.osa [10.202.2.45])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 6A943205AB
	for <linux-nfs@vger.kernel.org>; Tue, 20 Dec 2011 10:24:28 -0500 (EST)
Message-ID: <1324394664.30259.1.camel@perseus.themaw.net>
Subject: Re: [PATCH] NFSD: Change name of extended attribute containing
 junction
From: Ian Kent <raven@themaw.net>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        fedfs-utils-devel@oss.oracle.com
Date: Tue, 20 Dec 2011 23:24:24 +0800
In-Reply-To: <20111219222630.GC32599@pad.fieldses.org>
References: <20111219193843.30843.56764.stgit@degas.1015granger.net>
	 <20111219215259.GA15613@fieldses.org>
	 <20111219171957.70e13a1b@tlielax.poochiereds.net>
	 <20111219222630.GC32599@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-12-19 at 17:26 -0500, J. Bruce Fields wrote:
> On Mon, Dec 19, 2011 at 05:19:57PM -0500, Jeff Layton wrote:
> > On Mon, 19 Dec 2011 16:52:59 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Mon, Dec 19, 2011 at 02:38:43PM -0500, Chuck Lever wrote:
> > > > As of fedfs-utils-0.8.0, user space stores all NFS junction
> > > > information in a single extended attribute: "trusted.junction.nfs".
> > > 
> > > I suspect the break of backwards-compatibility is fine, but we should
> > > add a note explaining it; would something like this be right?:
> > > 
> > > 	This breaks compatibility with fedfs-utils versions before
> > > 	0.8.0.  As fedfs-utils has not been widely distributed, we don't
> > > 	believe this will affect anyone.
> > > 
> > > (Cc'ing jlayton: does this cause a problem for whatever just went into
> > > Fedora?)
> > > 
> > 
> > Also cc'ing Ian, on whose shoulders I dumped the fedfs work...
> > 
> > That stuff just went into Fedora rawhide, and as everyone knows (or
> > should) -- rawhide eats babies. At this point I don't think there's any
> > need to worry about compatibility issues.
> 
> OK, thanks.
> 
> (Chuck, that's the more important question to me than whether we declare
> done or not: if it's alpha-quality code but somebody nevertheless
> manages to get a working setup out of it, we try to be nice to them and
> not break that.  If it's only been distributed in rawhide, and only a
> little while, chances of that are very small, so fine.)

Yeah, alpha stage development shouldn't be constrained by backward
compatibly concerns. Of course a heads up to users is good too.

Ian



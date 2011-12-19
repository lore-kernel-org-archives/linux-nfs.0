Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2471 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159Ab1LSWUZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Dec 2011 17:20:25 -0500
Date: Mon, 19 Dec 2011 17:19:57 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org, fedfs-utils-devel@oss.oracle.com,
        raven@themaw.net
Subject: Re: [PATCH] NFSD: Change name of extended attribute containing
 junction
Message-ID: <20111219171957.70e13a1b@tlielax.poochiereds.net>
In-Reply-To: <20111219215259.GA15613@fieldses.org>
References: <20111219193843.30843.56764.stgit@degas.1015granger.net>
	<20111219215259.GA15613@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 19 Dec 2011 16:52:59 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Dec 19, 2011 at 02:38:43PM -0500, Chuck Lever wrote:
> > As of fedfs-utils-0.8.0, user space stores all NFS junction
> > information in a single extended attribute: "trusted.junction.nfs".
> 
> I suspect the break of backwards-compatibility is fine, but we should
> add a note explaining it; would something like this be right?:
> 
> 	This breaks compatibility with fedfs-utils versions before
> 	0.8.0.  As fedfs-utils has not been widely distributed, we don't
> 	believe this will affect anyone.
> 
> (Cc'ing jlayton: does this cause a problem for whatever just went into
> Fedora?)
> 

Also cc'ing Ian, on whose shoulders I dumped the fedfs work...

That stuff just went into Fedora rawhide, and as everyone knows (or
should) -- rawhide eats babies. At this point I don't think there's any
need to worry about compatibility issues.

-- 
Jeff Layton <jlayton@redhat.com>

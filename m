From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFSD: Fix a bug in the NFSv4 'supported attrs' mandatory
 attribute
Date: Mon, 31 Aug 2009 18:21:53 -0400
Message-ID: <1251757313.25048.12.camel@heimdal.trondhjem.org>
References: <1251746171.25048.1.camel@heimdal.trondhjem.org>
	 <20090831220324.GC5718@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15560 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672AbZHaWWY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2009 18:22:24 -0400
In-Reply-To: <20090831220324.GC5718@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-31 at 18:03 -0400, J. Bruce Fields wrote:
> On Mon, Aug 31, 2009 at 03:16:11PM -0400, Trond Myklebust wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > The fact that the filesystem is present does _not_ imply that the
> > fs_locations attribute should be marked as "unsupported".
> 
> Yes, but the fact that the filesystem is present also does not imply
> that exp->ex_fslocs.locations is NULL.  So I'm confused by your
> characterization of the existing code.
> 
> If you want to do this, you probably also want to turn off the previous
> exfslocs.locations check in the same function.  Otherwise we claim
> support for the attribute but then never actually return it.

...why is that a problem? Clients that conform to RFC3530 are perfectly
capable of dealing with that case. The point is that if you say "I don't
support this attribute", then the client will _never_ be allowed to
check it.

IOW: if you later decide to add replica information to the /etc/exports
file, then none of the existing clients will be able to check that
information.

Furthermore, you are basically promising the clients that you will never
return NFS4ERR_MOVED on that volume, since you're telling them that you
don't support fs_locations on it.
So you can't ever migrate it...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

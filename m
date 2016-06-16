Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59202 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754207AbcFPN15 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jun 2016 09:27:57 -0400
Date: Thu, 16 Jun 2016 09:27:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andrew Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/3] Deal with lost delegations and EKEYEXPIRED
Message-ID: <20160616132755.GA15546@fieldses.org>
References: <1466009529-3421-1-git-send-email-aweits@rit.edu>
 <1466077747.3079.0.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1466077747.3079.0.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 16, 2016 at 07:49:07AM -0400, Jeff Layton wrote:
> On Wed, 2016-06-15 at 12:52 -0400, Andrew Elble wrote:
> > The majority of our lost delegation problems come from the inability
> > to return the delegations when the credentials that obtained them
> > have expired (conundrum mentioned in RFC 5661 18.35.3)
> > 
> > ObMemoryJog:
> > 
> > http://www.spinics.net/lists/linux-nfs/msg56230.html
> > 
> > v3: removal of OP_IS_PUTFH_LIKE checks
> >     added clarification of addressing the conundrum
> > 
> > Andrew Elble (3):
> >   nfs/nfsd: Move useful bitfield ops to a commonly accessible place
> >   nfsd: allow mach_creds_match to be used more broadly
> >   nfsd: implement machine credential support for some operations
> > 
> >  fs/nfsd/export.c        | 10 ++++++++++
> >  fs/nfsd/nfs4proc.c      | 39 +++++++++++++++++++++++++++++++++++++
> >  fs/nfsd/nfs4state.c     | 32 ++++++++++++++++++++++++-------
> >  fs/nfsd/nfs4xdr.c       | 51 ++++++++++++++++++++++-----------------
> > ----------
> >  fs/nfsd/nfsd.h          |  5 +++++
> >  fs/nfsd/state.h         |  1 +
> >  fs/nfsd/xdr4.h          |  5 +++++
> >  include/linux/nfs4.h    | 11 +++++++++++
> >  include/linux/nfs_xdr.h | 11 -----------
> >  9 files changed, 119 insertions(+), 46 deletions(-)
> > 
> 
> All look good to me.
> 
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Thanks!--b.

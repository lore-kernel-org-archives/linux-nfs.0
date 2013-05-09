Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27863 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284Ab3EIUgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 May 2013 16:36:50 -0400
Date: Thu, 9 May 2013 16:36:15 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Vyacheslav Dubeyko <slava@dubeyko.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Hin-Tak Leung <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/5] nfsd + hfsplus: introduce generalized version of
 NFSv4 ACLs <-> POSIX ACLs mapping algorithms
Message-ID: <20130509203614.GE18541@pad.fieldses.org>
References: <1368117430.5695.30.camel@slavad-ubuntu-12.04>
 <1368118877.3282.104.camel@leira.trondhjem.org>
 <9841F318-DA62-4ACF-AA33-0474DBC2B107@dubeyko.com>
 <20130509181647.GA18541@pad.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130509181647.GA18541@pad.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 09, 2013 at 02:16:47PM -0400, J. Bruce Fields wrote:
> On Thu, May 09, 2013 at 09:34:50PM +0400, Vyacheslav Dubeyko wrote:
> > So, we need to map NFSv4 ACLs <-> POSIX ACLs in hfsplus for the case
> > of using POSIX ACLs model. I think that to have such mapping is better
> > than to have nothing.
> 
> So, in the "better than nothing" spirit, I'll take a look at these, but
> I would still rather we get the richacl stuff done....

It's a lot of code so I didn't give it a detailed review.  A couple
things that jump out at me:

The interface here consists of four operation arrays with a total of 30
functions between them.  It seems terribly verbose.  In some cases
you're compensating for that by writing macros to generate the ops.

Is there some less complicated way to do this?

Maybe just write two functions that do the NFSv4<->OSX translation, then
use the existing NFSv4<->POSIX translation unchanged?  It might be a
little less efficient, but easier to understand, I think.

Second:

Note that the existing NFSv4->POSIX mapping is meant to choose the most
permissive ACL that is no more permissive than the given NFSv4 ACL.
This is because we assume it is safer to deny access that was meant to
be allowed than to allow access that was meant to be denied.

You're using the mapping on *getting* an ACL, not on setting it, so I
think you want the reverse: it's safer to claim you're allowing access
that you're not, then to claim you're denying access that you're
actually allowing.

On a quick skim I don't think you're taking that into account.

Finally:

Really, I still think this effort would be better spent working on rich
acls.

--b.

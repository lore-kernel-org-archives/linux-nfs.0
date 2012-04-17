Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221Ab2DQOUJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 10:20:09 -0400
Date: Tue, 17 Apr 2012 10:20:35 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach@exagrid.com" <pstaubach@exagrid.com>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120417102035.2236e553@corrin.poochiereds.net>
In-Reply-To: <1334671473.2963.27.camel@lade.trondhjem.org.localdomain>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<4F8C3036.2030702@itwm.fraunhofer.de>
	<20120416134642.1754cd3e@corrin.poochiereds.net>
	<1334604785.2879.23.camel@lade.trondhjem.org>
	<20120416154322.0d95e435@corrin.poochiereds.net>
	<1334607906.2879.36.camel@lade.trondhjem.org>
	<20120416190548.2463d1d0@corrin.poochiereds.net>
	<87sjg2o62z.fsf@tucsk.pomaz.szeredi.hu>
	<20120417093222.2ff5e1bd@corrin.poochiereds.net>
	<1334671473.2963.27.camel@lade.trondhjem.org.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 17 Apr 2012 14:04:34 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2012-04-17 at 09:32 -0400, Jeff Layton wrote:
> > On Tue, 17 Apr 2012 15:12:20 +0200
> > Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > To do that would require protocol support that we simply don't have. We
> > don't have a way to (for instance) say via NFS "give me the attributes
> > for this filename". Well, at least not for NFSv3...
> 
> What's wrong with LOOKUP?
> 

Some of this is due to my decision to use fstatat as an example, but we
should bear in mind that I've just been using that as an example. We'll
eventually have to do something similar for all path based syscalls in
order to fix tihs comprehensively.

While it may be possible to handle stat type calls atomically with a
simple LOOKUP call, other operations may require more than one round
trip. Consider chmod(), for instance...

> > With v4 you could theoretically construct a compound that does that,
> > but you'd have to assume that the server won't release the reference to
> > the inode midway through the compound. That's a reasonably safe
> > assumption.
> 
> Actually, NFSv4 is the one that has the problem: there are no atomicity
> guarantees within compounds, so you could theoretically get an ESTALE in
> the GETATTR part of our lookup compound.
> 

Well, it's possible, but it seems pathological to me for a server to do
that...

Bruce and I were discussing this the other day. It would be good to add
something like this to the RFCs:

"On a PUTFH, a server SHOULD hold a reference to the filehandle such
that it does not go stale over the life of the compound."

...or something along those lines. That's a different matter though and
not directly related to this. :)

-- 
Jeff Layton <jlayton@redhat.com>

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54345 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639Ab2DQPp6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 11:45:58 -0400
Date: Tue, 17 Apr 2012 11:45:49 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
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
Message-ID: <20120417154549.GA27426@fieldses.org>
References: <4F8C3036.2030702@itwm.fraunhofer.de>
 <20120416134642.1754cd3e@corrin.poochiereds.net>
 <1334604785.2879.23.camel@lade.trondhjem.org>
 <20120416154322.0d95e435@corrin.poochiereds.net>
 <1334607906.2879.36.camel@lade.trondhjem.org>
 <20120416190548.2463d1d0@corrin.poochiereds.net>
 <87sjg2o62z.fsf@tucsk.pomaz.szeredi.hu>
 <20120417093222.2ff5e1bd@corrin.poochiereds.net>
 <1334671473.2963.27.camel@lade.trondhjem.org.localdomain>
 <20120417102035.2236e553@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120417102035.2236e553@corrin.poochiereds.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2012 at 10:20:35AM -0400, Jeff Layton wrote:
> Well, it's possible, but it seems pathological to me for a server to do
> that...
> 
> Bruce and I were discussing this the other day. It would be good to add
> something like this to the RFCs:
> 
> "On a PUTFH, a server SHOULD hold a reference to the filehandle such

For "filehandle" I'd specify "current and saved filehandle".

> that it does not go stale over the life of the compound."

And that's *much* less of a burden on the server than requiring that the
compound execute atomically.

> ...or something along those lines. That's a different matter though and
> not directly related to this. :)

Yes.

--b.

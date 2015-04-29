Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43659 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423038AbbD2Rez (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2015 13:34:55 -0400
Date: Wed, 29 Apr 2015 13:34:54 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH, RFC] backchannel overflows
Message-ID: <20150429173454.GA23284@fieldses.org>
References: <20150428202157.GA23972@infradead.org>
 <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
 <20150429151404.GA12936@infradead.org>
 <CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 11:24:02AM -0400, Trond Myklebust wrote:
> On Wed, Apr 29, 2015 at 11:14 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > On Wed, Apr 29, 2015 at 10:55:10AM -0400, Chuck Lever wrote:
> >>
> >> On Apr 28, 2015, at 4:21 PM, Christoph Hellwig <hch@infradead.org> wrote:
> >>
> >> > Currently the client will just crap out if a CB_NULL comes in at the
> >> > same time as a slot controlled CB_COMPOUND that includes a CB_SEQUENCE.
> >>
> >> Under what circumstances does the server send a CB_NULL while a CB_COMPOUND
> >> is in flight?
> >
> > When a client is under heavy loads from fsx or aio-stress, and we lose
> > the connection (nfsd4_conn_lost is called) while doing heavy recalls.
> >
> > xfstests against a server offering pnfs layouts for which the client
> > can't reach the storage devices is an easy reproducer.
> 
> Why does it need to do this? If the client has sent the
> BIND_CONN_TO_SESSION (which I believe that knfsd asks for), then the
> server knows that this is a bi-directional connection.
> The difference between NFSv4 and NFSv4.1 is that the CB_NULL should
> almost always be redundant, because the client initiates the
> connection and it explicitly tells the server whether or not it is to
> be used for the callback channel.
> 
> The CB_NULL should always be redundant.

I'd be fine with suppressing it.  I think I actually intended to but
screwed it up.  (Chuck or somebody convinced me the
NFSD4_CB_UP/UNKNOWN/DOWN logic is totally broken but I never got around
to fixing it.)

--b.

From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Union mounts, NFS, and locking
Date: Wed, 15 Jul 2009 13:27:59 -0400
Message-ID: <20090715172758.GA13893@fieldses.org>
References: <20090714201940.GF27582@shell> <200907142036.n6EKaexe017464@agora.fsl.cs.sunysb.edu> <20090714220515.GH27582@shell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jan Blunck <jblunck@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Valerie Aurora <vaurora@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48180 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755627AbZGOR2Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jul 2009 13:28:16 -0400
In-Reply-To: <20090714220515.GH27582@shell>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2009 at 06:05:16PM -0400, Valerie Aurora wrote:
> On Tue, Jul 14, 2009 at 04:36:40PM -0400, Erez Zadok wrote:
> > In message <20090714201940.GF27582@shell>, Valerie Aurora writes:
> >
> > > Okay, so my best idea for a solution is to introduce a new NFS mount
> > > option that means the server promises that the exported file system is
> > > read-only (using superblock read-only count scheme locally).  E.g.:

Language nitpick: the term "read-only" is confusing.  Files
(/proc/mounts) and filesystems (nfs) that are "read-only" can still
change.

I'd be happier with "unchanging" or "constant" or "static".

> > 
> > How would the server be able to guarantee that?  Are you planning to change
> > the protocol or implementation somehow?  Are you assuming that the server
> > will be running linux w/ special r/o sb support?  If so, it won't work on
> > other platforms (NFS is supposed to be interoperable in principle :-)
> > 
> > Without a protocol change, such an option (if I understood you), is at best
> > a server promise to "behave nice."
> 
> Yeah, it's just a promise, one that the NFS server shouldn't make if
> it can't implement it.  The client's sole responsibility is to fail
> gracefully if the server breaks its promise.
> 
> The "protocol change" can probably be limited to a new NFS mount
> option and the error returned if the server can't implement this mount
> option.

The mount options aren't really in the protocol--so it'd probably take
the form of a filesystem-granularity attribute that the client could
query (and then fail the mount if the client didn't like the answer).

But even then: the fact is that someone will want to update the
filesystem some day.  And there's no way to force every client
administrator to remount.  So we'd have to decide how to handle that
case.

--b.

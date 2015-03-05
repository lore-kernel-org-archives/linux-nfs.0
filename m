Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59788 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757998AbbCEUdu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2015 15:33:50 -0500
Date: Thu, 5 Mar 2015 15:33:50 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs(5): Update close-to-open discussion in DATA AND
 METADATA COHERENCY
Message-ID: <20150305203350.GA17297@fieldses.org>
References: <20150305155511.26051.93398.stgit@manet.1015granger.net>
 <20150305184238.GD15674@fieldses.org>
 <CAHQdGtSrJS6XEegy7COxBijMKg5UTMa8nCopfFnWGrF2FaxXPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtSrJS6XEegy7COxBijMKg5UTMa8nCopfFnWGrF2FaxXPA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 05, 2015 at 03:18:00PM -0500, Trond Myklebust wrote:
> On Thu, Mar 5, 2015 at 1:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Thu, Mar 05, 2015 at 11:06:37AM -0500, Chuck Lever wrote:
> >> The discussion of close-to-open describes the GETATTR and data flush
> >> behavior implemented on the Linux client, but does not describe what
> >> happens between open() and close(). The lack of strict cache
> >> coherency surprises users who expect single-system behavior
> >> similar to local file systems.
> >>
> >> An explicit description of this behavior is inserted.  Additional
> >> clarifications are made of the surrounding text.
> >>
> >> Text contributed by Trond, Bruce, Chuck, and Chris Perl.
> >>
> >> Link: http://marc.info/?l=linux-nfs&m=142472673425307&w=2
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> Hi-
> >>
> >> TBH I'm more concerned about nfs(5) than I am about the antique NFS
> >> FAQ. Besides, my sf.net login expired long ago, after I retired from
> >> FAQ maintenance.
> >
> > If someone wanted to just copy the whole thing over to the linux-nfs.org
> > wiki, I'd support that.
> >
> >> Thus I'm proposing this change to nfs(5). Then I'd like to suggest
> >> eventually replacing the bulk of FAQ A8 with a pointer to the DATA
> >> AND METADATA COHERENCE section of nfs(5).
> >
> > Moving it to the man pages sounds fine to me too, though.
> >
> >> Comments?
> >
> > We're leading with the mechanism (flushing and attribute checking),
> > which I think encourages people to reason starting from the
> > implementation.  We know that's difficult.
> >
> > I'd rather lead with a conservative black-box explanation of what
> > applications can and cannot depend on.
> >
> 
> This should be the case here.  Exactly what are we saying that you
> believe goes beyond the close-to-open caching model?

Nothing.  I'm not claiming the text is incorrect.  I would just prefer
that we begin by describing the behavior from the point of view of a
user of the filesystem interface, rather than from the point of view of
the implementation.

Statements like

	When an application opens a file stored on an NFS version 3
	server, the NFS client checks that the file exists on the server
	and is permitted to the opener by sending a GETATTR or ACCESS
	request.  The NFS client sends these requests regardless of the
	freshness of the file's cached attributes.

describe the implementation.

A block-box explanation of what applications can and cannot depend on
might consist of statements of the form:

	Access from multiple processes on the same client provides the
	same guarantees as on local filesystems.

	Access from multiple clients will provide the same guarantees as
	long as no client's open for write overlaps any other open from
	another client.

	If a client does open a file for read while another holds it
	open for write, results of that client's reads are undefined.

Etc.

--b.

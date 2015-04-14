Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34586 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753696AbbDNS3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Apr 2015 14:29:07 -0400
Date: Tue, 14 Apr 2015 14:29:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Zach Brown <zab@redhat.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org
Subject: Re: [PATCH RFC 1/3] vfs: add copy_file_range syscall and vfs helper
Message-ID: <20150414182906.GB2080@fieldses.org>
References: <1428703236-24735-1-git-send-email-zab@redhat.com>
 <1428703236-24735-2-git-send-email-zab@redhat.com>
 <CAHQdGtSwSf0j6ge7rCue48bZ08212Ny2Crz9WMadSno11N8z_g@mail.gmail.com>
 <20150411000208.GA20949@lenny.home.zabbo.net>
 <CAHQdGtSaaPHbvtBM3yVGtAFpEAP8ZquYvErknq_rCoCCK+W2bA@mail.gmail.com>
 <20150411090402.67d22d02@tlielax.poochiereds.net>
 <20150414165344.GA21421@infradead.org>
 <552D4B5D.3090904@Netapp.com>
 <20150414181911.GA2080@fieldses.org>
 <20150414182241.GB23129@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150414182241.GB23129@lenny.home.zabbo.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 14, 2015 at 11:22:41AM -0700, Zach Brown wrote:
> On Tue, Apr 14, 2015 at 02:19:11PM -0400, J. Bruce Fields wrote:
> > On Tue, Apr 14, 2015 at 01:16:13PM -0400, Anna Schumaker wrote:
> > > On 04/14/2015 12:53 PM, Christoph Hellwig wrote:
> > > > On Sat, Apr 11, 2015 at 09:04:02AM -0400, Jeff Layton wrote:
> > > >> Yuck! How the heck do you clean up the mess if that happens? I
> > > >> guess you're just stuck redoing the copy with normal READ/WRITE?
> > > >>
> > > >> Maybe we need to have the interface return a hard error in that
> > > >> case and not try to give back any sort of offset?
> > > > 
> > > > The NFSv4.2 COPY interface is a train wreck.  At least for Linux I'd
> > > > expect us to simply ignore it and only implement my new CLONE
> > > > operation with sane semantics.  That is unless someone can show some
> > > > real life use case for the inter server copy, in which case we'll
> > > > have to deal with that mess.  But getting that one right at the VFS
> > > > level will be a nightmare anyway.
> > > > 
> > > > Make this a vote from me to not support partial copies and just
> > > > return and error in that case.
> > > 
> > > Agreed.  Looking at the v4.2 spec, COPY does take ca_consecutive and a
> > > ca_synchronous flags that let the client state if the copy should be
> > > done consecutively or synchronously.  I expected to always set
> > > consecutive to "true" for the Linux client.
> > 
> > That's supposed to mean results are well-defined in the partial-copy
> > case, but I think Christoph's suggesting eliminating the partial-copy
> > case entirely?
> > 
> > Which would be fine with me.
> > 
> > It might actually have been me advocating for partial copies.  But that
> > was only because a partial-copy-handling-loop seemed simpler to me than
> > progress callbacks if we were going to support long-running copies.
> > 
> > I'm happy enough not to have it at all.
> 
> Ah, OK, that's great news.
> 
> I thought at one point we were worried about very long running RPCs on
> the server.  Are we not worried about that now?
> 
> Is the client expected to cut the work up into arbitrarily managable
> chunks?  Is the server expected to fail COPY/CLONE requests that it
> thinks would take way too long?  Something else?

Christoph is proposing a CLONE rpc that's required to be atomic:

	https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-35#section-15.13
	"The CLONE operation is atomic, that is either all changes or no
	changes are seen by the client or other clients."

So that couldn't be really long-running (or the server is nuts).

So that'd mean Anna would rip out the server-side copy loop and we'd
initially just support btrfs or whatever.

I mean the server-side copy loop may also be useful but I'm all for
wiring up the obvious case first.

--b.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34577 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753202AbbDNSTM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Apr 2015 14:19:12 -0400
Date: Tue, 14 Apr 2015 14:19:11 -0400
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Zach Brown <zab@redhat.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org
Subject: Re: [PATCH RFC 1/3] vfs: add copy_file_range syscall and vfs helper
Message-ID: <20150414181911.GA2080@fieldses.org>
References: <1428703236-24735-1-git-send-email-zab@redhat.com>
 <1428703236-24735-2-git-send-email-zab@redhat.com>
 <CAHQdGtSwSf0j6ge7rCue48bZ08212Ny2Crz9WMadSno11N8z_g@mail.gmail.com>
 <20150411000208.GA20949@lenny.home.zabbo.net>
 <CAHQdGtSaaPHbvtBM3yVGtAFpEAP8ZquYvErknq_rCoCCK+W2bA@mail.gmail.com>
 <20150411090402.67d22d02@tlielax.poochiereds.net>
 <20150414165344.GA21421@infradead.org>
 <552D4B5D.3090904@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <552D4B5D.3090904@Netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 14, 2015 at 01:16:13PM -0400, Anna Schumaker wrote:
> On 04/14/2015 12:53 PM, Christoph Hellwig wrote:
> > On Sat, Apr 11, 2015 at 09:04:02AM -0400, Jeff Layton wrote:
> >> Yuck! How the heck do you clean up the mess if that happens? I
> >> guess you're just stuck redoing the copy with normal READ/WRITE?
> >>
> >> Maybe we need to have the interface return a hard error in that
> >> case and not try to give back any sort of offset?
> > 
> > The NFSv4.2 COPY interface is a train wreck.  At least for Linux I'd
> > expect us to simply ignore it and only implement my new CLONE
> > operation with sane semantics.  That is unless someone can show some
> > real life use case for the inter server copy, in which case we'll
> > have to deal with that mess.  But getting that one right at the VFS
> > level will be a nightmare anyway.
> > 
> > Make this a vote from me to not support partial copies and just
> > return and error in that case.
> 
> Agreed.  Looking at the v4.2 spec, COPY does take ca_consecutive and a
> ca_synchronous flags that let the client state if the copy should be
> done consecutively or synchronously.  I expected to always set
> consecutive to "true" for the Linux client.

That's supposed to mean results are well-defined in the partial-copy
case, but I think Christoph's suggesting eliminating the partial-copy
case entirely?

Which would be fine with me.

It might actually have been me advocating for partial copies.  But that
was only because a partial-copy-handling-loop seemed simpler to me than
progress callbacks if we were going to support long-running copies.

I'm happy enough not to have it at all.

--b.

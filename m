Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47187 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755942AbbDNQ6G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2015 12:58:06 -0400
Date: Tue, 14 Apr 2015 09:58:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Zach Brown <zab@redhat.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-scsi@vger.kernel.org
Subject: Re: [PATCH RFC 1/3] vfs: add copy_file_range syscall and vfs helper
Message-ID: <20150414165803.GA4739@infradead.org>
References: <1428703236-24735-1-git-send-email-zab@redhat.com>
 <1428703236-24735-2-git-send-email-zab@redhat.com>
 <CAHQdGtSwSf0j6ge7rCue48bZ08212Ny2Crz9WMadSno11N8z_g@mail.gmail.com>
 <20150411000208.GA20949@lenny.home.zabbo.net>
 <CAHQdGtSaaPHbvtBM3yVGtAFpEAP8ZquYvErknq_rCoCCK+W2bA@mail.gmail.com>
 <20150411090402.67d22d02@tlielax.poochiereds.net>
 <20150414165344.GA21421@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150414165344.GA21421@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 14, 2015 at 09:53:44AM -0700, Christoph Hellwig wrote:
> On Sat, Apr 11, 2015 at 09:04:02AM -0400, Jeff Layton wrote:
> > Yuck! How the heck do you clean up the mess if that happens? I guess
> > you're just stuck redoing the copy with normal READ/WRITE?
> > 
> > Maybe we need to have the interface return a hard error in that
> > case and not try to give back any sort of offset?
> 
> The NFSv4.2 COPY interface is a train wreck.  At least for Linux I'd
> expect us to simply ignore it and only implement my new CLONE operation
> with sane semantics.  That is unless someone can show some real life
> use case for the inter server copy, in which case we'll have to deal
> with that mess.  But getting that one right at the VFS level will
> be a nightmare anyway.

Btw, in case someone cares about the NFS CLONE implementation here is
my prototype based on Anna's older COPY prototype.  It's simple enough that
it might be worth adding to the copy_file_range patch set.

http://git.infradead.org/users/hch/pnfs.git/shortlog/refs/heads/clone

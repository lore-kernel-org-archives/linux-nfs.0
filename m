Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:45522 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969AbaG2LmO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 07:42:14 -0400
Received: by mail-qa0-f52.google.com with SMTP id j15so9086151qaq.25
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 04:42:13 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 29 Jul 2014 07:42:09 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/40] nfsd: Add locking to protect the state owner
 lists
Message-ID: <20140729074209.122238bd@f20.localdomain>
In-Reply-To: <20140727134218.GA26868@infradead.org>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
 <1405954972-28904-9-git-send-email-jlayton@primarydata.com>
 <20140727134218.GA26868@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 27 Jul 2014 06:42:18 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Jul 21, 2014 at 11:02:20AM -0400, Jeff Layton wrote:
> > Change to using the clp->cl_lock for this. For now, there's a lot of
> > cl_lock thrashing, but in later patches we'll eliminate that and close
> > the potential races that can occur when releasing the cl_lock while
> > walking the lists. For now, the client_mutex prevents those races.
> 
> I'll have to look at those later patches, but in general I'd prefer
> not to have an intermediate stage like this.  Maybe just merge
> the later cleanup in, maybe do some of the required cleanups before
> even adding the new locking.
> 

Thanks for the comments so far! FWIW, this set of patches needed to be
respun anyway to deal with the nfs4_file hashing changes.

I've incorporated most of your comments into the respun set, and I'll
repost it once I get some confirmation from Bruce about the latest
set of delegation patches that precede it.

The one thing I didn't address is your comment above. Adding this
locking is hairy enough that I think it's warranted to do it with an
intermediate step like this.

-- 
Jeff Layton <jlayton@primarydata.com>

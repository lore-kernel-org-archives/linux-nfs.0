Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f68.google.com ([209.85.216.68]:50471 "EHLO
	mail-qa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbaGJLty (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 07:49:54 -0400
Received: by mail-qa0-f68.google.com with SMTP id hw13so990130qab.11
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 04:49:53 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 07:49:52 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 012/100] nfsd: remove nfs4_file_put_fd
Message-ID: <20140710074952.20e97f70@tlielax.poochiereds.net>
In-Reply-To: <20140710080336.GB6226@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-13-git-send-email-jlayton@primarydata.com>
	<20140710080336.GB6226@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 01:03:36 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Jul 08, 2014 at 02:03:00PM -0400, Jeff Layton wrote:
> > ...and replace it with a simple swap call.
> 
> While trying to understand this code I'm failing to grasp the point
> of the fi_access counters.  Why can't we simply grab a reference to
> file everytime we increment fi_access, and simply drop it evertime we
> decrement it?
> 

I'm not sure I understand what you're suggesting here. Can you
elaborate?

AFAIU, the fi_access counters tell us when we're able to zero out the
fi_fds slot. fput returns void so we don't have a way to know whether
we're putting the last reference to a file or not. Without that,
find_*_file become quite problematic -- how would we know whether the
pointers they return are still good?

> Note that the comment explaining fi_access also seems wrong, as it
> suggest contributing 0-4 to the counts, but at best we increment each
> one by 1 in a single operation.
> 

Right, we only increment by one for each operation, but open stateids
can be upgraded and downgraded. If we do:

OPEN for NFS4_SHARE_ACCESS_READ
OPEN for NFS4_SHARE_ACCESS_WRITE
OPEN for NFS4_SHARE_ACCESS_BOTH

...then we will have incremented the fi_access counts by a total of 4.

The big pain in the ass with this code is explained in the comment over
bmap_to_share_mode. We have to keep track of what share bits have been
previously used in order to comply with the RFC, so you can easily end
up with "extra" references.

> Also as you touch this area big time:  I think fi_fds should be renamed
> to fi_fils or similar as we point to file structures and not fds.

No objection to the renaming, I'll see if I can work that in on the
next respin.

-- 
Jeff Layton <jlayton@primarydata.com>

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43945 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003Ab1IZOKu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 10:10:50 -0400
Date: Mon, 26 Sep 2011 10:10:27 -0400
To: "Stefan (metze) Metzmacher" <metze@samba.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-fsdevel@vger.kernel.org,
        Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: breaking leases on metadata changes
Message-ID: <20110926141027.GB16044@fieldses.org>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
 <4E7E2314.6000101@samba.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E7E2314.6000101@samba.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Sep 24, 2011 at 08:36:04PM +0200, Stefan (metze) Metzmacher wrote:
> Hi Bruce,
> 
> > So there's this longstanding problem that read leases should really be
> > broken on anything that changes an inode's metadata or any change to the
> > set of links pointing to the inode.
> > 
> > (Cc'ing samba-technical for confirmation of that statement from Samba's
> > point of view....)
> > 
> > So we need mutual exclusion between read leases and link, unlink,
> > rename, etc.
> 
> As far as I know oplocks in SMB only care about content
> and attribute only opens (without the READ/WRITE access bits) doesn't
> break oplocks.

Thanks for looking into this!

Just wandering around msdn (but not having to background to know what
really applies)....  The discussion of "Level 2 Opportunistic Locks"
(which is what I assume you'd be using read leases to implement) at
http://msdn.microsoft.com/en-us/library/aa365713(v=VS.85).aspx says such
an oplock "allows the client to perform read operations and obtain
fileattributes using cached or read-ahead local information".  Which
suggests the oplock also covers attributes?

But I'm probably not reading the right thing.

Is it possible to get any sort of documentation or test results or
confirm the behavior here?

> So changing the modification time of a file should not break the oplock.
> 
> I think link and rename doesn't break oplocks, while unlink would.
> 
> But Samba requirements may change for SMB 2.2 support with directory leases.
> We're currently exploring what the details are.

Well, presumably you'll need to keep supporting the old semantics as
well, regardless of what the new protocol may do.

Anyway, if this is all correct then it sounds like v4 read delegations
and level 2 oplocks may be more different than I'd thought.

In which case I'm probably better off leaving leases alone for now and
defining a new lock type for v4 delegations.  Which could be exposed to
userspace later as well if it turned out to be useful to someone.

That's not to rule out fixes to lease behavior to work better for Samba
if there are any that would make sense.

--b.

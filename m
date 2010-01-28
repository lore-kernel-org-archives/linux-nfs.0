Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36626 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854Ab0A1DTJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jan 2010 22:19:09 -0500
Date: Wed, 27 Jan 2010 22:20:42 -0500
To: Peter Staubach <staubach@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: Don't fail mounts when /etc/netconfig is
	nonexistent
Message-ID: <20100128032042.GB25925@fieldses.org>
References: <4B606CA5.2090607@RedHat.com> <4B60816E.5070108@oracle.com> <4B608905.90708@RedHat.com> <25FE1491-19BF-47AC-8AF2-50D474E67B7D@oracle.com> <4B60BE9E.6020702@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B60BE9E.6020702@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 27, 2010 at 05:30:54PM -0500, Peter Staubach wrote:
> Chuck, it feels as if you are under the impression that this
> is a general purpose deployment that Steve is attempting to
> make to work.  It is not.  It is a very restricted use, ie.
> to install a system.  Thus, the resources available are very
> restricted.  The restriction is not diskspace, per se, but
> the memory footprint which would be required to hold it.

The memory footprint for /etc/netconfig?  What are the numbers here?  Is
this a real problem?  And couldn't you get most of the savings as Chuck
suggests just by removing the comments from /etc/netconfig?

> The suggestion to use the non-TI-RPC version is interesting,
> but has some very negative ramifications.  It would mean that
> we would have to test the TI-RPC flavor and the non-TI-RPC
> flavor.  It would also limit future development to that which
> could be supported via the non-TI-RPC version.  This seems
> unnecessarily limiting.
> 
> While I don't agree with what the anaconda folks have done,
> picking and choosing as they have, they have done so.  I
> think that we should work with them to figure out why they
> have chosen to do so and whether it is valid or not.

OK.

> All that said, what is the technical problem with including
> this support?  There is no possibility that "tcp" or "udp"
> will ever change meaning, at least not in our lifetimes.
> 
> The bottom line is that I could agree, that this isn't the
> most aesthetically pleasing architecture and implementation.
> However, sometimes, the code must run in a non-perfect
> world and hence, compromises must be made.

If we have to have this hack, I also wonder (with Chuck) why the same
hack couldn't be done in libtirpc itself.

--b.

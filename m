Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42276 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488Ab0CYRpK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Mar 2010 13:45:10 -0400
Date: Thu, 25 Mar 2010 13:47:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        Trond Myklebust <trond@netapp.com>
Subject: Re: [PATCH] nfsd: don't break lease while servicing a COMMIT call
	(try #2)
Message-ID: <20100325174707.GA4033@fieldses.org>
References: <1269000388-5543-1-git-send-email-jlayton@redhat.com> <20100322194710.GO5359@fieldses.org> <20100322163340.4b3b285f@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100322163340.4b3b285f@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 22, 2010 at 04:33:40PM -0400, Jeff Layton wrote:
> It looks like nfs_inode_return_delegation always calls nfs_msync_inode
> on any valid delegation before returning it, regardless of the
> delegation type.
> 
> RFC 3530 says this:
> 
>    If the client is granted a read delegation, it is assured that no
>    other client has the ability to write to the file for the duration of
>    the delegation.  If the client is granted a write delegation, the
>    client is assured that no other client has read or write access to
>    the file.
> 
> That doesn't seem to imply that we must flush writes before returning
> either type of delegation. OTOH, maybe it makes sense to treat those as
> cache consistency points since a delegreturn sort of implies that
> another client wants to use the file.
> 
> I'm not quite sure how to interpret the spec here...

If there's that call could cause the client to wait for an actual write
to succeed before returning the delegation, then something's wrong.

Waiting for a commit also seems strange, but probably not incorrect: it
seems fair for the client to expect the server not to treat a commit as
conflicting with a delegation.

--b.

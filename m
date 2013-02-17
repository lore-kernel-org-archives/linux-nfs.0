Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752Ab3BQQA6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Feb 2013 11:00:58 -0500
Date: Sun, 17 Feb 2013 11:00:56 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: report length of the largest hash chain in
 reply cache stats
Message-ID: <20130217160056.GC11441@fieldses.org>
References: <20130215133406.20b1ef09@tlielax.poochiereds.net>
 <1360958672-5692-1-git-send-email-jlayton@redhat.com>
 <299C8DF9-5BFC-4E26-8F7E-CE3415D1140F@oracle.com>
 <20130215172058.29941a54@tlielax.poochiereds.net>
 <20130216133927.GA28824@fieldses.org>
 <BA5562CC-9236-4EC1-BC7A-341387B9F452@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BA5562CC-9236-4EC1-BC7A-341387B9F452@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 16, 2013 at 12:18:18PM -0500, Chuck Lever wrote:
> 
> On Feb 16, 2013, at 8:39 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > With a per-client maximum number of entries, sizing the hash tables
> > should be easier.
> When a server has only one client, should that client be allowed to
> maximize the use of a server's resources (eg, use all of the DRC
> resource the server has available)?

I've been assuming there's rapidly diminishing returns to caching a lot
of replies to a single client.  But that might not be true--I guess a
busy UDP client with a long retry timeout might benefit from a large
cache?

> How about when a server has one active client and multiple quiescent
> clients?

I think there's a chance in that case that one of the quiescent clients
is experiencing a temporary network problem, in which case we may want
to preserve a few entries for them even if the active client's activity
would normally evict them.

--b.

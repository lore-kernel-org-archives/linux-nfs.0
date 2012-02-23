Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38747 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755733Ab2BWOk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Feb 2012 09:40:57 -0500
Date: Thu, 23 Feb 2012 09:40:53 -0500
To: steve <steve@steve-ss.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
Message-ID: <20120223144053.GA25010@fieldses.org>
References: <4F40053A.3090301@steve-ss.com>
 <4F412E2F.9070200@steve-ss.com>
 <4F45E78E.8050501@steve-ss.com>
 <20120223063913.5736a5b1@tlielax.poochiereds.net>
 <4F4628B8.90401@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F4628B8.90401@steve-ss.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 23, 2012 at 12:53:28PM +0100, steve wrote:
> Hi Jeff
> Thanks for the reply. I'm trying to make the files created in a
> share take on group rw.
> 
> The trouble is that I've already tried setting the acl's via
> nfs4_setfacl on the mounted share too (please see details below).
> The acl + appears on the unmounted share and behaves as expected
> even when it is not mounted. The mounted share however ignores the
> acl I've set. I've tried remounting but still no acl is effective.
> My workaround is to scan the folder and change the files to group rw
> every few seconds.

Without looking at your details, apologies:

First, if you want an ace on a directory to be inherited by files and
directories created under that directory, make sure you're setting the f
and d flags (see nfs4_getfacl -H).

Second, there's a umask problem: posix acl inheritance overrides the
umask, but nfs4 acl inheritance isn't doing that.  (The client combines
the create mode and the umask and sets both together, there's no way for
the server to even tell what the umask is.)

(We should do something about this if we can: maybe modifying the client
to scan the directory acl for any inheritable aces and leaving out the
umask if they're found?  It has the obvious race, but I seem to recall
we live with that in the v3 case.  Or maybe there's something more
clever, but this comes up every now and then and I can't remember a
better solution.)

--b.

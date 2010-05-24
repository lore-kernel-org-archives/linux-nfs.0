Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:41700 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482Ab0EXQrj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 12:47:39 -0400
Date: Mon, 24 May 2010 17:47:36 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Neil Brown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
Message-ID: <20100524164736.GR31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
 <20100524115903.GP31073@ZenIV.linux.org.uk>
 <20100524155031.GQ31073@ZenIV.linux.org.uk>
 <1274718082.10795.31.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1274718082.10795.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 24, 2010 at 12:21:22PM -0400, Trond Myklebust wrote:
> > Can an nfs4 server e.g. have /x/y being a symlink that resolves to /a/b and
> > allow mounting of both /x/y/c and /a/b/c?  Which path would it return to
> > client that has mounted both, walked to some referral point and called
> > nfs_do_refmount(), triggering nfs4_proc_fs_locations()?
> > 
> > Trond, Neil?
> 
> When mounting /x/y/c in your example above, the NFSv4 protocol requires
> the client itself to resolve the symlink, and then walk down /a/b/c
> (looking up component by component), so it will in practice not see
> anything other than /a/b/c.
> 
> If it walks down to a referral, and then calls nfs_do_refmount, it will
> do the same thing: obtain a path /e/f/g on the new server, and then walk
> down that component by component while resolving any symlinks and/or
> referrals that it crosses in the process.

Ho-hum...  What happens if the same fs is mounted twice on server?  I.e.
have ext2 from /dev/sda1 mounted on /a and /b on server, then on the client
do mount -t nfs foo:/a /tmp/a; mount -t nfs foo:/b /tmp/b.  Which path
would we get from GETATTR with fs_locations requested, if we do it for
/tmp/a/x and /tmp/b/x resp.?  Dentry will be the same, since fsid would
match.

Or would the server refuse to export things that way?

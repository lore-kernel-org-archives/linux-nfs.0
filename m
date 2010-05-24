Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:43799 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755727Ab0EXQVb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 12:21:31 -0400
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Neil Brown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <20100524155031.GQ31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
	 <20100524115903.GP31073@ZenIV.linux.org.uk>
	 <20100524155031.GQ31073@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 24 May 2010 12:21:22 -0400
Message-ID: <1274718082.10795.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-05-24 at 16:50 +0100, Al Viro wrote: 
> On Mon, May 24, 2010 at 12:59:03PM +0100, Al Viro wrote:
> 
> > BTW, here's a question for nfs client folks: is it true that for any two
> > pathnames on _client_ resolving to pairs (mnt1, dentry) and (mnt2, dentry)
> > resp., nfs_devname(mnt1, dentry, ...) and nfs_devname(mnt2, dentry, ...)
> > should yield the strings that do not differ past the ':' (i.e. that the
> > only possible difference is going to be in spelling the server name)?
> 
> Actually, there's a related one: suppose we have two mounts from the same
> server, with the same flags, etc., ending up sharing a dentry on client.
> What will we get from GETATTR asking for fs_locations, in fs_root field?
> 
> Can an nfs4 server e.g. have /x/y being a symlink that resolves to /a/b and
> allow mounting of both /x/y/c and /a/b/c?  Which path would it return to
> client that has mounted both, walked to some referral point and called
> nfs_do_refmount(), triggering nfs4_proc_fs_locations()?
> 
> Trond, Neil?

When mounting /x/y/c in your example above, the NFSv4 protocol requires
the client itself to resolve the symlink, and then walk down /a/b/c
(looking up component by component), so it will in practice not see
anything other than /a/b/c.

If it walks down to a referral, and then calls nfs_do_refmount, it will
do the same thing: obtain a path /e/f/g on the new server, and then walk
down that component by component while resolving any symlinks and/or
referrals that it crosses in the process.

Cheers
  Trond


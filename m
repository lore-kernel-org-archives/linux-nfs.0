Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49766 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757180Ab0EXPui (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 11:50:38 -0400
Date: Mon, 24 May 2010 16:50:31 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
Message-ID: <20100524155031.GQ31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
 <20100524115903.GP31073@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100524115903.GP31073@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 24, 2010 at 12:59:03PM +0100, Al Viro wrote:

> BTW, here's a question for nfs client folks: is it true that for any two
> pathnames on _client_ resolving to pairs (mnt1, dentry) and (mnt2, dentry)
> resp., nfs_devname(mnt1, dentry, ...) and nfs_devname(mnt2, dentry, ...)
> should yield the strings that do not differ past the ':' (i.e. that the
> only possible difference is going to be in spelling the server name)?

Actually, there's a related one: suppose we have two mounts from the same
server, with the same flags, etc., ending up sharing a dentry on client.
What will we get from GETATTR asking for fs_locations, in fs_root field?

Can an nfs4 server e.g. have /x/y being a symlink that resolves to /a/b and
allow mounting of both /x/y/c and /a/b/c?  Which path would it return to
client that has mounted both, walked to some referral point and called
nfs_do_refmount(), triggering nfs4_proc_fs_locations()?

Trond, Neil?

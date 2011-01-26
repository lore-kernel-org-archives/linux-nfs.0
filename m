Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16798 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab1AZUOx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jan 2011 15:14:53 -0500
Subject: Re: 2.6.38-rc2... NFS sillyrename is broken...
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Cc: linux-nfs@vger.kernel.org, Nick Piggin <npiggin@gmail.com>,
        Linux Filesystem Development <linux-fsdevel@vger.kernel.org>
In-Reply-To: <21515.1296030022@jrobl>
References: <1295998215.6867.22.camel@heimdal.trondhjem.org>
	 <21515.1296030022@jrobl>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 26 Jan 2011 15:14:27 -0500
Message-ID: <1296072867.7127.26.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-26 at 17:20 +0900, J. R. Okajima wrote: 
> (CC-ed Nick Piggin)
> 
> Trond Myklebust:
> > Something in the recent VFS churn appears to have broken NFS
> > sillyrename.
> >
> > Currently, when I try to unlink() a file that is being held open by
> > another process, I do indeed see that file getting renamed to
> > a .nfsxxxxxxx file, but when the file is closed, the .nfsxxxxx file
> > sticks around until I unlink() it again.
> >
> > I'll have a look tomorrow at what is going wrong, but I figured I'd ask
> > on the list in case someone has a suspect...
> 
> I noticed this issue yesterday and found the change for removing
> dcache_lock is suspicious.
> By the commit 949854d
> 	2011-01-07 fs: Use rename lock and RCU for multi-step operations
> dentry->d_parent = NULL;
> is added into the beginning of VFS d_kill().
> 
> Later d_kill() calls dentry_iput(), d_op->d_iput() which is
> nfs_dentry_iput() in NFS.
> Then nfs_dentry_iput() calls nfs_complete_unlink(), nfs_call_unlink().
> Here nfs_call_unlink() calls dget_parent() and when the result is NULL,
> it skips the actual unlink. Finally the "silly-renamed" dentry
> remains.

Agreed. That looks like it explains the breakage.

> Can we stop "dentry->d_parent = NULL"
> when (d->flags & DCACHE_NFSFS_RENAMED) is true?

Nick?

The alternative would be to add a callback that can be called after
dentry_iput() if DCACHE_NFSFS_RENAMED is true, and that takes the parent
and (negative) dentry as the arguments.
sillyrename doesn't need the inode as an argument, but it definitely
needs the parent dentry so that it can check for races with
->lookup()...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


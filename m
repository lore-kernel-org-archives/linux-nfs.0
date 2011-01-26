Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mtoichi12.ns.itscom.net ([219.110.2.182]:51913 "EHLO
	mtoichi12.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697Ab1AZIVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jan 2011 03:21:04 -0500
From: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Subject: Re: 2.6.38-rc2... NFS sillyrename is broken...
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Nick Piggin <npiggin@gmail.com>,
        Linux Filesystem Development <linux-fsdevel@vger.kernel.org>
In-Reply-To: <1295998215.6867.22.camel@heimdal.trondhjem.org>
References: <1295998215.6867.22.camel@heimdal.trondhjem.org>
Date: Wed, 26 Jan 2011 17:20:22 +0900
Message-ID: <21515.1296030022@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


(CC-ed Nick Piggin)

Trond Myklebust:
> Something in the recent VFS churn appears to have broken NFS
> sillyrename.
>
> Currently, when I try to unlink() a file that is being held open by
> another process, I do indeed see that file getting renamed to
> a .nfsxxxxxxx file, but when the file is closed, the .nfsxxxxx file
> sticks around until I unlink() it again.
>
> I'll have a look tomorrow at what is going wrong, but I figured I'd ask
> on the list in case someone has a suspect...

I noticed this issue yesterday and found the change for removing
dcache_lock is suspicious.
By the commit 949854d
	2011-01-07 fs: Use rename lock and RCU for multi-step operations
dentry->d_parent = NULL;
is added into the beginning of VFS d_kill().

Later d_kill() calls dentry_iput(), d_op->d_iput() which is
nfs_dentry_iput() in NFS.
Then nfs_dentry_iput() calls nfs_complete_unlink(), nfs_call_unlink().
Here nfs_call_unlink() calls dget_parent() and when the result is NULL,
it skips the actual unlink. Finally the "silly-renamed" dentry
remains.

Can we stop "dentry->d_parent = NULL"
when (d->flags & DCACHE_NFSFS_RENAMED) is true?


J. R. Okajima

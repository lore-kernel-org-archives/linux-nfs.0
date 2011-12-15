Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:36094 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855Ab1LOVdA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2011 16:33:00 -0500
Date: Thu, 15 Dec 2011 21:32:56 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Maxim Uvarov <maxim.uvarov@oracle.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org,
        Trond.Myklebust@netapp.com, john@johnmccutchan.com, rlove@rlove.org,
        eparis@parisplace.org
Subject: Re: [PATCH] NFS/INOTIFY: inotify user when deleting files on nfs
Message-ID: <20111215213256.GS2203@ZenIV.linux.org.uk>
References: <1323903495-4084-1-git-send-email-maxim.uvarov@oracle.com>
 <1323903495-4084-2-git-send-email-maxim.uvarov@oracle.com>
 <20111214232254.GP2203@ZenIV.linux.org.uk>
 <4EEA469E.6070307@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EEA469E.6070307@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 15, 2011 at 11:12:30AM -0800, Maxim Uvarov wrote:

> 1. Original VFS code already has "if NFS", in vfs_unlink(). Because
> of code does not call d_delete() it has to call notification from
> d_delete().
> 
> 2. inotify is done on VFS layer. So logically it has to work on all
> file systems.

You are using a very odd meaning of the word "logically", then.  Note
that inotify does *not* work on NFS, no matter what vfs_unlink() would do.
Simply because files are removed on server, not in VFS.  And server does
not notify clients of such removals.  Ergo, any software that relies on
inotify delivering notifications of files being removed is broken on NFS.
That has nothing whatsoever to the layer in kernel where it's handled;
the information asked for is simply not available to client.  Period.

Incidentally, inotify does not work on a bunch of local filesystems,
starting with procfs.  And won't work, unless you are seriously proposing
to generate events on things like open()/dup2()/etc.  In this case we
might very well have objects appearing and disappearing without ever
having had a dentry.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48790 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013AbcFCDhx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2016 23:37:53 -0400
Date: Fri, 3 Jun 2016 04:37:50 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Subject: Re: NFS/d_splice_alias breakage
Message-ID: <20160603033750.GL14480@ZenIV.linux.org.uk>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 02, 2016 at 06:46:08PM -0400, Oleg Drokin wrote:
> Hello!
> 
>    I just came across a bug (trying to run some Lustre test scripts against NFS, while hunting for another nfsd bug)
>    that seems to be present since at least 2014 that lets users crash nfs client locally.

> >  * Cluster filesystems may call this function with a negative, hashed dentry.
> >  * In that case, we know that the inode will be a regular file, and also this
> >  * will only occur during atomic_open. So we need to check for the dentry
> >  * being already hashed only in the final case.

Comment is long obsolete and should've been removed.  "Cluster filesystem"
in question was GFS2 and it had been dealt with there.  Mea culpa - should've
removed the comment as soon as that was done.

> Removing the BUG_ON headon is not going to work since the d_rehash of old
> is now folded into __d_add and we might not want to move that condition there.

No, it is not.  It really should not be called that way.

> The problem was there at least since 3.10 it appears where the fs/nfs/dir.c code
> was calling d_materialise_unique() that did require the dentry to be unhashed.
> 
> Not sure how this was not hit earlier. The crash looks like this (I added
> a printk to ensure this is what is going on indeed and not some other weird race):

> [   64.489326] Calling into d_splice_alias with hashed dentry, dentry->d_inode (null) inode ffff88010f500c70

Which of the call sites had that been and how does one reproduce that fun?
If you feel that posting a reproducer in the open is a bad idea, just send
it off-list...

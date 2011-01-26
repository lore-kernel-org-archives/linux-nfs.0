Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36523 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754465Ab1AZX7L convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jan 2011 18:59:11 -0500
Subject: Re: 2.6.38-rc2... NFS sillyrename is broken...
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nick Piggin <npiggin@gmail.com>
Cc: "J. R. Okajima" <hooanon05@yahoo.co.jp>, linux-nfs@vger.kernel.org,
        Linux Filesystem Development <linux-fsdevel@vger.kernel.org>
In-Reply-To: <AANLkTik2JJt4vcX8mMJmz+uwJU01vpMwF0UjQ+3QFAtp@mail.gmail.com>
References: <1295998215.6867.22.camel@heimdal.trondhjem.org>
	 <21515.1296030022@jrobl> <1296072867.7127.26.camel@heimdal.trondhjem.org>
	 <1296074585.7127.33.camel@heimdal.trondhjem.org>
	 <AANLkTik2JJt4vcX8mMJmz+uwJU01vpMwF0UjQ+3QFAtp@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 26 Jan 2011 18:59:09 -0500
Message-ID: <1296086349.7127.55.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-01-27 at 10:50 +1100, Nick Piggin wrote: 
> On Thu, Jan 27, 2011 at 7:43 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Wed, 2011-01-26 at 15:14 -0500, Trond Myklebust wrote:
> >> The alternative would be to add a callback that can be called after
> >> dentry_iput() if DCACHE_NFSFS_RENAMED is true, and that takes the parent
> >> and (negative) dentry as the arguments.
> >> sillyrename doesn't need the inode as an argument, but it definitely
> >> needs the parent dentry so that it can check for races with
> >> ->lookup()...
> >
> > The following (compile tested only!) patch illustrates what I mean.
> 
> We could do this. CEPH also want a way to get d_parent in the inode
> unlink path.
> 
> I think I can actually check for dentry->d_count == 0 rather than
> dentry->d_parent == NULL here, and avoid clearing d_parent
> entirely. That might be the better solution for 2.6.38, because other
> code I've missed might be expecting to use d_parent.

I'm not sure I understand. By the time we hit d_kill() we know that
dentry->d_count == 0. The only thing we need here is the ability to
unlink the file if it has been sillyrenamed previously. The reason for
needing the parent dentry is to allow the filesystem to guard against
races with lookup without requiring the vfs to take the
parent->d_inode->i_mutex in the dput() path...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


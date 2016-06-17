Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49684 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbcFQE3S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2016 00:29:18 -0400
Date: Fri, 17 Jun 2016 05:29:14 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, Mailing List <linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        idryomov@gmail.com, sage@redhat.com, zyan@redhat.com
Subject: Re: More parallel atomic_open/d_splice_alias fun with NFS and
 possibly more FSes.
Message-ID: <20160617042914.GD14480@ZenIV.linux.org.uk>
References: <F861E78B-00C3-4F17-A10D-C9FCB81D43B9@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F861E78B-00C3-4F17-A10D-C9FCB81D43B9@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 17, 2016 at 12:09:19AM -0400, Oleg Drokin wrote:

>     So they both do d_drop(), the dentry is now unhashed, and they both
>     dive into nfs_lookup().
>     There eventually they both call
> 
> 	res = d_splice_alias(inode, dentry);
> 
>    And so the first lucky one continues on it's merry way with a hashed dentry,
>    but the other less lucky one ends up calling into d_splice_alias() with
>    dentry that's already hashed and hits the very familiar assertion.
> 
>    I took a brief look into ceph and it looks like a very similar thing
>    might happen there with handle_reply() for two parallel replies calling into
>    ceph_fill_trace() and then splice_alias()->d_splice_alias(), since the
>    unhashed check it does is not under any locks, it's unsafe, so the problem
>    might be more generic than just NFS too.
> 
>    So I wonder how to best fix this? Holding some sort of dentry lock across a call
>    into atomic_open in VFS? We cannot just make d_splice_alias() callers call with
>    inode->i_lock held because dentry might be negative.

Oh, lovely...  So basically the problem is that we violate the "no lookups on
the same name in parallel" rule on those fallbacks from foo_atomic_open() to
foo_lookup().  The thing is, a lot of ->atomic_open() instances have such
fallbacks and I wonder if that's a sign that we need to lift some of that
to fs/namei.c...

Hell knows; alternative is to have that d_drop() followed by d_alloc_parallel()
and feeding that dentry to lookup.  I'll play with that a bit and see what's
better; hopefully I'll have something by tomorrow.

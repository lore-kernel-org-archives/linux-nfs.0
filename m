Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59672 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756934Ab1FVAYA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2011 20:24:00 -0400
Date: Wed, 22 Jun 2011 01:23:59 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [heads-up] mknod() broken on nfs4
Message-ID: <20110622002359.GC11521@ZenIV.linux.org.uk>
References: <20110621235900.GB11521@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110621235900.GB11521@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jun 22, 2011 at 12:59:00AM +0100, Al Viro wrote:
> 	Try mknod(path, 0777, 0); with path leading into nfs4.  It
> leads to call of nfs_open_create(), with nd->intent.open.file being
> uninitialized.  Note that LOOKUP_CREATE is set and so's LOOKUP_EXCL,
> but LOOKUP_OPEN isn't.  So nfs_atomic_lookup() falls through to
> nfs_lookup(), which sees that we are doing exclusive create and just
> does d_instantiate(dentry, NULL) and do nothing else.  And then
> we hit ->create()...
> 
> 	Results are ugly - random errors (often -EINVAL or -ENOENT)
> and possibility of memory corruption if we manage to generate a request
> that won't fail on server.  
> 
> 	The really interesting question is what should we pass in
> NFS_PROTO(dir)->create() in open_flags.  I suspect that you are
> checking the wrong flag there (LOOKUP_CREATE instead of LOOKUP_OPEN),
> but I'm not sure what *should* be passed when LOOKUP_OPEN is not
> there...

Argh...  Alas, it's not that simple.  Even though the code in nfs_open_create()
and nfs4_proc_create() seems to imply that passing NULL as ctx is OK and
expected, in reality that blows up since we end up with NULL cred passed
to nfs4_do_open(), which oopses on attempt to do get_rpccred(NULL) from
nfs4_get_state_owner().

Folks, how is that code supposed to work?  lookup_instantiate_filp() should
*not* be called by vfs_create() triggered by mknod().  And I don't see any
codepath in nfs_open_create() that would not step into that.  ctx == NULL
is the only thing that would skip it and it definitely isn't survivable
by nfs4_proc_create().  Moreover, we need the rpc_cred to come from somewhere
and nfs4_proc_create() needs to get it from us.

BTW, AFAICS fuse will oops in such situation as well...

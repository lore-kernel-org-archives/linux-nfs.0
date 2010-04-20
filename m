Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:59317 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754444Ab0DTNCH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Apr 2010 09:02:07 -0400
Subject: Re: [PATCH] Should we expect close-to-open consistency on
 directories?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100420172238.520eaa89@notabene.brown>
References: <20100420172238.520eaa89@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 20 Apr 2010 09:02:01 -0400
Message-ID: <1271768521.25129.94.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-04-20 at 17:22 +1000, Neil Brown wrote: 
> Hi Trond et al,
> 
> It has come to my attention that NFS directories don't behave consistently
> in terms of cache consistency.
> 
> If, on the client, you have a loop like:
> 
>  while true; do sleep 1; ls -l $dirname ; done
> 
> and then on the server you make changes to the named directory, there are
> some cases where you will see changes promptly and some where you wont.
> 
> In particular, if $dirname is '.' or the name of an NFS mountpoint, then
> changes can be delayed by up to acdirmax.  If it is any other path, i.e. with
> a non-trivial path component that is in the NFS filesystem, then changes
> are seen promptly.
> 
> This seems to me to relate to "close to open" consistency.  Of course with
> directories the 'close' side isn't relevant, but I still think it should be
> that when you open a directory it validates the 'change' attribute on that
> directory over the wire.
> 
> However the Linux VFS never tells NFS when a directory is opened.  The
> current correct behaviour for most directories is achieved through
> d_revalidate == nfs_lookup_revalidate.
> 
> For '.' and mountpoints we need a different approach.  Possibly the VFS could
> be changed to tell the filesystem when such a directory is opened.  However I
> don't feel up to that at the moment.

I agree that mountpoints are problematic in this case, however why isn't
'.' working correctly? Is the FS_REVAL_DOT mechanism broken?

The other thing is that we should definitely expect the VFS to call
nfs_opendir() once it has opened the file.

> An alternative is to do a revalidation in nfs_readdir as below.  i.e. when
> readdir see f_pos == 0, it requests a revalidation of the page cache.
> This has two problems:
> 1/ a seek before the first read would cause the revalidation to be skipped.
>    This can be fixed by putting a similar test in nfs_llseek_dir, or maybe
>    triggering off 'dir_cookie == NULL' rather than 'f_pos == 0'.
> 2/ A normal open/readdir sequence will validate a directory twice, once in the
>    lookup and once in the readdir.  This is probably undesirable, but it is
>    not clear to me how to fix it.
> 
> 
> So: is it reasonable to view the current behaviour as 'wrong'?
>     any suggestions on how to craft a less problematic fix?

nfs_opendir() should fix case 1/, but still has the issue with case 2/.
How about just having it force a revalidation if we see that this is a
mountpoint?

Cheers
  Trond


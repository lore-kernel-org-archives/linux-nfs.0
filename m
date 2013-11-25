Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:46234 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753681Ab3KYO7r convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Nov 2013 09:59:47 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: The return of the hanging "ls"...
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131125155942.0a3e4ca1@notabene.brown>
Date: Mon, 25 Nov 2013 09:59:39 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Message-Id: <A7CF3941-980F-4B96-B473-ECB46375CFCF@oracle.com>
References: <20131125155942.0a3e4ca1@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

On Nov 24, 2013, at 11:59 PM, NeilBrown <neilb@suse.de> wrote:

> 
> Hi Trond,
> I just noticed commit acdc53b2146c7ee67feb1f02f7bc3020126514b8 from 2010
> reverts the effect commit 28c494c5c8d425e15b7b82571e4df6d6bc34594d from Chunk
> in 2007.

I'm wondering if a subsequent commit changed filemap_write_and_wait().

There was some recent clean up that (very likely unintentionally) changed the serialization of some of these VFS utility functions.



> Specifically it removes mutex lock/unlock in nfs_getattr.
> Chuck added them:
> 
> -       /* Flush out writes to the server in order to update c/mtime */
> -       if (S_ISREG(inode->i_mode))
> +       /*
> +        * Flush out writes to the server in order to update c/mtime.
> +        *
> +        * Hold the i_mutex to suspend application writes temporarily;
> +        * this prevents long-running writing applications from blocking
> +        * nfs_wb_nocommit.
> +        */
> +       if (S_ISREG(inode->i_mode)) {
> +               mutex_lock(&inode->i_mutex);
>                nfs_wb_nocommit(inode);
> +               mutex_unlock(&inode->i_mutex);
> +       }
> 
> 
> You removed them.
> 
> -       /*
> -        * Flush out writes to the server in order to update c/mtime.
> -        *
> -        * Hold the i_mutex to suspend application writes temporarily;
> -        * this prevents long-running writing applications from blocking
> -        * nfs_wb_nocommit.
> -        */
> +       /* Flush out writes to the server in order to update c/mtime.  */
>        if (S_ISREG(inode->i_mode)) {
> -               mutex_lock(&inode->i_mutex);
> -               nfs_wb_nocommit(inode);
> -               mutex_unlock(&inode->i_mutex);
> +               err = filemap_write_and_wait(inode->i_mapping);
> +               if (err)
> +                       goto out;
>        }
> 
>        /*
> 
> 
> Do you recall why?
> 
> I noticed because a customer reported exactly the same symptoms the were
> fixed by Chucks patch some years ago.
> 
> 
> The comment on your patch says (in part):
> 
>    Also replace nfs_wb_nocommit() with a
>    call to filemap_write_and_wait(), which doesn't need to hold the
>    inode->i_mutex.
> 
> It is certainly true that filemap_write_and_wait doesn't need to hold the
> mutex, but neither did nfs_wb_nocommit.  The mutex is held to stop "suspend
> application writes temporarily" so no more pages get dirtied until all
> the current dirty pages have been written out.  i.e. to stop
> generic_file_aio_write() from proceeding.
> 
> The particular test that shows the problem is a large write like
>  dd if=/dev/zero of=/mnt/nfs/somefile count=2000000
> then in another window
>  ls -l /mnt/nfs
> 
> the "ls -l" will hang until the "dd" completes.
> 
> Can we put the mutex lock/unlock back please?
> 
> Thanks,
> NeilBrown

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




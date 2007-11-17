From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Cache flushing
Date: Sat, 17 Nov 2007 14:46:25 -0500
Message-ID: <1195328785.6999.5.camel@localhost.localdomain>
References: <1195258291.6039.189.camel@hurina>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItTcf-0003sa-Sp
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 11:46:36 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ItTcl-0003jN-Ba
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 11:46:39 -0800
In-Reply-To: <1195258291.6039.189.camel@hurina>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Sat, 2007-11-17 at 02:11 +0200, Timo Sirainen wrote:
> Solaris and BSDs support flushing attribute cache safely using
> fchown(fd, (uid_t)-1, (gid_t)-1). Could Linux be changed to support this
> as well? If I'm looking at the sources right, this might work
> (completely untested):
> 
> --- inode.c.old 2007-11-16 22:18:46.000000000 +0200
> +++ inode.c     2007-11-16 22:19:44.000000000 +0200
> @@ -322,6 +322,7 @@
>  nfs_setattr(struct dentry *dentry, struct iattr *attr)
>  {
>         struct inode *inode = dentry->d_inode;
> +       struct nfs_inode *nfsi = NFS_I(inode);
>         struct nfs_fattr fattr;
>         int error;
>  
> @@ -334,8 +335,10 @@
>  
>         /* Optimization: if the end result is no change, don't RPC */
>         attr->ia_valid &= NFS_VALID_ATTRS;
> -       if (attr->ia_valid == 0)
> +       if (attr->ia_valid == 0) {
> +               nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
>                 return 0;
> +       }
>  
>         lock_kernel();
>         nfs_begin_data_update(inode);

Why is this needed?

> Another problem I have is that it's difficult to get a file's data cache
> flushed. The only way I found was to successfully fcntl() lock the file.
> This is pretty bad from performance point of view since often I don't
> want/need to lock the file.
> 
> Solaris and BSDs invalidate also a file's data cache when its attribute
> cache is invalidated. It would be nicer if there was a separate way, but
> I'd settle for fchown(fd, (uid_t)-1, (gid_t)-1) invalidating data cache
> as well.
> 
> Actually I did also look at posix_fadvise(fd, 0, 0,
> POSIX_FADVN_DONTNEED). It appears to work, but I'm a bit worried about
> race conditions that causes pages to randomly not get dropped because
> invalidate_mapping_pages() doesn't drop locked pages.

Again, why do you need this level of data cache invalidation? If you
don't want cached i/o, then use O_DIRECT.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


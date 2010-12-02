Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43912 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756450Ab0LBBgm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 20:36:42 -0500
Subject: Re: [PATCH] NFS client has troubles with fileid with bit 31 (or
 bit 63) set
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Frank Filz <ffilzlnx@us.ibm.com>
Cc: NFS List <linux-nfs@vger.kernel.org>, ffilz@us.ibm.com
In-Reply-To: <1291251786.5075.6.camel@KPMH461.ibm.com>
References: <1291251786.5075.6.camel@KPMH461.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 20:36:26 -0500
Message-ID: <1291253786.6609.90.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-01 at 17:03 -0800, Frank Filz wrote:
> 
> 
> I discovered this problem by accident while doing some testing of the
> Ganesha user space server. It was producing garbage fileids that
> happened to have bit 31 set (0x80000000).
> 
> The telldir special test from cthon04 would fail. Investigating, I found
> that it appeared that the getdents() was returning EOVERFLOW. It wasn't
> too hard to track that down to the following code:
> 
> static int fillonedir(void * __buf, const char * name, int namlen, loff_t offset,
>                       u64 ino, unsigned int d_type)
> {
>         struct readdir_callback * buf = (struct readdir_callback *) __buf;
>         struct old_linux_dirent __user * dirent;
>         unsigned long d_ino;
> 
>         if (buf->result)
>                 return -EINVAL;
>         d_ino = ino;
>         if (sizeof(d_ino) < sizeof(ino) && d_ino != ino)
>                 return -EOVERFLOW;
> 
> It took adding some debug code to track the problem down to this
> function:
> 
> u64 nfs_compat_user_ino64(u64 fileid)
> {
>         int ino;
> 
>         if (enable_ino64)
>                 return fileid;
>         ino = fileid;
>         if (sizeof(ino) < sizeof(fileid))
>                 ino ^= fileid >> (sizeof(fileid)-sizeof(ino)) * 8;
>         return ino;
> }
> 
> In trying to reduce a 64 bit fileid to 32 bits, it produces a SIGNED 32
> bit int! When this is passed to fillonedir as a uint64, a negative
> number is sign extended. bit 31 of ino will be set if bit 31 OR bit 63
> (but not both) is set in the fileid.
> 
> Turns out the fix is simple! Change ino to an unsigned int.
> 
> In order to test my fix in an orderly fashion, I used a simple process
> to modify the fileids produced by the kernel server:
> 
> u64 warp_fileid(u64 fileid)
> {
>         return (fileid & 0xffffffff7fffffefLL) | ((fileid & 0x10LL) << 27) | ((fileid &0x80000000LL) >> 27);
> }
> 
> This means that every 16 inode numbers, bit 31 will be flipped,
> producing plenty of problem fileids. The telldir test case fails with
> this hacked kernel server.
> 
> Of course if anyone has a real file system with > 2G inodes, they could
> see the problem for real, but I don't have a big enough file system...
> 
> 
> 
> 
> 
> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> ---
> diff -X ignore.patcher -ruNp linux-2.6.18-194.el5/fs/nfs/inode.c linux-2.6.18-194.ff/fs/nfs/inode.c
> --- linux-2.6.18-194.el5/fs/nfs/inode.c	2010-12-01 15:52:11.000000000 -0800
> +++ linux-2.6.18-194.ff/fs/nfs/inode.c	2010-12-01 16:53:28.000000000 -0800
> @@ -71,7 +71,7 @@ static kmem_cache_t * nfs_inode_cachep;
>   */
>  u64 nfs_compat_user_ino64(u64 fileid)
>  {
> -	int ino;
> +	unsigned int ino;

Shouldn't this just be of type 'compat_ulong_t' if CONFIG_COMPAT is
defined, and of type 'unsigned long' if not?

Cheers
 Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


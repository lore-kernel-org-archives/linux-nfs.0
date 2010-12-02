Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47095 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546Ab0LBDNS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 22:13:18 -0500
Subject: Re: [PATCH] NFS client has troubles with fileid with bit 31 (or
 bit 63) set
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Frank Filz <ffilzlnx@us.ibm.com>
Cc: ffilz@us.ibm.com, NFS List <linux-nfs@vger.kernel.org>
In-Reply-To: <1291258912.5075.10.camel@KPMH461.ibm.com>
References: <1291251786.5075.6.camel@KPMH461.ibm.com>
	 <1291253786.6609.90.camel@heimdal.trondhjem.org>
	 <1291258912.5075.10.camel@KPMH461.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 22:13:16 -0500
Message-ID: <1291259596.6609.109.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-01 at 19:01 -0800, Frank Filz wrote:
> On Wed, 2010-12-01 at 20:36 -0500, Trond Myklebust wrote:
> > On Wed, 2010-12-01 at 17:03 -0800, Frank Filz wrote:
> > > Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> > > ---
> > > diff -X ignore.patcher -ruNp linux-2.6.18-194.el5/fs/nfs/inode.c linux-2.6.18-194.ff/fs/nfs/inode.c
> > > --- linux-2.6.18-194.el5/fs/nfs/inode.c	2010-12-01 15:52:11.000000000 -0800
> > > +++ linux-2.6.18-194.ff/fs/nfs/inode.c	2010-12-01 16:53:28.000000000 -0800
> > > @@ -71,7 +71,7 @@ static kmem_cache_t * nfs_inode_cachep;
> > >   */
> > >  u64 nfs_compat_user_ino64(u64 fileid)
> > >  {
> > > -	int ino;
> > > +	unsigned int ino;
> > 
> > Shouldn't this just be of type 'compat_ulong_t' if CONFIG_COMPAT is
> > defined, and of type 'unsigned long' if not?
> 
> The full (patched) function is:
> 
> u64 nfs_compat_user_ino64(u64 fileid)
> {
> 	unsigned int ino;
> 
> 	if (enable_ino64)
> 		return fileid;
> 	ino = fileid;
> 	if (sizeof(ino) < sizeof(fileid))
> 		ino ^= fileid >> (sizeof(fileid)-sizeof(ino)) * 8;
> 	return ino;
> }
> 
> ino is only used if the function is expected to return a 32 bit fileid,
> so no need for it to be anything other than an unsigned int. I suppose
> it should actually be a uint32.

I'm suggesting it should rather match the compat_ulong_t, since that is
what 64-bit kernels will need to deal with if running a 32-bit
userspace. For 64-bit kernels that have no 32-bit userspace emulation
layer, why would we care about returning a truncated 32-bit fileid?

Conversely, if running a 32-bit kernel, then 'unsigned long' will
directly match the types used by fs/readdir.c:filldir()

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


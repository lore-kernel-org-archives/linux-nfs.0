Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:35133 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756062Ab0LBDCA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 22:02:00 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oB22paLX023542
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 19:51:36 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id oB231tRc251960
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 20:01:55 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB2365I4016481
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 20:06:05 -0700
Subject: Re: [PATCH] NFS client has troubles with fileid with bit 31 (or
	bit 63) set
From: Frank Filz <ffilzlnx@us.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: ffilz@us.ibm.com, NFS List <linux-nfs@vger.kernel.org>
In-Reply-To: <1291253786.6609.90.camel@heimdal.trondhjem.org>
References: <1291251786.5075.6.camel@KPMH461.ibm.com>
	 <1291253786.6609.90.camel@heimdal.trondhjem.org>
Content-Type: text/plain
Date: Wed, 01 Dec 2010 19:01:52 -0800
Message-Id: <1291258912.5075.10.camel@KPMH461.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Wed, 2010-12-01 at 20:36 -0500, Trond Myklebust wrote:
> On Wed, 2010-12-01 at 17:03 -0800, Frank Filz wrote:
> > Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> > ---
> > diff -X ignore.patcher -ruNp linux-2.6.18-194.el5/fs/nfs/inode.c linux-2.6.18-194.ff/fs/nfs/inode.c
> > --- linux-2.6.18-194.el5/fs/nfs/inode.c	2010-12-01 15:52:11.000000000 -0800
> > +++ linux-2.6.18-194.ff/fs/nfs/inode.c	2010-12-01 16:53:28.000000000 -0800
> > @@ -71,7 +71,7 @@ static kmem_cache_t * nfs_inode_cachep;
> >   */
> >  u64 nfs_compat_user_ino64(u64 fileid)
> >  {
> > -	int ino;
> > +	unsigned int ino;
> 
> Shouldn't this just be of type 'compat_ulong_t' if CONFIG_COMPAT is
> defined, and of type 'unsigned long' if not?

The full (patched) function is:

u64 nfs_compat_user_ino64(u64 fileid)
{
	unsigned int ino;

	if (enable_ino64)
		return fileid;
	ino = fileid;
	if (sizeof(ino) < sizeof(fileid))
		ino ^= fileid >> (sizeof(fileid)-sizeof(ino)) * 8;
	return ino;
}

ino is only used if the function is expected to return a 32 bit fileid,
so no need for it to be anything other than an unsigned int. I suppose
it should actually be a uint32.

Frank


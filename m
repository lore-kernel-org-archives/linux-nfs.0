Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:41475 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755040Ab0K3SDI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 13:03:08 -0500
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp02.in.ibm.com (8.14.4/8.13.1) with ESMTP id oAUI35uG018368
	for <linux-nfs@vger.kernel.org>; Tue, 30 Nov 2010 23:33:05 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAUI35B14223044
	for <linux-nfs@vger.kernel.org>; Tue, 30 Nov 2010 23:33:05 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAUI35Ow009030
	for <linux-nfs@vger.kernel.org>; Wed, 1 Dec 2010 05:03:05 +1100
From: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 ACL set and inode attribute cache
In-Reply-To: <1291061630.12784.49.camel@heimdal.trondhjem.org>
References: <m3hbfpvz0k.fsf@linux.vnet.ibm.com> <m3eiatvwpc.fsf@linux.vnet.ibm.com> <m31v6rrrfr.fsf@linux.vnet.ibm.com> <m3zkssjuyz.fsf@linux.vnet.ibm.com> <1291061630.12784.49.camel@heimdal.trondhjem.org>
Date: Tue, 30 Nov 2010 23:33:03 +0530
Message-ID: <m3hbeyzo2w.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 29 Nov 2010 15:13:50 -0500, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Mon, 2010-11-29 at 15:46 +0530, Aneesh Kumar K. V wrote:
> > On Fri, 12 Nov 2010 11:53:20 +0530, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > On Thu, 11 Nov 2010 00:21:27 +0530, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > > On Wed, 10 Nov 2010 23:31:31 +0530, Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > > > 
> > > > > Hi,
> > > > > 
> > > > > I guess we are not marking the inode attribute as invalid when we set
> > > > > the ACL value. For ex:
> > > > > 
> > > > > /d# mkdir sub3
> > > > > /d# ls -dl sub3
> > > > > drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> > > > > /d# nfs4_setfacl -s A:fd:EVERYONE@:rwax sub3
> > > > > /d# ls -dl sub3
> > > > > drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> > > > > /d# 
> > > > > 
> > > > > 
> > > > > On the server i have the mode bits as
> > > > > /d# ls -dl sub3
> > > > > drwxrwxrwx 2 root root 4096 Nov 10 17:56 sub3
> > > > > /d# 
> > > > 
> > > > We also have similar issue other way round. ie setting the mode bits
> > > > don't result in ACL values being invalidated. But a second request get
> > > > the right value of ACL as show below.
> > > > 
> > > > /d# nfs4_getfacl  x
> > > > A::OWNER@:rw
> > > > A::GROUP@:rw
> > > > A::EVERYONE@:r
> > > > /d# chmod 600 x
> > > > /d# nfs4_getfacl  x
> > > > A::OWNER@:rw
> > > > A::GROUP@:rw
> > > > A::EVERYONE@:r
> > > > /d#
> > > > 
> > > > Expected value is
> > > > 
> > > > /d# nfs4_getfacl  x
> > > > A::OWNER@:rw
> > > > 
> > > 
> > > The below patch fix the problem for me. If this is the right way
> > > to fix, I can send a proper patch with commit message and s-o-b.
> > > 
> > > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > > index 0f24cdf..666a48b 100644
> > > --- a/fs/nfs/nfs4proc.c
> > > +++ b/fs/nfs/nfs4proc.c
> > > @@ -3359,6 +3359,8 @@ static ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen)
> > >  	ret = nfs_revalidate_inode(server, inode);
> > >  	if (ret < 0)
> > >  		return ret;
> > > +	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
> > > +		nfs_zap_acl_cache(inode);
> > >  	ret = nfs4_read_cached_acl(inode, buf, buflen);
> > >  	if (ret != -ENOENT)
> > >  		return ret;
> > > @@ -3387,6 +3389,11 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
> > >  	nfs_inode_return_delegation(inode);
> > >  	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
> > >  	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
> > > +	/*
> > > +	 * Acl update can result in inode attribute update.
> > > +	 * so mark the attribute cache invalid.
> > > +	 */
> > > +	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
> 
> This needs to be done under the correct spin locks, so please use the
> helper nfs_mark_for_revalidate() instead of attempting to open coding
> it.

nfs_mark_for_revalidate mark other fields as invalid. Do we need to do that
when updating ACL ? If not how about 

	spin_lock(&inode->i_lock);
        NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;   
	spin_unlock(&inode->i_lock);

> 
> > >  	nfs_access_zap_cache(inode);
> > >  	nfs_zap_acl_cache(inode);
> > >  	return ret;
> > 
> > 
> > Any update on this ? Another option i figured out today is to make sure
> > we add FATTR4_WORD0_ACL in nfs4_fattr_bitmap for fetching the modified
> > acl value on mode update. Similarly setfacl can be compounded with the
> > getattr request.
> 
> We actually used to compound setacl with a GETATTR(FATTR4_WORD0_ACL) in
> order to ensure that the server sets it correctly. Unfortunately, that
> caused some servers to return NFS4ERR_RESOURCE due to the burden of
> caching all that acl information in the duplicate request queue.

What i was suggesting was to compound setacl with
GETATTR(FATTR4_WORD1_MODE) so that we get the update mode bits as a part
of response. Also componding setattr request with GETATTR(FATTR4_WORD0_ACL)


> 
> I'd be fine with adding an ordinary getattr request, though, as long as
> it is allowed to fail (i.e. the result of __nfs4_proc_set_acl() must
> only depend on the setacl).
> 

-aneesh

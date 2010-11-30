Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9811 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab0K3VoS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 16:44:18 -0500
Subject: Re: NFSv4 ACL set and inode attribute cache
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <m3hbeyzo2w.fsf@linux.vnet.ibm.com>
References: <m3hbfpvz0k.fsf@linux.vnet.ibm.com>
	 <m3eiatvwpc.fsf@linux.vnet.ibm.com> <m31v6rrrfr.fsf@linux.vnet.ibm.com>
	 <m3zkssjuyz.fsf@linux.vnet.ibm.com>
	 <1291061630.12784.49.camel@heimdal.trondhjem.org>
	 <m3hbeyzo2w.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Nov 2010 13:40:14 -0500
Message-ID: <1291142414.3594.4.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-11-30 at 23:33 +0530, Aneesh Kumar K. V wrote: 
> On Mon, 29 Nov 2010 15:13:50 -0500, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > On Mon, 2010-11-29 at 15:46 +0530, Aneesh Kumar K. V wrote:
> > > On Fri, 12 Nov 2010 11:53:20 +0530, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > > On Thu, 11 Nov 2010 00:21:27 +0530, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > > > On Wed, 10 Nov 2010 23:31:31 +0530, Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > > > > 
> > > > > > Hi,
> > > > > > 
> > > > > > I guess we are not marking the inode attribute as invalid when we set
> > > > > > the ACL value. For ex:
> > > > > > 
> > > > > > /d# mkdir sub3
> > > > > > /d# ls -dl sub3
> > > > > > drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> > > > > > /d# nfs4_setfacl -s A:fd:EVERYONE@:rwax sub3
> > > > > > /d# ls -dl sub3
> > > > > > drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> > > > > > /d# 
> > > > > > 
> > > > > > 
> > > > > > On the server i have the mode bits as
> > > > > > /d# ls -dl sub3
> > > > > > drwxrwxrwx 2 root root 4096 Nov 10 17:56 sub3
> > > > > > /d# 
> > > > > 
> > > > > We also have similar issue other way round. ie setting the mode bits
> > > > > don't result in ACL values being invalidated. But a second request get
> > > > > the right value of ACL as show below.
> > > > > 
> > > > > /d# nfs4_getfacl  x
> > > > > A::OWNER@:rw
> > > > > A::GROUP@:rw
> > > > > A::EVERYONE@:r
> > > > > /d# chmod 600 x
> > > > > /d# nfs4_getfacl  x
> > > > > A::OWNER@:rw
> > > > > A::GROUP@:rw
> > > > > A::EVERYONE@:r
> > > > > /d#
> > > > > 
> > > > > Expected value is
> > > > > 
> > > > > /d# nfs4_getfacl  x
> > > > > A::OWNER@:rw
> > > > > 
> > > > 
> > > > The below patch fix the problem for me. If this is the right way
> > > > to fix, I can send a proper patch with commit message and s-o-b.
> > > > 
> > > > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > > > index 0f24cdf..666a48b 100644
> > > > --- a/fs/nfs/nfs4proc.c
> > > > +++ b/fs/nfs/nfs4proc.c
> > > > @@ -3359,6 +3359,8 @@ static ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen)
> > > >  	ret = nfs_revalidate_inode(server, inode);
> > > >  	if (ret < 0)
> > > >  		return ret;
> > > > +	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
> > > > +		nfs_zap_acl_cache(inode);
> > > >  	ret = nfs4_read_cached_acl(inode, buf, buflen);
> > > >  	if (ret != -ENOENT)
> > > >  		return ret;
> > > > @@ -3387,6 +3389,11 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
> > > >  	nfs_inode_return_delegation(inode);
> > > >  	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
> > > >  	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
> > > > +	/*
> > > > +	 * Acl update can result in inode attribute update.
> > > > +	 * so mark the attribute cache invalid.
> > > > +	 */
> > > > +	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
> > 
> > This needs to be done under the correct spin locks, so please use the
> > helper nfs_mark_for_revalidate() instead of attempting to open coding
> > it.
> 
> nfs_mark_for_revalidate mark other fields as invalid. Do we need to do that
> when updating ACL ? If not how about 



> 	spin_lock(&inode->i_lock);
>         NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;   
> 	spin_unlock(&inode->i_lock);

That's fine as a short term fix. For the long term, let's try to add the
getattr, as you suggested, so that we can do the inode attribute
revalidation here.

> > > >  	nfs_access_zap_cache(inode);
> > > >  	nfs_zap_acl_cache(inode);
> > > >  	return ret;
> > > 
> > > 
> > > Any update on this ? Another option i figured out today is to make sure
> > > we add FATTR4_WORD0_ACL in nfs4_fattr_bitmap for fetching the modified
> > > acl value on mode update. Similarly setfacl can be compounded with the
> > > getattr request.
> > 
> > We actually used to compound setacl with a GETATTR(FATTR4_WORD0_ACL) in
> > order to ensure that the server sets it correctly. Unfortunately, that
> > caused some servers to return NFS4ERR_RESOURCE due to the burden of
> > caching all that acl information in the duplicate request queue.
> 
> What i was suggesting was to compound setacl with
> GETATTR(FATTR4_WORD1_MODE) so that we get the update mode bits as a part
> of response. Also componding setattr request with GETATTR(FATTR4_WORD0_ACL)

You'd be missing the change attribute and the ctime, both of which are
also guaranteed to change when the acl is changed.

We might as well just do a full attribute revalidation...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com



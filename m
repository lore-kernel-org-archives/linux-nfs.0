Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:55115 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918Ab0K2KQ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 05:16:27 -0500
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id oATABOno031799
	for <linux-nfs@vger.kernel.org>; Mon, 29 Nov 2010 21:11:24 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oATAGPbL2338896
	for <linux-nfs@vger.kernel.org>; Mon, 29 Nov 2010 21:16:25 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oATAGPfc021792
	for <linux-nfs@vger.kernel.org>; Mon, 29 Nov 2010 21:16:25 +1100
From: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
To: Trond Myklebust <trond.myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 ACL set and inode attribute cache
In-Reply-To: <m31v6rrrfr.fsf@linux.vnet.ibm.com>
References: <m3hbfpvz0k.fsf@linux.vnet.ibm.com> <m3eiatvwpc.fsf@linux.vnet.ibm.com> <m31v6rrrfr.fsf@linux.vnet.ibm.com>
Date: Mon, 29 Nov 2010 15:46:20 +0530
Message-ID: <m3zkssjuyz.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 12 Nov 2010 11:53:20 +0530, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> On Thu, 11 Nov 2010 00:21:27 +0530, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > On Wed, 10 Nov 2010 23:31:31 +0530, Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > 
> > > Hi,
> > > 
> > > I guess we are not marking the inode attribute as invalid when we set
> > > the ACL value. For ex:
> > > 
> > > /d# mkdir sub3
> > > /d# ls -dl sub3
> > > drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> > > /d# nfs4_setfacl -s A:fd:EVERYONE@:rwax sub3
> > > /d# ls -dl sub3
> > > drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> > > /d# 
> > > 
> > > 
> > > On the server i have the mode bits as
> > > /d# ls -dl sub3
> > > drwxrwxrwx 2 root root 4096 Nov 10 17:56 sub3
> > > /d# 
> > 
> > We also have similar issue other way round. ie setting the mode bits
> > don't result in ACL values being invalidated. But a second request get
> > the right value of ACL as show below.
> > 
> > /d# nfs4_getfacl  x
> > A::OWNER@:rw
> > A::GROUP@:rw
> > A::EVERYONE@:r
> > /d# chmod 600 x
> > /d# nfs4_getfacl  x
> > A::OWNER@:rw
> > A::GROUP@:rw
> > A::EVERYONE@:r
> > /d#
> > 
> > Expected value is
> > 
> > /d# nfs4_getfacl  x
> > A::OWNER@:rw
> > 
> 
> The below patch fix the problem for me. If this is the right way
> to fix, I can send a proper patch with commit message and s-o-b.
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 0f24cdf..666a48b 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3359,6 +3359,8 @@ static ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen)
>  	ret = nfs_revalidate_inode(server, inode);
>  	if (ret < 0)
>  		return ret;
> +	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
> +		nfs_zap_acl_cache(inode);
>  	ret = nfs4_read_cached_acl(inode, buf, buflen);
>  	if (ret != -ENOENT)
>  		return ret;
> @@ -3387,6 +3389,11 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
>  	nfs_inode_return_delegation(inode);
>  	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
>  	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
> +	/*
> +	 * Acl update can result in inode attribute update.
> +	 * so mark the attribute cache invalid.
> +	 */
> +	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
>  	nfs_access_zap_cache(inode);
>  	nfs_zap_acl_cache(inode);
>  	return ret;


Any update on this ? Another option i figured out today is to make sure
we add FATTR4_WORD0_ACL in nfs4_fattr_bitmap for fetching the modified
acl value on mode update. Similarly setfacl can be compounded with the
getattr request.

-aneesh

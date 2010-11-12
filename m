Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:49716 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab0KLGXd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Nov 2010 01:23:33 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp02.in.ibm.com (8.14.4/8.13.1) with ESMTP id oAC6NU1l012906
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 11:53:30 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAC6NTvn1192176
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 11:53:29 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAC6NTq5021307
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 11:53:29 +0530
From: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
To: Trond Myklebust <trond.myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 ACL set and inode attribute cache
In-Reply-To: <m3eiatvwpc.fsf@linux.vnet.ibm.com>
References: <m3hbfpvz0k.fsf@linux.vnet.ibm.com> <m3eiatvwpc.fsf@linux.vnet.ibm.com>
Date: Fri, 12 Nov 2010 11:53:20 +0530
Message-ID: <m31v6rrrfr.fsf@linux.vnet.ibm.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 11 Nov 2010 00:21:27 +0530, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> On Wed, 10 Nov 2010 23:31:31 +0530, Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > 
> > Hi,
> > 
> > I guess we are not marking the inode attribute as invalid when we set
> > the ACL value. For ex:
> > 
> > /d# mkdir sub3
> > /d# ls -dl sub3
> > drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> > /d# nfs4_setfacl -s A:fd:EVERYONE@:rwax sub3
> > /d# ls -dl sub3
> > drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> > /d# 
> > 
> > 
> > On the server i have the mode bits as
> > /d# ls -dl sub3
> > drwxrwxrwx 2 root root 4096 Nov 10 17:56 sub3
> > /d# 
> 
> We also have similar issue other way round. ie setting the mode bits
> don't result in ACL values being invalidated. But a second request get
> the right value of ACL as show below.
> 
> /d# nfs4_getfacl  x
> A::OWNER@:rw
> A::GROUP@:rw
> A::EVERYONE@:r
> /d# chmod 600 x
> /d# nfs4_getfacl  x
> A::OWNER@:rw
> A::GROUP@:rw
> A::EVERYONE@:r
> /d#
> 
> Expected value is
> 
> /d# nfs4_getfacl  x
> A::OWNER@:rw
> 

The below patch fix the problem for me. If this is the right way
to fix, I can send a proper patch with commit message and s-o-b.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0f24cdf..666a48b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3359,6 +3359,8 @@ static ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen)
 	ret = nfs_revalidate_inode(server, inode);
 	if (ret < 0)
 		return ret;
+	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
+		nfs_zap_acl_cache(inode);
 	ret = nfs4_read_cached_acl(inode, buf, buflen);
 	if (ret != -ENOENT)
 		return ret;
@@ -3387,6 +3389,11 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	nfs_inode_return_delegation(inode);
 	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
 	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
+	/*
+	 * Acl update can result in inode attribute update.
+	 * so mark the attribute cache invalid.
+	 */
+	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
 	nfs_access_zap_cache(inode);
 	nfs_zap_acl_cache(inode);
 	return ret;

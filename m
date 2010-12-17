Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:50365 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab0LQGrA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Dec 2010 01:47:00 -0500
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id oBH6lAPP007043
	for <linux-nfs@vger.kernel.org>; Fri, 17 Dec 2010 17:47:10 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBH6kvnN2220070
	for <linux-nfs@vger.kernel.org>; Fri, 17 Dec 2010 17:46:58 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBH6kvLa009500
	for <linux-nfs@vger.kernel.org>; Fri, 17 Dec 2010 17:46:57 +1100
From: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: Set MS_POSIXACL always
In-Reply-To: <1292521792.2912.49.camel@heimdal.trondhjem.org>
Date: Fri, 17 Dec 2010 12:10:38 +0530
Message-ID: <m3fwtw297d.fsf@linux.vnet.ibm.com>
References: <1291894514-6524-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <m3k4j91vw2.fsf@linux.vnet.ibm.com> <1292521792.2912.49.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 16 Dec 2010 12:49:52 -0500, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Thu, 2010-12-16 at 22:45 +0530, Aneesh Kumar K. V wrote:
> > Any update on this ?
> > 
> > -aneesh
> > 
> > On Thu,  9 Dec 2010 17:05:14 +0530, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > We want to skip VFS applying mode for NFS. So set MS_POSIXACL always
> > > and selectively use umask. Ideally we would want to use umask only
> > > when we don't have inheritable ACEs set. But NFS currently don't
> > > allow to send umask to the server. So this is best what we can do
> > > and this is consistent with NFSv3
> > > 
> > > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > > ---
> > >  fs/nfs/dir.c      |    3 +--
> > >  fs/nfs/nfs4proc.c |    5 +++++
> > >  fs/nfs/super.c    |   10 ++++++++++
> > >  3 files changed, 16 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > > index 3c04504..e57e670 100644
> > > --- a/fs/nfs/super.c
> > > +++ b/fs/nfs/super.c
> > > @@ -2508,6 +2513,11 @@ static void nfs4_fill_super(struct super_block *sb)
> > >  {
> > >  	sb->s_time_gran = 1;
> > >  	sb->s_op = &nfs4_sops;
> > > +	/*
> > > +	 * The VFS shouldn't apply the umask to mode bits. We will do
> > > +	 * so ourselves when necessary.
> > > +	 */
> > > +	sb->s_flags  |= MS_POSIXACL;
> > >  	nfs_initialise_sb(sb);
> > >  }
> 
> Won't this end up possibly turning on ACL checking in
> acl_permission_check()?

acl_permission_check get called only when we don't define an
inode->permission callback. In case of nfs client we do define 
nfs_permission callback. In case we don't define a access NFS proto
callback we are still ok because in that case we want mode based
validation and we do pass check_acl as NULL 

-aneesh

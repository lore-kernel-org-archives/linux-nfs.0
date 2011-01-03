Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:54617 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181Ab1ACQEa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jan 2011 11:04:30 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p03G4SEa005841
	for <linux-nfs@vger.kernel.org>; Mon, 3 Jan 2011 21:34:28 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p03G4Rlf2387990
	for <linux-nfs@vger.kernel.org>; Mon, 3 Jan 2011 21:34:27 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p03G4Q8c020910
	for <linux-nfs@vger.kernel.org>; Tue, 4 Jan 2011 03:04:27 +1100
From: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: Set MS_POSIXACL always
In-Reply-To: <m3fwtw297d.fsf@linux.vnet.ibm.com>
References: <1291894514-6524-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <m3k4j91vw2.fsf@linux.vnet.ibm.com> <1292521792.2912.49.camel@heimdal.trondhjem.org> <m3fwtw297d.fsf@linux.vnet.ibm.com>
Date: Mon, 03 Jan 2011 21:34:23 +0530
Message-ID: <877hemdldk.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 17 Dec 2010 12:10:38 +0530, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> On Thu, 16 Dec 2010 12:49:52 -0500, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > On Thu, 2010-12-16 at 22:45 +0530, Aneesh Kumar K. V wrote:
> > > Any update on this ?
> > > 
> > > -aneesh
> > > 
> > > On Thu,  9 Dec 2010 17:05:14 +0530, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > > > We want to skip VFS applying mode for NFS. So set MS_POSIXACL always
> > > > and selectively use umask. Ideally we would want to use umask only
> > > > when we don't have inheritable ACEs set. But NFS currently don't
> > > > allow to send umask to the server. So this is best what we can do
> > > > and this is consistent with NFSv3
> > > > 
> > > > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > > > ---
> > > >  fs/nfs/dir.c      |    3 +--
> > > >  fs/nfs/nfs4proc.c |    5 +++++
> > > >  fs/nfs/super.c    |   10 ++++++++++
> > > >  3 files changed, 16 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > > > index 3c04504..e57e670 100644
> > > > --- a/fs/nfs/super.c
> > > > +++ b/fs/nfs/super.c
> > > > @@ -2508,6 +2513,11 @@ static void nfs4_fill_super(struct super_block *sb)
> > > >  {
> > > >  	sb->s_time_gran = 1;
> > > >  	sb->s_op = &nfs4_sops;
> > > > +	/*
> > > > +	 * The VFS shouldn't apply the umask to mode bits. We will do
> > > > +	 * so ourselves when necessary.
> > > > +	 */
> > > > +	sb->s_flags  |= MS_POSIXACL;
> > > >  	nfs_initialise_sb(sb);
> > > >  }
> > 
> > Won't this end up possibly turning on ACL checking in
> > acl_permission_check()?
> 
> acl_permission_check get called only when we don't define an
> inode->permission callback. In case of nfs client we do define 
> nfs_permission callback. In case we don't define a access NFS proto
> callback we are still ok because in that case we want mode based
> validation and we do pass check_acl as NULL 
> 

Can we get this upstream ?

-aneesh

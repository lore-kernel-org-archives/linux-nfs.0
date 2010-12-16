Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6467 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751795Ab0LPRty convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Dec 2010 12:49:54 -0500
Subject: Re: [PATCH] nfs: Set MS_POSIXACL always
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
In-Reply-To: <m3k4j91vw2.fsf@linux.vnet.ibm.com>
References: <1291894514-6524-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <m3k4j91vw2.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Dec 2010 12:49:52 -0500
Message-ID: <1292521792.2912.49.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-12-16 at 22:45 +0530, Aneesh Kumar K. V wrote:
> Any update on this ?
> 
> -aneesh
> 
> On Thu,  9 Dec 2010 17:05:14 +0530, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> > We want to skip VFS applying mode for NFS. So set MS_POSIXACL always
> > and selectively use umask. Ideally we would want to use umask only
> > when we don't have inheritable ACEs set. But NFS currently don't
> > allow to send umask to the server. So this is best what we can do
> > and this is consistent with NFSv3
> > 
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > ---
> >  fs/nfs/dir.c      |    3 +--
> >  fs/nfs/nfs4proc.c |    5 +++++
> >  fs/nfs/super.c    |   10 ++++++++++
> >  3 files changed, 16 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index 3c04504..e57e670 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -2508,6 +2513,11 @@ static void nfs4_fill_super(struct super_block *sb)
> >  {
> >  	sb->s_time_gran = 1;
> >  	sb->s_op = &nfs4_sops;
> > +	/*
> > +	 * The VFS shouldn't apply the umask to mode bits. We will do
> > +	 * so ourselves when necessary.
> > +	 */
> > +	sb->s_flags  |= MS_POSIXACL;
> >  	nfs_initialise_sb(sb);
> >  }

Won't this end up possibly turning on ACL checking in
acl_permission_check()?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


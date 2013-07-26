Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46247 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757778Ab3GZWJ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jul 2013 18:09:26 -0400
Date: Fri, 26 Jul 2013 18:09:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-nfs@vger.kernel.org, bfields@redhat.com,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: fix NFSv3 with sec=krb5 and CONFIG_NFS_V3_ACL=y
Message-ID: <20130726220924.GG30651@fieldses.org>
References: <682ebd8ecc7309b18396da356a0feb38bfa41674.1372692346.git.jstancek@redhat.com>
 <20130708201643.GI29071@fieldses.org>
 <1157529877.873319.1373353194344.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1157529877.873319.1373353194344.JavaMail.root@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 02:59:54AM -0400, Jan Stancek wrote:
> 
> 
> 
> 
> ----- Original Message -----
> > From: "J. Bruce Fields" <bfields@fieldses.org>
> > To: "Jan Stancek" <jstancek@redhat.com>
> > Cc: linux-nfs@vger.kernel.org, bfields@redhat.com, "Trond Myklebust" <Trond.Myklebust@netapp.com>
> > Sent: Monday, 8 July, 2013 10:16:43 PM
> > Subject: Re: [PATCH] NFS: fix NFSv3 with sec=krb5 and CONFIG_NFS_V3_ACL=y
> > 
> > On Mon, Jul 01, 2013 at 05:32:34PM +0200, Jan Stancek wrote:
> > > Starting with commit:
> > >   commit f994c43d19a9116727d4c228d3f13db595bff562
> > >   Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> > >   Date:   Thu Nov 1 12:14:14 2012 -0400
> > >       SUNRPC: Clean up rpc_bind_new_program
> > > 
> > > operations on directory mounted with -onfsvers=3,tcp,sec=krb5 fail
> > > with Input/Output error after ~60 second timeout. This is presumably
> > > because upcalls for 'nfsacl' are not getting anywhere.
> > > 
> > > This patch enables pipe dir for nfsacl_program and changes its name
> > > to 'nfs'. This name will be used in upcalls and whole setup should
> > > work as it did in past - just with nfs/hostname principal.
> > 
> > I think this was the problem that nfs-utils commits
> > 
> > 	a1f8afc560 gssd: Remove insane sanity checks of the service name
> > 	a56989b665 gssd: Handle the target name correctly
> > 
> > were supposed to fix?
> > 
> > But perhaps the kernel needs a fix too to fix a regression with old
> > userspace.
> 
> I saw this error with nfs-utils.1.2.9-rc1, which should already contain
> those 2 commits.

Actually, I think your patch is just a subset of Trond's
http://mid.gmane.org/<4FA345DA4F4AE44899BD2B03EEEC2FA9092EC392@SACEXCMBX04-PRD.hq.netapp.com>

Trond, is there a reason that never got applied?

--b.

> 
> Regards,
> Jan
> 
> > 
> > --b.
> > 
> > > 
> > > Signed-off-by: Jan Stancek <jstancek@redhat.com>
> > > ---
> > >  fs/nfs/nfs3client.c |    3 ++-
> > >  1 files changed, 2 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
> > > index b3fc65e..09a7d06 100644
> > > --- a/fs/nfs/nfs3client.c
> > > +++ b/fs/nfs/nfs3client.c
> > > @@ -9,11 +9,12 @@ static const struct rpc_version *nfsacl_version[] = {
> > >  };
> > >  
> > >  const struct rpc_program nfsacl_program = {
> > > -	.name			= "nfsacl",
> > > +	.name			= "nfs",
> > >  	.number			= NFS_ACL_PROGRAM,
> > >  	.nrvers			= ARRAY_SIZE(nfsacl_version),
> > >  	.version		= nfsacl_version,
> > >  	.stats			= &nfsacl_rpcstat,
> > > +	.pipe_dir_name		= NFS_PIPE_DIRNAME,
> > >  };
> > >  
> > >  /*
> > > --
> > > 1.7.1
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

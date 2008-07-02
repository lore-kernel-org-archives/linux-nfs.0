From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: inux-next: Tree for July 1
Date: Wed, 02 Jul 2008 13:15:11 -0400
Message-ID: <1215018911.9783.1.camel@localhost>
References: <20080702011434.6fb403d5.sfr@canb.auug.org.au>
	 <200807012236.19400.rjw@sisk.pl> <1214959743.10317.3.camel@localhost>
	 <76bd70e30807020734g3db408dcqea2a61622c83004d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Randy.Dunlap" <rdunlap@xenotime.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-testers@vger.kernel.org, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <76bd70e30807020734g3db408dcqea2a61622c83004d@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-07-02 at 10:34 -0400, Chuck Lever wrote:
> On Tue, Jul 1, 2008 at 8:49 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Tue, 2008-07-01 at 22:36 +0200, Rafael J. Wysocki wrote:
> >> I can't mount NFS shares with this kernel.  I get something of this sort in
> >> dmesg and it seems to be 100% reproducible:
> >>
> >> [  314.058858] RPC: Registered udp transport module.
> >> [  314.058863] RPC: Registered tcp transport module.
> >> [  314.490970] RPC: transport (0) not supported
> >> [  319.246987] __ratelimit: 23 messages suppressed
> >
> > Does this patch fix the problem for you?
> > -----------------------------------------------------------------------------------
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > NFS: Fix the mount protocol defaults for binary mounts
> >
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >
> >  fs/nfs/super.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index e09b1c2..85fbb98 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -1575,6 +1575,7 @@ static int nfs_validate_mount_data(void *options,
> >
> >                if (!(data->flags & NFS_MOUNT_TCP))
> >                        args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
> > +               nfs_set_transport_defaults(args);
> 
> nfs_set_transport_defaults() is overkill for the legacy mount path.
> The bug is that the logic here assumes that nfs_server.protocol
> already has the default value of XPRT_TRANSPORT_TCP, but commit
> 8b59ea3c removed that default.  The correct fix is to add
> 
>             args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
> 
> just before the 'if' statement.  We should fold that into 8b59ea3c to
> preserve bisectability.

NACK. You still need to set the appropriate retrans and timeo defaults.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

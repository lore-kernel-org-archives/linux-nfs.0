From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] [NFSD] Typo in nfsd_vers()
Date: Fri, 18 Jan 2008 17:06:41 -0500
Message-ID: <20080118220641.GP15158@fieldses.org>
References: <478F472F.9050800@RedHat.com> <20080117181055.2bd53d7d@tupile.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59015 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761171AbYARWGn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 17:06:43 -0500
In-Reply-To: <20080117181055.2bd53d7d-PC62bkCOHzGdMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 17, 2008 at 06:10:55PM -0500, Jeff Layton wrote:
> On Thu, 17 Jan 2008 07:16:47 -0500
> Steve Dickson <SteveD@redhat.com> wrote:
> 
> > During my travels I found a small typo in nfsd_vers() (the routine
> > used by rpc.nfsd to set the protocol version(s) in NFS server)
> > 
> > When testing to see which versions are available, nfsd_vers() should
> > use nfsd_versions[] not nfsd_version[]. The reason this typo is
> > not noticeable is due to the fact this availability info is used in
> > a reply that rpc.nfsd ignores.
> > 
> > steved.
> > 
> > 
> > Author: Steve Dickson <steved@redhat.com>
> > Date:   Thu Jan 17 06:50:57 2008 -0500
> > 
> >     In nfsd_vers() the NFSD_AVAIL command should be using nfsd_versions[]
> >     not nfsd_version[]
> > 
> >     Signed-off-by: Steve Dickson <steved@redhat.com>
> > 
> > diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> > index 1190aea..f0c66e0 100644
> > --- a/fs/nfsd/nfssvc.c
> > +++ b/fs/nfsd/nfssvc.c
> > @@ -134,7 +134,7 @@ int nfsd_vers(int vers, enum vers_op change)
> >     case NFSD_TEST:
> >         return nfsd_versions[vers] != NULL;
> >     case NFSD_AVAIL:
> > -       return nfsd_version[vers] != NULL;
> > +       return nfsd_versions[vers] != NULL;
> >     }
> >     return 0;
> >  }
> 
> This doesn't look right to me. With this, NFSD_TEST and NFSD_AVAIL do
> exactly the same thing. Why do we need both?
> 
> It also changes the output of /proc/fs/nfsd/versions. It should show a
> number for every version compiled into the kernel, with a corresponding
> + or - depending on whether that version is enabled. With this patch,
> it'll only ever show versions that are enabled, never ones that are
> compiled in and disabled.

Oops, looks to me like you're correct--so nfsd_version[] is the versions
which this kernel was built to support, and nfsd_versions[] is the
subset of those that the server is currently accepting?

We could maybe give those two arrays names that were more helpful....

--b.

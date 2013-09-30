Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26553 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755245Ab3I3O1l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 10:27:41 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>
Subject: RE: [PATCH 3/3] NFSv4.1: Ensure memory ordering between
 nfs4_ds_connect and nfs4_fl_prepare_ds
Date: Mon, 30 Sep 2013 14:27:39 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9467F33BB@SACEXCMBX04-PRD.hq.netapp.com>
References: <1380224367-10939-1-git-send-email-Trond.Myklebust@netapp.com>
	<1380224367-10939-2-git-send-email-Trond.Myklebust@netapp.com>
	<1380224367-10939-3-git-send-email-Trond.Myklebust@netapp.com>
 <20130930070154.3278f3c8@tlielax.poochiereds.net>
In-Reply-To: <20130930070154.3278f3c8@tlielax.poochiereds.net>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@redhat.com]
> Sent: Monday, September 30, 2013 7:02 AM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org; Adamson, Andy
> Subject: Re: [PATCH 3/3] NFSv4.1: Ensure memory ordering between
> nfs4_ds_connect and nfs4_fl_prepare_ds
> 
> On Thu, 26 Sep 2013 15:39:27 -0400
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > We need to ensure that the initialisation of the data server
> > nfs_client structure in nfs4_ds_connect is correctly ordered w.r.t.
> > the read of
> > ds->ds_clp in nfs4_fl_prepare_ds.
> >
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >  fs/nfs/nfs4filelayoutdev.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> > index ea2b2bf..6456fc4 100644
> > --- a/fs/nfs/nfs4filelayoutdev.c
> > +++ b/fs/nfs/nfs4filelayoutdev.c
> > @@ -185,6 +185,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv,
> struct nfs4_pnfs_ds *ds)
> >  	if (status)
> >  		goto out_put;
> >
> > +	smp_wmb();
> >  	ds->ds_clp = clp;
> >  	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
> >  out:
> > @@ -812,6 +813,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment
> *lseg, u32 ds_idx)
> >  		filelayout_mark_devid_invalid(devid);
> >  		goto out;
> >  	}
> > +	smp_rmb();
> >  	if (ds->ds_clp)
> >  		goto out;
> >
> 
> I noticed that you had patch #2 in this series marked for stable in your for-
> next branch, but this one wasn't. Should this one also go to stable?

Possibly, but so far it remains at the "theoretical problem" level, and not a "fixes a definite bug". The x86_64 architecture doesn't do out-of-order store, so I have problems testing fixes such as this one...

Cheers
  Trond


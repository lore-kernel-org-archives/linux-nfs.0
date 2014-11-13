Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:41630 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753641AbaKMDdT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 22:33:19 -0500
Date: Thu, 13 Nov 2014 14:33:17 +1100
From: Dave Chinner <david@fromorbit.com>
To: Steve French <smfrench@gmail.com>
Cc: Eryu Guan <eguan@redhat.com>, fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        dros@primarydata.com
Subject: Re: [PATCH v2 1/5] common: re-enable tests that require scratch dev
 on NFS
Message-ID: <20141113033317.GC28565@dastard>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com>
 <1414775040-4051-2-git-send-email-eguan@redhat.com>
 <CAH2r5muuJRcC4YgFkwUeUcCeEntgY+4POF8-bwmox64wXykuTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAH2r5muuJRcC4YgFkwUeUcCeEntgY+4POF8-bwmox64wXykuTw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2014 at 12:36:13PM -0600, Steve French wrote:
> On Fri, Oct 31, 2014 at 12:03 PM, Eryu Guan <eguan@redhat.com> wrote:
> > This commit disables tests requires scratch dev running on NFS
> >
> > c041421 xfstests: stop special casing nfs and udf
> >
> > Now re-enable them to get a larger test coverage on NFS.
> >
> > Signed-off-by: Eryu Guan <eguan@redhat.com>
> > ---
> >  common/rc | 22 +++++++++++++++++++---
> >  1 file changed, 19 insertions(+), 3 deletions(-)
> >
> > diff --git a/common/rc b/common/rc
> > index 747cf72..ae03712 100644
> > --- a/common/rc
> > +++ b/common/rc
> > @@ -551,6 +551,14 @@ _mkfs_dev()
> >      rm -f $tmp_dir.mkfserr $tmp_dir.mkfsstd
> >  }
> >
> > +# remove all files in $SCRATCH_MNT, useful when testing on NFS/CIFS
> > +_scratch_cleanup_files()
> > +{
> > +       _scratch_mount
> > +       rm -rf $SCRATCH_MNT/*
> > +       _scratch_unmount
> > +}
>
> There should be a check to make sure SCRATCH_MNT exists before you
> wipe the whole disk ....
> 
> so if no SCRATCH_MNT then this does rm -rf/*
> right ... (and wipes out your whole system ...)

You can't get to that function until after all the checks that
SCRATCH_MNT exists. i.e. this happens during _scratch_mkfs, and that
is only called in tests after all the startup checks validate
devices and mounts exist. i.e. see common/config::get_next_config()

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

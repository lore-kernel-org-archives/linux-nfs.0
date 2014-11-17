Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:47201 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751044AbaKQFl5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 00:41:57 -0500
Date: Mon, 17 Nov 2014 16:41:41 +1100
From: Dave Chinner <david@fromorbit.com>
To: Eryu Guan <eguan@redhat.com>
Cc: Steve French <smfrench@gmail.com>, fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH v2 1/5] common: re-enable tests that require scratch dev
 on NFS
Message-ID: <20141117054141.GK23575@dastard>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com>
 <1414775040-4051-2-git-send-email-eguan@redhat.com>
 <CAH2r5muuJRcC4YgFkwUeUcCeEntgY+4POF8-bwmox64wXykuTw@mail.gmail.com>
 <20141113033317.GC28565@dastard>
 <CAH2r5msD-FDDvUL5Gt+7Fzt-tvduS93sxM-PG9dZjvk0ED53QA@mail.gmail.com>
 <20141115053533.GK2863@dhcp-13-216.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141115053533.GK2863@dhcp-13-216.nay.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 15, 2014 at 01:35:33PM +0800, Eryu Guan wrote:
> On Fri, Nov 14, 2014 at 11:02:50AM -0600, Steve French wrote:
> > On Wed, Nov 12, 2014 at 9:33 PM, Dave Chinner <david@fromorbit.com> wrote:
> > > On Wed, Nov 12, 2014 at 12:36:13PM -0600, Steve French wrote:
> > >> On Fri, Oct 31, 2014 at 12:03 PM, Eryu Guan <eguan@redhat.com> wrote:
> > >> > This commit disables tests requires scratch dev running on NFS
> > >> >
> > >> > c041421 xfstests: stop special casing nfs and udf
> > >> >
> > >> > Now re-enable them to get a larger test coverage on NFS.
> > >> >
> > >> > Signed-off-by: Eryu Guan <eguan@redhat.com>
> > >> > ---
> > >> >  common/rc | 22 +++++++++++++++++++---
> > >> >  1 file changed, 19 insertions(+), 3 deletions(-)
> > >> >
> > >> > diff --git a/common/rc b/common/rc
> > >> > index 747cf72..ae03712 100644
> > >> > --- a/common/rc
> > >> > +++ b/common/rc
> > >> > @@ -551,6 +551,14 @@ _mkfs_dev()
> > >> >      rm -f $tmp_dir.mkfserr $tmp_dir.mkfsstd
> > >> >  }
> > >> >
> > >> > +# remove all files in $SCRATCH_MNT, useful when testing on NFS/CIFS
> > >> > +_scratch_cleanup_files()
> > >> > +{
> > >> > +       _scratch_mount
> > >> > +       rm -rf $SCRATCH_MNT/*
> > >> > +       _scratch_unmount
> > >> > +}
> > >>
> > >> There should be a check to make sure SCRATCH_MNT exists before you
> > >> wipe the whole disk ....
> > >>
> > >> so if no SCRATCH_MNT then this does rm -rf/*
> > >> right ... (and wipes out your whole system ...)
> > >
> > > You can't get to that function until after all the checks that
> > > SCRATCH_MNT exists. i.e. this happens during _scratch_mkfs, and that
> > > is only called in tests after all the startup checks validate
> > > devices and mounts exist. i.e. see common/config::get_next_config()
> > 
> > Well, I reproduced it easily enough again today (after taking a
> > snapshot of the VM)
> > by simply running generic/120 against NFS with SCRATCH_MNT not
> > specified in local.config
> > Dros also ran into this problem.
> 
> You're right, I missed that _scratch_mkfs is also called by ./check,
> and if there's no SCRATCH_MNT set in local.config, only SCRATCH_DEV is
> set, _scratch_mkfs can be dangerous.

As I asked earlier in this thread: why isn't get_next_config()
catching this?

> I propose this patch, which skips _scratch_cleanup_files if called by check
> 
> [root@hp-dl388eg8-01 xfstests]# git diff
> diff --git a/common/rc b/common/rc
> index 435f74f..254fb66 100644
> --- a/common/rc
> +++ b/common/rc
> @@ -554,6 +554,11 @@ _mkfs_dev()
>  # remove all files in $SCRATCH_MNT, useful when testing on NFS/CIFS
>  _scratch_cleanup_files()
>  {
> +       # do nothing if called by check, variables are not fully valided yet
> +       # SCRATCH_MNT can be empty, which is dangerous
> +       if [ "$iam" == "check" ]; then
> +               return
> +       fi

Again, this is the wrong place to try to fix this - we haven't fixed
the landmine that has left us running with an invalid config. IOWs,
by the time _scratch_mkfs is called from *anywhere* we should have
fully validated the environment to be correct and valid. Parsing and
validating the config we have loaded from the config file is the job
of get_next_config(), yes?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

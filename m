Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:43561 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751102AbaKQGzA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 01:55:00 -0500
Date: Mon, 17 Nov 2014 17:54:43 +1100
From: Dave Chinner <david@fromorbit.com>
To: Eryu Guan <eguan@redhat.com>
Cc: Steve French <smfrench@gmail.com>, fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH v2 1/5] common: re-enable tests that require scratch dev
 on NFS
Message-ID: <20141117065443.GL23575@dastard>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com>
 <1414775040-4051-2-git-send-email-eguan@redhat.com>
 <CAH2r5muuJRcC4YgFkwUeUcCeEntgY+4POF8-bwmox64wXykuTw@mail.gmail.com>
 <20141113033317.GC28565@dastard>
 <CAH2r5msD-FDDvUL5Gt+7Fzt-tvduS93sxM-PG9dZjvk0ED53QA@mail.gmail.com>
 <20141115053533.GK2863@dhcp-13-216.nay.redhat.com>
 <20141117054141.GK23575@dastard>
 <20141117060603.GO2863@dhcp-13-216.nay.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141117060603.GO2863@dhcp-13-216.nay.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 17, 2014 at 02:06:03PM +0800, Eryu Guan wrote:
> On Mon, Nov 17, 2014 at 04:41:41PM +1100, Dave Chinner wrote:
> > On Sat, Nov 15, 2014 at 01:35:33PM +0800, Eryu Guan wrote:
> > > On Fri, Nov 14, 2014 at 11:02:50AM -0600, Steve French wrote:
> > > > On Wed, Nov 12, 2014 at 9:33 PM, Dave Chinner <david@fromorbit.com> wrote:
> > > > > On Wed, Nov 12, 2014 at 12:36:13PM -0600, Steve French wrote:
> > > > >> On Fri, Oct 31, 2014 at 12:03 PM, Eryu Guan <eguan@redhat.com> wrote:
> > > > >> > This commit disables tests requires scratch dev running on NFS
> > > > >> >
> > > > >> > c041421 xfstests: stop special casing nfs and udf
> > > > >> >
> > > > >> > Now re-enable them to get a larger test coverage on NFS.
> > > > >> >
> > > > >> > Signed-off-by: Eryu Guan <eguan@redhat.com>
> > > > >> > ---
> > > > >> >  common/rc | 22 +++++++++++++++++++---
> > > > >> >  1 file changed, 19 insertions(+), 3 deletions(-)
> > > > >> >
> > > > >> > diff --git a/common/rc b/common/rc
> > > > >> > index 747cf72..ae03712 100644
> > > > >> > --- a/common/rc
> > > > >> > +++ b/common/rc
> > > > >> > @@ -551,6 +551,14 @@ _mkfs_dev()
> > > > >> >      rm -f $tmp_dir.mkfserr $tmp_dir.mkfsstd
> > > > >> >  }
> > > > >> >
> > > > >> > +# remove all files in $SCRATCH_MNT, useful when testing on NFS/CIFS
> > > > >> > +_scratch_cleanup_files()
> > > > >> > +{
> > > > >> > +       _scratch_mount
> > > > >> > +       rm -rf $SCRATCH_MNT/*
> > > > >> > +       _scratch_unmount
> > > > >> > +}
> > > > >>
> > > > >> There should be a check to make sure SCRATCH_MNT exists before you
> > > > >> wipe the whole disk ....
> > > > >>
> > > > >> so if no SCRATCH_MNT then this does rm -rf/*
> > > > >> right ... (and wipes out your whole system ...)
> > > > >
> > > > > You can't get to that function until after all the checks that
> > > > > SCRATCH_MNT exists. i.e. this happens during _scratch_mkfs, and that
> > > > > is only called in tests after all the startup checks validate
> > > > > devices and mounts exist. i.e. see common/config::get_next_config()
> > > > 
> > > > Well, I reproduced it easily enough again today (after taking a
> > > > snapshot of the VM)
> > > > by simply running generic/120 against NFS with SCRATCH_MNT not
> > > > specified in local.config
> > > > Dros also ran into this problem.
> > > 
> > > You're right, I missed that _scratch_mkfs is also called by ./check,
> > > and if there's no SCRATCH_MNT set in local.config, only SCRATCH_DEV is
> > > set, _scratch_mkfs can be dangerous.
> > 
> > As I asked earlier in this thread: why isn't get_next_config()
> > catching this?
> 
> I think I see the problem, this patch catches the empty SCRATCH_MNT
> and works for me:
> 
> eguan@dhcp-13-216:~/workspace/src/xfstests$ git diff
> diff --git a/common/config b/common/config
> index 1cb08c0..409f1b8 100644
> --- a/common/config
> +++ b/common/config
> @@ -464,7 +464,7 @@ get_next_config() {
>                 exit 1
>         fi
>  
> -       if [ ! -z "$SCRATCH_MNT" -a ! -d "$SCRATCH_MNT" ]; then
> +       if [ ! -z "$SCRATCH_MNT" -o ! -d "$SCRATCH_MNT" ]; then

"if (not an empty string OR not a directory)"

That doesn't work if you define $SCRATCH_MNT - the directory check
fails on an empty string.

As it is, this isn't solving the underlying problem - that "empty
string" check is to avoid failing configs that are not configured
with a scratch device.  i.e. if you define SCRATCH_MNT, it must be a
directory. However, there's no check that if you define SCRATCH_DEV
you've also defined a SCRATCH_MNT...

IOWs, the underlying problem here is that SCRATCH_DEV is defined,
but SCRATCH_MNT is not and we are not catching that issue.  FYI, the
setup script is used for checking these sorts of things.  e.g.  with
an empty config:

$ sudo ./setup
Warning: need to define parameters for host test2
       or set variables:
               TEST_DIR TEST_DEV
$

And you'll note that it catches when we only have one of the two
necessary TEST_D* variables set.  However, even with XFS as the
probe fstyp, it doesn't error out if I don't define a SCRATCH_MNT:

$ sudo TEST_DEV=/dev/vda TEST_DIR=/mnt/test SCRATCH_DEV=/dev/vdb
./setup
TEST: DIR=/mnt/test DEV=/dev/vda rt=[] log=[]
TAPE: dev=[] rmt=[] rmtirix=[@]
SCRATCH: MNT= DEV=/dev/vdb rt=[/dev/vdc] log=[/dev/vdd]
VARIABLES: external=no largeblk=no fstyp=xfs
           large_scratch_dev=no attrsecure=no
$ 

But it should fail with a sane error message indicating that we
caught the invalid config and didn't leave check to fail randomly
wiht some downstream error like:

$ sudo TEST_DEV=/dev/vda TEST_DIR=/mnt/test SCRATCH_DEV=/dev/vdb ./check generic/120
....
check: failed to mount $SCRATCH_DEV using specified options
Passed all 0 tests
$

Another FYI: we can actually test any filesystem without a scratch
device configured:

$ sudo TEST_DEV=/dev/vda TEST_DIR=/mnt/test ./check generic/120
FSTYP         -- xfs (non-debug)
PLATFORM      -- Linux/x86_64 test2 3.18.0-rc2-dgc+

generic/120 16s ... [not run] this test requires a valid $SCRATCH_DEV
Not run: generic/120
Passed all 0 tests
$

So, really, all we need to do is ensure that SCRATCH_DEV/SCRATCH_MNT
are sanely configured...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

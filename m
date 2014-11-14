Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:53052 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933486AbaKNRDN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2014 12:03:13 -0500
MIME-Version: 1.0
In-Reply-To: <20141113033317.GC28565@dastard>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com>
 <1414775040-4051-2-git-send-email-eguan@redhat.com> <CAH2r5muuJRcC4YgFkwUeUcCeEntgY+4POF8-bwmox64wXykuTw@mail.gmail.com>
 <20141113033317.GC28565@dastard>
From: Steve French <smfrench@gmail.com>
Date: Fri, 14 Nov 2014 11:02:50 -0600
Message-ID: <CAH2r5msD-FDDvUL5Gt+7Fzt-tvduS93sxM-PG9dZjvk0ED53QA@mail.gmail.com>
Subject: Re: [PATCH v2 1/5] common: re-enable tests that require scratch dev
 on NFS
To: Dave Chinner <david@fromorbit.com>
Cc: Eryu Guan <eguan@redhat.com>, fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2014 at 9:33 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Wed, Nov 12, 2014 at 12:36:13PM -0600, Steve French wrote:
>> On Fri, Oct 31, 2014 at 12:03 PM, Eryu Guan <eguan@redhat.com> wrote:
>> > This commit disables tests requires scratch dev running on NFS
>> >
>> > c041421 xfstests: stop special casing nfs and udf
>> >
>> > Now re-enable them to get a larger test coverage on NFS.
>> >
>> > Signed-off-by: Eryu Guan <eguan@redhat.com>
>> > ---
>> >  common/rc | 22 +++++++++++++++++++---
>> >  1 file changed, 19 insertions(+), 3 deletions(-)
>> >
>> > diff --git a/common/rc b/common/rc
>> > index 747cf72..ae03712 100644
>> > --- a/common/rc
>> > +++ b/common/rc
>> > @@ -551,6 +551,14 @@ _mkfs_dev()
>> >      rm -f $tmp_dir.mkfserr $tmp_dir.mkfsstd
>> >  }
>> >
>> > +# remove all files in $SCRATCH_MNT, useful when testing on NFS/CIFS
>> > +_scratch_cleanup_files()
>> > +{
>> > +       _scratch_mount
>> > +       rm -rf $SCRATCH_MNT/*
>> > +       _scratch_unmount
>> > +}
>>
>> There should be a check to make sure SCRATCH_MNT exists before you
>> wipe the whole disk ....
>>
>> so if no SCRATCH_MNT then this does rm -rf/*
>> right ... (and wipes out your whole system ...)
>
> You can't get to that function until after all the checks that
> SCRATCH_MNT exists. i.e. this happens during _scratch_mkfs, and that
> is only called in tests after all the startup checks validate
> devices and mounts exist. i.e. see common/config::get_next_config()

Well, I reproduced it easily enough again today (after taking a
snapshot of the VM)
by simply running generic/120 against NFS with SCRATCH_MNT not
specified in local.config
Dros also ran into this problem.

The patch below fixes it for me but it wasn't immediately obvious how to best
return info to the user (ie print messages that make sense here -
"echo" seems to be supressed
in common/rc and notrun exits and logs it to a file but not to the
screen in this case)

sfrench@ubuntu:~/xfstests$ git diff -a
diff --git a/common/rc b/common/rc
index d5e3aff..866244b 100644
--- a/common/rc
+++ b/common/rc
@@ -555,6 +555,9 @@ _mkfs_dev()
 _scratch_cleanup_files()
 {
        _scratch_mount
+       if ! [ "$SCRATCH_MNT" ]; then
+               _notrun "this test requires a \$SCRATCH_MNT to be specified"
+       fi
        rm -rf $SCRATCH_MNT/*
        _scratch_unmount
 }


-- 
Thanks,

Steve

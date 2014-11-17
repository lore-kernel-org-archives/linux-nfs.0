Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:9564 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751521AbaKQUWN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 15:22:13 -0500
Date: Tue, 18 Nov 2014 07:22:07 +1100
From: Dave Chinner <david@fromorbit.com>
To: Omer Zilberberg <omzg@plexistor.com>
Cc: Eryu Guan <eguan@redhat.com>, Steve French <smfrench@gmail.com>,
        fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH v2 1/5] common: re-enable tests that require scratch dev
 on NFS
Message-ID: <20141117202207.GN23575@dastard>
References: <1414775040-4051-1-git-send-email-eguan@redhat.com>
 <1414775040-4051-2-git-send-email-eguan@redhat.com>
 <CAH2r5muuJRcC4YgFkwUeUcCeEntgY+4POF8-bwmox64wXykuTw@mail.gmail.com>
 <20141113033317.GC28565@dastard>
 <CAH2r5msD-FDDvUL5Gt+7Fzt-tvduS93sxM-PG9dZjvk0ED53QA@mail.gmail.com>
 <20141115053533.GK2863@dhcp-13-216.nay.redhat.com>
 <20141117054141.GK23575@dastard>
 <20141117060603.GO2863@dhcp-13-216.nay.redhat.com>
 <20141117065443.GL23575@dastard>
 <546A0BFE.6080608@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <546A0BFE.6080608@plexistor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 17, 2014 at 04:53:50PM +0200, Omer Zilberberg wrote:
> > Another FYI: we can actually test any filesystem without a scratch
> > device configured:
> > 
> > $ sudo TEST_DEV=/dev/vda TEST_DIR=/mnt/test ./check generic/120
> > FSTYP         -- xfs (non-debug)
> > PLATFORM      -- Linux/x86_64 test2 3.18.0-rc2-dgc+
> > 
> > generic/120 16s ... [not run] this test requires a valid $SCRATCH_DEV
> > Not run: generic/120
> > Passed all 0 tests
> > $
> 
> Please note that since commit 83ef157d, that is no longer true, because _require_test calls _is_block_dev with empty parameter, which prints usage:
> $ sudo TEST_DEV=/dev/sda TEST_DIR=/mnt/dev0  ./check generic/001
> FSTYP         -- ext4
> PLATFORM      -- Linux/x86_64 testvm 3.17.0
> 
> generic/001 7s ... - output mismatch (see /opt/xfstests/results//generic/001.out.bad)
>     --- tests/generic/001.out   2014-09-10 11:04:44.249185592 +0300
>     +++ /opt/xfstests/results//generic/001.out.bad      2014-11-17 15:14:12.380061760 +0200
>     @@ -1,4 +1,5 @@
>      QA output created by 001
>     +Usage: _is_block_dev dev
>      cleanup
>      setup ....................................
>      iter 1 chain ... check ....................................
>     ...
>     (Run 'diff -u tests/generic/001.out /opt/xfstests/results//generic/001.out.bad'  to see the entire diff)
> Ran: generic/001
> Failures: generic/001
> Failed 1 of 1 tests
> 
> Here's a patch to fix that:
> ----
> Subject: [PATCH] _required_test: removed unneeded test for scratch_dev
> 
> testing for scratch_dev in _required_test is unnecessary, since it is
> not required for these tests. Furthermore, if a scratch_dev is not given,
> all tests which are supposed to pass on test_dev fail, because
> _is_block_dev is given an empty string as scratch_dev, and prints usage.

I'm beginning to sound like a broken record. Why isn't this *invalid
config check* being done in the config parsing rather than on every
test that requires a scratch or test device?

i.e. removing the check is not the correct fix - checking it during
config parsing means none of these checks need to be done in
_require_test, nor in _require_scratch_nocheck.

i.e. in get_next_config() we already know the FSTYP, so we should
be checking that:

	a) TEST_DEV is valid for fstyp
	b) SCRATCH_DEV (if configured) is valid for fstyp
	c) TEST_DEV != SCRATCH_DEV if they both exist and fstyp
	   indicates they should be block devices

And then we can pretty much assume that they are valid everywhere
else, and _require_scratch_nocheck() simply needs to check for a
non-empty string...

> Signed-off-by: Omer Zilberberg <omzg@plexistor.com>
> ---
>  common/rc | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/common/rc b/common/rc
> index d5e3aff..b863808 100644
> --- a/common/rc
> +++ b/common/rc
> @@ -1104,7 +1104,7 @@ _require_scratch()
>  }
>  
>  
> -# this test needs a test partition - check we're ok & unmount it
> +# this test needs a test partition - check we're ok & mount if necessary
>  #
>  _require_test()
>  {
> @@ -1138,10 +1138,6 @@ _require_test()
>                  then
>                      _notrun "this test requires a valid \$TEST_DEV"
>                  fi
> -                if [ "`_is_block_dev $SCRATCH_DEV`" = "`_is_block_dev $TEST_DEV`" ]
> -                then
> -                    _notrun "this test requires a valid \$TEST_DEV"
> -                fi
>                 if [ ! -d "$TEST_DIR" ]
>                 then
>                      _notrun "this test requires a valid \$TEST_DIR"

The patch is whitespace damaged. Please read:

https://www.kernel.org/doc/Documentation/email-clients.txt

and resend.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f47.google.com ([74.125.82.47]:63922 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbaKQOxz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 09:53:55 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so2835027wgh.6
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 06:53:54 -0800 (PST)
Message-ID: <546A0BFE.6080608@plexistor.com>
Date: Mon, 17 Nov 2014 16:53:50 +0200
From: Omer Zilberberg <omzg@plexistor.com>
MIME-Version: 1.0
To: Dave Chinner <david@fromorbit.com>, Eryu Guan <eguan@redhat.com>
CC: Steve French <smfrench@gmail.com>, fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH v2 1/5] common: re-enable tests that require scratch dev
 on NFS
References: <1414775040-4051-1-git-send-email-eguan@redhat.com> <1414775040-4051-2-git-send-email-eguan@redhat.com> <CAH2r5muuJRcC4YgFkwUeUcCeEntgY+4POF8-bwmox64wXykuTw@mail.gmail.com> <20141113033317.GC28565@dastard> <CAH2r5msD-FDDvUL5Gt+7Fzt-tvduS93sxM-PG9dZjvk0ED53QA@mail.gmail.com> <20141115053533.GK2863@dhcp-13-216.nay.redhat.com> <20141117054141.GK23575@dastard> <20141117060603.GO2863@dhcp-13-216.nay.redhat.com> <20141117065443.GL23575@dastard>
In-Reply-To: <20141117065443.GL23575@dastard>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Another FYI: we can actually test any filesystem without a scratch
> device configured:
> 
> $ sudo TEST_DEV=/dev/vda TEST_DIR=/mnt/test ./check generic/120
> FSTYP         -- xfs (non-debug)
> PLATFORM      -- Linux/x86_64 test2 3.18.0-rc2-dgc+
> 
> generic/120 16s ... [not run] this test requires a valid $SCRATCH_DEV
> Not run: generic/120
> Passed all 0 tests
> $

Please note that since commit 83ef157d, that is no longer true, because _require_test calls _is_block_dev with empty parameter, which prints usage:
$ sudo TEST_DEV=/dev/sda TEST_DIR=/mnt/dev0  ./check generic/001
FSTYP         -- ext4
PLATFORM      -- Linux/x86_64 testvm 3.17.0

generic/001 7s ... - output mismatch (see /opt/xfstests/results//generic/001.out.bad)
    --- tests/generic/001.out   2014-09-10 11:04:44.249185592 +0300
    +++ /opt/xfstests/results//generic/001.out.bad      2014-11-17 15:14:12.380061760 +0200
    @@ -1,4 +1,5 @@
     QA output created by 001
    +Usage: _is_block_dev dev
     cleanup
     setup ....................................
     iter 1 chain ... check ....................................
    ...
    (Run 'diff -u tests/generic/001.out /opt/xfstests/results//generic/001.out.bad'  to see the entire diff)
Ran: generic/001
Failures: generic/001
Failed 1 of 1 tests

Here's a patch to fix that:
----
Subject: [PATCH] _required_test: removed unneeded test for scratch_dev

testing for scratch_dev in _required_test is unnecessary, since it is
not required for these tests. Furthermore, if a scratch_dev is not given,
all tests which are supposed to pass on test_dev fail, because
_is_block_dev is given an empty string as scratch_dev, and prints usage.

Signed-off-by: Omer Zilberberg <omzg@plexistor.com>
---
 common/rc | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/common/rc b/common/rc
index d5e3aff..b863808 100644
--- a/common/rc
+++ b/common/rc
@@ -1104,7 +1104,7 @@ _require_scratch()
 }
 
 
-# this test needs a test partition - check we're ok & unmount it
+# this test needs a test partition - check we're ok & mount if necessary
 #
 _require_test()
 {
@@ -1138,10 +1138,6 @@ _require_test()
                 then
                     _notrun "this test requires a valid \$TEST_DEV"
                 fi
-                if [ "`_is_block_dev $SCRATCH_DEV`" = "`_is_block_dev $TEST_DEV`" ]
-                then
-                    _notrun "this test requires a valid \$TEST_DEV"
-                fi
                if [ ! -d "$TEST_DIR" ]
                then
                     _notrun "this test requires a valid \$TEST_DIR"
-- 
1.9.3

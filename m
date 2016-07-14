Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57054 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbcGNC1e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2016 22:27:34 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 14 Jul 2016 12:26:43 +1000
Subject: [PATCH 0/8] Assorted mount-related nfs-utils patches.
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <20160714021310.5874.22953.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series is an assortment of mount-related things.

1/ resend the manpage update for "retry=" that I sent a while
   back, but messed up
2/ remove a meaningless option from mountd.
3/ Fix up support for the "mountpoint" export option in mountd,
   particularly making it work sensibly with NFSv4
4/ temporary hostname failure should be treated by mount.nfs
   as a temporary condition
5/ Avoid advertising a temporary IPv6 address for NFSv4.0 callback.

That last point needs a kernel fix too, but I'm not sure what is best
yet.

If you have IPv6 privacy extensions enabled, then the default
address for outgoing connections is a temporary address which
becomes "deprecated" after a period of time, when another address will
become available for use.  A while later the deprecated address becomes
invalid, and will stop working.
So if a connection is held open for longer than the "valid lifetime"
(valid_lft in "ip -6 addr" output) it will stop working, which isn't
what users will expect.

We could possibly close and re-open the connection after the address
becomes deprecated.  Or we could insist on a 'public' address when
establishing the connection.  Thoughts?

When setting the call-back address for NFSv4.0, using a public address
is the only real option, so that is what this patch does.

Thanks,
NeilBrown

---

NeilBrown (8):
      nfs.man: clarify effect of 'retry' option.
      mountd: remove the --exports-file option
      mountd: remove 'dev_missing' checks
      mountd: cause attempts to access unmounted exportpoints to return ESTALE
      mountd: Don't export unmounted exports to NFSv4
      mountd: don't add paths to non-mounted export points to pseudo-root
      mount: don't treat temporary name resolution failure as permanent.
      mount: use a public address for IPv6 callback.


 support/include/v4root.h |    2 +-
 utils/mount/network.c    |    5 ++++
 utils/mount/nfs.man      |   14 ++++++++++--
 utils/mount/stropts.c    |   54 ++++++++++++++++++++++++++--------------------
 utils/mountd/auth.c      |   34 ++++++++++++++++++++++++-----
 utils/mountd/cache.c     |   36 ++++++++++++++-----------------
 utils/mountd/mountd.c    |   11 +++------
 utils/mountd/mountd.h    |    2 +-
 utils/mountd/mountd.man  |    8 -------
 utils/mountd/v4root.c    |   11 +++++++++
 10 files changed, 107 insertions(+), 70 deletions(-)

--
Signature


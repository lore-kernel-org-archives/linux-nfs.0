Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:62556 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbaHSSuA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 14:50:00 -0400
Received: by mail-qc0-f179.google.com with SMTP id m20so6575721qcx.24
        for <linux-nfs@vger.kernel.org>; Tue, 19 Aug 2014 11:49:56 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/7] nfs-utils: support for lifting grace period early
Date: Tue, 19 Aug 2014 14:49:42 -0400
Message-Id: <1408474189-14491-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset adds some support to sm-notify and nfsdcltrack for lifting
the grace periods early. Allowing this to actually work depends on the
companion kernel patchset, but the approach I've taken here should deal
properly with userland/kernel mismatches.

There are two main pieces:

sm-notify: in the event that sm-notify isn't sending any NOTIFY
requests, we don't expect to see any reclaims from clients. In that
case, we should be able to safely lift the lockd grace period early.
The first patch in the series implements this (though we'll probably
need a bit of selinux work to get that working in Fedora under enforcing
mode).

nfsdcltrack: if there are no v4.0 clients and all v4.1+ clients have
issued a RECLAIM_COMPLETE, then we can go ahead and end the nfsd grace
period. The remainder of the patchset adds the support for this. This
requires revving the DB schema for it, and making use of the environment
variables that are passed to the upcall by the kernel.

With an updated kernel and nfs-utils, I typically see the grace period
being lifted just a few seconds after it starts. It may take a little
longer with more clients, but this is a vast improvement over having
to wait 90s after each reboot to get meaningful work done.

Assuming that the kernel parts are acceptable to Bruce et. al., then I
think we'll want this merged around the same time.

Jeff Layton (7):
  sm-notify: inform the kernel if there were no hosts to notify
  nfsdcltrack: update comments in sqlite.c
  nfsdcltrack: rename CLD_* constants with CLTRACK_* prefixes
  nfsdcltrack: overhaul database initializtion
  nfsdcltrack: update schema to v2
  nfsdcltrack: grab the client minorversion from the env var if it's
    present
  nfsdcltrack: fetch NFSDCLTRACK_GRACE_START out of environment

 utils/nfsdcltrack/nfsdcltrack.c | 106 +++++++++++-
 utils/nfsdcltrack/sqlite.c      | 375 ++++++++++++++++++++++++++++++----------
 utils/nfsdcltrack/sqlite.h      |   5 +-
 utils/statd/sm-notify.c         |  25 +++
 4 files changed, 413 insertions(+), 98 deletions(-)

-- 
1.9.3


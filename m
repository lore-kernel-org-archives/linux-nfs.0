Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:64488 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbaHOOpX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 10:45:23 -0400
Received: by mail-qc0-f172.google.com with SMTP id i8so2413235qcq.31
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 07:45:22 -0700 (PDT)
Received: from tlielax.poochiereds.net ([2001:470:8:d63:3a60:77ff:fe93:a95d])
        by mx.google.com with ESMTPSA id t107sm3989900qgt.28.2014.08.15.07.45.20
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Aug 2014 07:45:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 0/7] nfs-utils: support for lifting grace period early
Date: Fri, 15 Aug 2014 10:45:08 -0400
Message-Id: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset adds some support to sm-notify and nfsdcltrack for lifting
the grace periods early. Allowing this actually work depends on the
companion kernel patchset, but the approach I've taken here should deal
properly with userland/kernel mismatch.

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

Again, this is just an RFC set for now. Does anyone have thoughts or
comments on the general approach?

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


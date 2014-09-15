Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:65083 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbaIOOBP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 10:01:15 -0400
Received: by mail-qa0-f44.google.com with SMTP id w8so3751700qac.17
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 07:01:14 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/7] nfs-utils: support for lifting grace period early
Date: Mon, 15 Sep 2014 10:00:58 -0400
Message-Id: <1410789665-19745-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v4:
- replace "reclaim_complete" timestamp column with "has_session" boolean
- change to use NFSDCLTRACK_CLIENT_HAS_SESSION environment variable
- only set timestamp on "has_session" clients during "create" op

v3:
- account for change to NFSDCLTRACK_RECLAIM_COMPLETE env var

This is v4 of the patchset to allow the lifting of the grace period
early. The changes in this set are a bit more substantial than the kernel
piece.

Last week Bruce noted that we have an existing bug in how nfsdcltrack
works with v4.1+ clients. It updates the timestamp for v4.1+ clients
on a "check" operation, which can lead to the server handing out
conflicting locks if the v4.1+ client never sends a RECLAIM_COMPLETE.

To fix this, the program must be able to distingush between v4.0 and
v4.1+ clients during both the create and check operations. This set adds
the ability for it to do so by looking for the correct environment
variables as passed by the kernel.

Historically, nfsdcltrack has not distinguished between v4.0 and v4.1+
clients at alli and has basically applied the v4.0 rules to all clients.
On a DB upgrade, the kernel assumes that all clients are v4.0. Once
the kernel sends a "create" upcall that indicates that it's a v4.1
client it will update the DB accordingly.

Thus, fixing the bug that Bruce spotted requires both an updated
nfs-utils and kernel. With only one or the other, things should
basically work as they have so far (with all clients being treated
as v4.0 clients).

Jeff Layton (7):
  sm-notify: inform the kernel if there were no hosts to notify
  nfsdcltrack: update comments in sqlite.c
  nfsdcltrack: rename CLD_* constants with CLTRACK_* prefixes
  nfsdcltrack: overhaul database initializtion
  nfsdcltrack: update schema to v2
  nfsdcltrack: grab the NFSDCLTRACK_CLIENT_HAS_SESSION env var if it's
    present
  nfsdcltrack: fetch NFSDCLTRACK_GRACE_START out of environment

 utils/nfsdcltrack/nfsdcltrack.c | 103 ++++++++++-
 utils/nfsdcltrack/sqlite.c      | 388 ++++++++++++++++++++++++++++++----------
 utils/nfsdcltrack/sqlite.h      |   8 +-
 utils/statd/sm-notify.c         |  25 +++
 4 files changed, 421 insertions(+), 103 deletions(-)

-- 
1.9.3


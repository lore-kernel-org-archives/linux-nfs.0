Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:33182 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261AbcDNMhM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2016 08:37:12 -0400
Received: by mail-qg0-f52.google.com with SMTP id j35so61697305qge.0
        for <linux-nfs@vger.kernel.org>; Thu, 14 Apr 2016 05:37:12 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/8] nfs/sunrpc: fix flexfiles credential handling
Date: Thu, 14 Apr 2016 08:36:57 -0400
Message-Id: <1460637425-1580-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The way that credentials are handled in the flexfiles client is
currently wrong. It only keeps one set of credentials per mirror object,
but those objects can be shared between read and rw layout segments
If the server hands out different credentials for read and rw layouts,
then you can end up in a situation where the client will end up issuing
writes with the wrong uid.

This is visible by simply mounting a server that does hand out different
creds for ro vs. rw layouts, opening the file for read, then opening it
for write, and then issuing a write. At that point, the DS write calls
will fail with EACCES. The client will then re-fetch the layout, but the
creds are not updated, so the writes still fail. The client is then
stuck at that point. This problem also means that the client is unable
to recover after a layout is fenced, since the creds are never updated.

This patchset cleans up some ugliness in how flexfiles rpc_creds are
handled, adds a place to keep ro and rw creds per mirror, and allows
those creds to be updated when a LAYOUTGET response contains different
ones.

We start with a few sunrpc patches that lay the groundwork to allow the
creds to be accessible via RCU and to fix up a current wart where we can
end up doing a GFP_KERNEL allocation while in a possible memory reclaim
scenario. The flexfiles code is then changed to allow the creds to be
swapped out as credential updates come in. The users of those creds then
ensure that they take references to them in case they are swapped out,
and put those references after the calls are dispatched.

Only lightly tested so far (cthon and fstests) but it does fix the
original problem.

Jeff Layton (7):
  sunrpc: allow generic_match to handle creds with NULL group_info ptr
  sunrpc: plumb gfp_t parm into crcreate operation
  sunrpc: add a get_rpccred_rcu inline
  nfs: don't call nfs4_ff_layout_prepare_ds from ff_layout_get_ds_cred
  nfs: have ff_layout_get_ds_cred take a reference to the cred
  nfs: get a reference to the credential in ff_layout_alloc_lseg
  nfs: have flexfiles mirror keep creds for both ro and rw layouts

Weston Andros Adamson (1):
  sunrpc: add rpc_lookup_generic_cred

 fs/nfs/flexfilelayout/flexfilelayout.c    | 59 ++++++++++++++++++-----
 fs/nfs/flexfilelayout/flexfilelayout.h    |  5 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 78 +++++++++++--------------------
 include/linux/sunrpc/auth.h               | 23 ++++++++-
 net/sunrpc/auth.c                         |  4 +-
 net/sunrpc/auth_generic.c                 | 22 ++++++---
 net/sunrpc/auth_gss/auth_gss.c            |  6 +--
 net/sunrpc/auth_unix.c                    |  6 +--
 8 files changed, 122 insertions(+), 81 deletions(-)

-- 
2.5.5


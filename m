Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:43164 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755681Ab2KIUGw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 15:06:52 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so4276477vbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2012 12:06:50 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 0/7] nfsd: limit the use of md5 hashes in nfsdv4 code
Date: Fri,  9 Nov 2012 15:06:37 -0500
Message-Id: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

knfsd has historically used md5 hashes as a way to turn nfs_client_id4
blobs into printable strings. It mainly does this to make directories in
the v4recoverydir, but it also uses those strings as part of a scheme to
pick a hash bucket for tracking it.

The choice of md5 here turns out to be problematic. We have customers
that would like to be able to use knfsd while booted in FIPS mode, but
serving v4 currently falls down because those algorithms are proscribed.

This patchset is a first pass at making md5 hashing less necessary.
Clearly, we *do* need md5 hashes for the legacy client tracking code.
But, if someone is using nfsdcltrack, for instance it's not strictly
necessary.

With this patchset it also ought to be possible to support v4 serving
with the legacy tracker, even if md5 is unavailable. Reclaiming won't
work correctly of course, but you'll be able to serve NFSv4 without
that.

This code builds and I've done some rudimentary testing on it that
indicates that it works. It needs more testing, so consider this an RFC.
This patchset is based on the 4 patches that add the nfsdcltrack
recovery tracker.

The code is also available here in my nfsd-3.8 branch:

    http://git.samba.org/?p=jlayton/linux.git;a=shortlog;h=refs/heads/nfsd-3.8

Jeff Layton (7):
  nfsd: remove unused argument to nfs4_has_reclaimed_state
  nfsd: have nfsd4_find_reclaim_client take a char * argument
  nfsd: break out reclaim record removal into separate function
  nfsd: make nfs4_client_to_reclaim return a pointer to the reclaim
    record
  nfsd: don't search for client by hash on legacy reboot recovery
    gracedone
  nfsd: move the confirmed and unconfirmed hlists to a rbtree
  nfsd: get rid of cl_recdir field

 fs/nfsd/nfs4recover.c |  75 +++++++++++++-----
 fs/nfsd/nfs4state.c   | 207 +++++++++++++++++++++++++++++---------------------
 fs/nfsd/state.h       |  14 ++--
 3 files changed, 183 insertions(+), 113 deletions(-)

-- 
1.7.11.7


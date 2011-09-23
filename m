Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995Ab1IWQZ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 12:25:29 -0400
From: David Howells <dhowells@redhat.com>
Subject: [RFC][PATCH 0/7] Automount behaviour correction
To: miklos@szeredi.hu, raven@themaw.net, viro@ZenIV.linux.org.uk,
        torvalds@linux-foundation.org
Cc: dhowells@redhat.com, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Date: Fri, 23 Sep 2011 17:24:38 +0100
Message-ID: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



Here are a set of patches to correct the behaviour of automounting, hopefully
without introducing extra fragility.  We might want to merge them together in
various ways, and the last one or two patches we may want to drop, depending on
what we actually want the behaviour to actually be.

They are:

 (1) Revert Miklos's patch.  Not strictly a necessary part of the series, but
     it does fix the NFS4 regression immediately.

 (2) Make chown and lchown jump to fchownat with appropriate flags.  This is a
     useful cleanup for the following patches.

 (3) Replace LOOKUP_NO_AUTOMOUNT with LOOKUP_AUTOMOUNT and set it where
     appropriate before calling pathwalk (usually when we'd be setting
     LOOKUP_FOLLOW).  This just switches the polarity of the flag.

 (4) Move the automount/no-automount policy to the callers of pathwalk so that
     things such as NFS4 don't get caught out by changes to the policy.  The
     policy is outlined in that patch header.

 (5) Remove the logic from follow_automount() to try and guess from the
     LOOKUP_* flags whether or not we should be automounting this time.  It's
     shown to be a bit fragile and the policy is better predetermined by this
     point.

 (6) Make stat and xattr unconditionally _not_ automount.  This reinstates the
     old autofs behaviour, but does then regress NFS, AFS and CIFS.

 (7) Make stat and xattr vary their behaviour depending on whether the
     automount point belongs to autofs or not.  This should reinstate the NFS,
     AFS and CIFS behaviour without regressing autofs.

Now if we want 6 and maybe 7, these can be rolled into 4.  Patch 1 can be
discarded entirely if 5 is taken.

David
---
David Howells (7):
      VFS: Vary the automounting rules for autofs
      VFS: Make stat and xattr calls not automount
      VFS: Ignore symlink following advice when pathwalking
      VFS: Move the automount suppression decision out to the initial callers of
      VFS: Change LOOKUP_NO_AUTOMOUNT to LOOKUP_AUTOMOUNT
      VFS: Make chown() and lchown() call fchownat()
      NFS4: Revert commit to make the automount code ignore LOOKUP_FOLLOW


 drivers/mtd/ubi/build.c            |    2 +
 drivers/mtd/ubi/kapi.c             |    2 +
 fs/autofs4/dev-ioctl.c             |    2 +
 fs/block_dev.c                     |    2 +
 fs/configfs/symlink.c              |    2 +
 fs/ecryptfs/main.c                 |    2 +
 fs/exec.c                          |    5 ++-
 fs/fhandle.c                       |   11 +++----
 fs/gfs2/ops_fstype.c               |    2 +
 fs/internal.h                      |   24 +++++++++++++++
 fs/namei.c                         |   30 ++++++-------------
 fs/namespace.c                     |    8 +++--
 fs/nfs/super.c                     |    2 +
 fs/nfsd/nfs4state.c                |    2 +
 fs/notify/fanotify/fanotify_user.c |    2 +
 fs/notify/inotify/inotify_user.c   |    2 +
 fs/open.c                          |   57 +++++++++---------------------------
 fs/quota/quota.c                   |    2 +
 fs/stat.c                          |   20 ++++++-------
 fs/statfs.c                        |    2 +
 fs/utimes.c                        |   14 ++++-----
 fs/xattr.c                         |   24 ++++++++++-----
 include/linux/fcntl.h              |    1 +
 include/linux/namei.h              |   10 ++++--
 net/unix/af_unix.c                 |    2 +
 security/tomoyo/load_policy.c      |    2 +
 security/tomoyo/mount.c            |    3 +-
 27 files changed, 116 insertions(+), 121 deletions(-)


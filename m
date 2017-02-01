Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37296 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751096AbdBAPTa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Feb 2017 10:19:30 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: neilb@suse.com, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 0/2] Add support for -s/--state-directory-path for rpc.mountd and exportfs
Date: Wed,  1 Feb 2017 10:19:27 -0500
Message-Id: <1485962369-25852-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, rpc.mountd's -s/--state-directory-path option doesn't really
do anything (rpc.mountd tests it via chdir() but that's all).  These
patches implement the -s/--state-directory-path option so that
rpc.mountd's state files (the etab and rmtab) can be placed in a
location other than /var/lib/nfs... for example, /run/nfs.

To use /run/nfs, it's necessary to create a systemd-tmpfiles config
file, e.g.

# cat /usr/lib/tmpfiles.d/nfs.conf 
#Type Path           Mode  UID  GID  Age Argument
d    /run/nfs        0755  root root  -  -
f    /run/nfs/etab   0644  root root  -  -
f    /run/nfs/rmtab  0644  root root  -  -

and if selinux is in enforcing mode, the correct context would need to
be set on the directory (On Fedora, semanage barks at me if I use
/run/nfs... that's why I'm using /var/run/nfs here instead):

# semanage fcontext -a -t var_lib_nfs_t "/var/run/nfs(/.*)?"

Changes since v1:

- Replaced all newly-added occurrences of the term 'xtab' so it wouldn't
  be confused with the recently removed 'xtab' file.  I did not replace
  any existing uses of the term 'xtab' though.
- Removed the reference to statd on the mountd man page.

Scott Mayhew (2):
  libnsm.a: refactor nsm_setup_pathnames() and nsm_make_pathname()
  mountd/exportfs: implement the -s/--state-directory-path option

 support/export/xtab.c     |  82 +++++++++++++++++++++++++++++++++-
 support/include/misc.h    |   3 ++
 support/include/nfslib.h  |  17 +++++++
 support/misc/Makefile.am  |   2 +-
 support/misc/file.c       | 110 ++++++++++++++++++++++++++++++++++++++++++++++
 support/nfs/cacheio.c     |   4 +-
 support/nfs/rmtab.c       |   4 +-
 support/nsm/file.c        |  45 ++-----------------
 utils/exportfs/exportfs.c |  13 ++++++
 utils/mountd/auth.c       |   8 ++--
 utils/mountd/mountd.c     |  31 ++++++++-----
 utils/mountd/mountd.man   |   2 +-
 utils/mountd/rmtab.c      |  26 ++++++-----
 utils/statd/Makefile.am   |   1 +
 14 files changed, 274 insertions(+), 74 deletions(-)
 create mode 100644 support/misc/file.c

-- 
2.7.4


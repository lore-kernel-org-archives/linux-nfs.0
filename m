Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47862 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754108AbdA3TdK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Jan 2017 14:33:10 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: neilb@suse.com, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH RFC 0/2] Add support for -s/--state-directory-path for rpc.mountd and exportfs
Date: Mon, 30 Jan 2017 14:32:47 -0500
Message-Id: <1485804769-14393-1-git-send-email-smayhew@redhat.com>
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
# semanage fcontext -a -t var_lib_nfs_t /var/run/nfs

Notes:

- I didn't actually implement the option (in either the command line or
the nfs.conf) for exportfs.  Instead it reads rpc.mountd's setting from
the nfs.conf so that they're using the same value.  Maybe it would be
better to add the option to exportfs too and emit a warning if exportfs
is using a different value than rpc.mountd (which would only be
detectable if mountd is using the nfs.conf).
- Since the contents of /run are volatile, moving the rmtab file there
would mean 'showmount -a' would only show NFSv3 mounts that have occurred
since the last boot.  I'm not sure if that's a big deal or not.  Looking
at the rmtab file on my main test server I see a lot of outdated
entries, so this might actually be preferable.
- Looking at rpc.mountd(8) it actually says 'Specify a directory in which
to place statd state information'... I'm not sure why mountd would care
where statd puts its state files.  The point of these two patches was to
separate that out, so that all that's left on /var/lib/nfs is the stuff
used by rpc.statd/sm-notify/nfsdcltrack.  I can either use a different
option or reword that sentence on the man page.


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
 utils/mountd/rmtab.c      |  26 ++++++-----
 utils/statd/Makefile.am   |   1 +
 13 files changed, 273 insertions(+), 73 deletions(-)
 create mode 100644 support/misc/file.c

-- 
2.7.4


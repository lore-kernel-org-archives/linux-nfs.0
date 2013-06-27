Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f42.google.com ([209.85.213.42]:55476 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab3F0Tyr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 15:54:47 -0400
Received: by mail-yh0-f42.google.com with SMTP id c41so649182yho.15
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 12:54:46 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        Weston.Adamson@netapp.com
Subject: [PATCH v4 0/4] nfs: teach NFSv3 mount code to try each authflavor in turn
Date: Thu, 27 Jun 2013 15:54:37 -0400
Message-Id: <1372362881-32282-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes:
v4:
- fake up server list in nfs_mount rather than in nfs_try_mount_request.
  This simplifies the auth selection code by allowing it to always
  assume that it has a non-empty authlist from the mount request.

v3:
- fix some signed vs. unsigned type comparisons
- change how an empty server_authlist is handled. Instead of picking an
  authflavor to try at that point, just munge the list to contain only
  RPC_AUTH_NULL. The rest of the logic can take over at that point.

I got a report of a regression in recent kernels. Windows 2012 servers
support v3 and v4.1. They also return a list of authflavors that starts
with AUTH_GSS flavors and ends with AUTH_SYS.

Since commit 4580a92 (NFS: Use server-recommended security flavor by
default (NFSv3)) mounting this server with nfsv3 fails unless you
specify sec=sys. I can replicate the problem with a Linux NFS server
by exporing a filesystem with "sec=krb5:sys".

This patchset overhauls the NFSv3 auth code to try each authflavor in
the list provided by the server in the order that it specified them.
With this, I'm again able to mount the server without needing any
special mount options.

Thanks to Chuck Lever for suggestions thus far...

Jeff Layton (4):
  nfs: refactor "need_mount" code out of nfs_try_mount
  nfs: move server_authlist into nfs_try_mount_request
  nfs: have nfs_mount fake up a auth_flavs list when the server didn't
    provide it
  nfs: have NFSv3 try server-specified auth flavors in turn

 fs/nfs/mount_clnt.c |  18 +++++-
 fs/nfs/super.c      | 175 ++++++++++++++++++++++++++++------------------------
 2 files changed, 110 insertions(+), 83 deletions(-)

-- 
1.8.1.4


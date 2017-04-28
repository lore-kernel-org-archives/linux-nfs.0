Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33972 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937334AbdD1RZj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Apr 2017 13:25:39 -0400
Received: by mail-io0-f196.google.com with SMTP id h41so12712973ioi.1
        for <linux-nfs@vger.kernel.org>; Fri, 28 Apr 2017 10:25:39 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 0/5] Fun with the multipathing code
Date: Fri, 28 Apr 2017 13:25:30 -0400
Message-Id: <20170428172535.7945-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the spirit of experimentation, I've put together a set of patches
that implement setting up multiple TCP connections to the server.
The connections all go to the same server IP address, so do not
provide support for multiple IP addresses (which I believe is
something Andy Adamson is working on).

The feature is only enabled for NFSv4.1 and NFSv4.2 for now; I don't
feel comfortable subjecting NFSv3/v4 replay caches to this
treatment yet. It relies on the mount option "nconnect" to specify
the number of connections to st up. So you can do something like
  'mount -t nfs -overs=4.1,nconnect=8 foo:/bar /mnt'
to set up 8 TCP connections to server 'foo'.

Anyhow, feel free to test and give me feedback as to whether or not
this helps performance on your system.

Trond Myklebust (5):
  SUNRPC: Allow creation of RPC clients with multiple connections
  NFS: Add a mount option to specify number of TCP connections to use
  NFSv4: Allow multiple connections to NFSv4.x (x>0) servers
  pNFS: Allow multiple connections to the DS
  NFS: Display the "nconnect" mount option if it is set.

 fs/nfs/client.c             |  2 ++
 fs/nfs/internal.h           |  2 ++
 fs/nfs/nfs3client.c         |  3 +++
 fs/nfs/nfs4client.c         | 13 +++++++++++--
 fs/nfs/super.c              | 12 ++++++++++++
 include/linux/nfs_fs_sb.h   |  1 +
 include/linux/sunrpc/clnt.h |  1 +
 net/sunrpc/clnt.c           | 17 ++++++++++++++++-
 net/sunrpc/xprtmultipath.c  |  3 +--
 9 files changed, 49 insertions(+), 5 deletions(-)

-- 
2.9.3


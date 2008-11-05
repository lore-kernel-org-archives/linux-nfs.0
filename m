From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] Support for "resvport" NFS mount option
Date: Wed, 05 Nov 2008 15:24:43 -0500
Message-ID: <20081105202040.14469.32458.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:42919 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbYKEUZF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 15:25:05 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

I proposed a new mount option called "resvport" a few months back to make sure
that the NFS client has a mechanism for using unprivileged source ports that
doesn't break other in-kernel RPC consumers.

Here's a patch set that implements "resvport" that could be merged in 2.6.29.
It may require some of my earlier patches to apply cleanly to 2.6.28-rc3, but
this should give you enough of an idea how I'm approaching this so far.

---

Chuck Lever (8):
      NLM: allow lockd requests from an unprivileged port
      NFS: "[no]resvport" mount option changes mountd client too
      NFS: add "[no]resvport" mount option
      NFS: move nfs_server flag initialization
      NFS: expand flags passed to nfs_create_rpc_client()
      NFS: introduce nfs_mount_info struct for calling nfs_mount()
      NFS: Move declaration of nfs_mount() to fs/nfs/internal.h
      NFS: rename nfs_path variable


 fs/lockd/clntlock.c         |    2 +-
 fs/lockd/host.c             |   10 +++++++++-
 fs/nfs/client.c             |   35 ++++++++++++++++++++++-------------
 fs/nfs/internal.h           |   14 ++++++++++++++
 fs/nfs/mount_clnt.c         |   34 +++++++++++++++-------------------
 fs/nfs/nfsroot.c            |   27 +++++++++++++++++----------
 fs/nfs/super.c              |   42 +++++++++++++++++++++++++++---------------
 include/linux/lockd/bind.h  |    1 +
 include/linux/lockd/lockd.h |    4 +++-
 include/linux/nfs_fs.h      |    6 ------
 include/linux/nfs_mount.h   |    3 ++-
 11 files changed, 111 insertions(+), 67 deletions(-)

-- 
Chuck Lever

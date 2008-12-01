From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Make mount.nfs use new getport() function
Date: Mon, 01 Dec 2008 13:48:33 -0500
Message-ID: <20081201183616.10436.71066.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: steved@redhat.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:42956 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbYLAStF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:49:05 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Four new IPv6-related patches for mount.nfs.  These replace the
existing PMAP_GETPORT implementation in utils/mount/network.c with a
call to the new library functions we just added.

The probe_statd() function is used by both the legacy and the text-
based paths, but replacing the mount.nfs command's getport() function
affects only the *legacy* NFS mount path, not text-based mounts.

For anyone testing this code, please try it on pre-2.6.23 kernels,
or patch mount.nfs to use legacy binary style mounts.  This will
exercise the new PMAP_GETPORT implementation using all the special
cases needed by mount.nfs.

The new RPCB_GETADDR implementation will not be used until mount.nfs
can pass in IPv6 addresses.

---

Chuck Lever (4):
      mount command: remove local getport() implementation
      mount command: Replace clnt_ping() and getport() calls in probe_port()
      mount command: Use nfs_error() instead of perror()
      mount command: Use nfs_pmap_getport() in probe_statd()


 utils/mount/network.c |  144 +++++++++++++++----------------------------------
 1 files changed, 43 insertions(+), 101 deletions(-)

-- 
Chuck Lever

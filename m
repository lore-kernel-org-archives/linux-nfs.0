From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Address three recently reported bugs
Date: Tue, 28 Apr 2009 17:36:42 -0400
Message-ID: <20090428213453.16098.33168.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:41138 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551AbZD1Vij (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 17:38:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Some bug fixes for sm-notify and mount.nfs.  Please consider these for
nfs-utils 1.1.7.

---

Chuck Lever (3):
      mount: remove legacy version of nfs_name_to_address()
      sm-notify: Failed DNS lookups should be retried
      sm-notify: Don't orphan addrinfo structs


 utils/mount/network.c   |   88 ++++++++++++-----------------------------------
 utils/mount/network.h   |    3 +-
 utils/mount/nfsumount.c |    2 +
 utils/mount/stropts.c   |   16 ++-------
 utils/statd/sm-notify.c |   73 ++++++++++++++++++++++++++-------------
 5 files changed, 76 insertions(+), 106 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>

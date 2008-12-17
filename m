From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] Fix legacy build issues
Date: Wed, 17 Dec 2008 15:37:11 -0500
Message-ID: <20081217203301.14933.81853.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:26713 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbYLQUid (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2008 15:38:33 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Hope your power is restored.

We discovered some problems building nfs-utils on legacy systems caused
by recent IPv6 updates.  Here are some patches I propose to address
those problems.

Jonathan Andrews has tested the C code introduced by "use gethostbyname(3)
when building on old systems" on his distribution, which includes a very
old version of glibc that doesn't support AI_ADDRCONFIG.  But I was a
little challenged by the autoconf magic needed to pull this off.  Please
have a close look at that to see if it really does what is needed.

---

Chuck Lever (5):
      configure: use "--disable-uuid" instead of "--without-uuid"
      mount command: Random clean up
      getport: don't use getaddrinfo(3) on old systems
      mount command: use gethostbyname(3) when building on old systems
      mount: revert recent fix for build problems on old systems


 configure.ac          |   12 ++++++--
 support/nfs/getport.c |   69 ++++++++++++++++++++++++++++++++++++++------
 utils/mount/network.c |   77 +++++++++++++++++++++++++++++++++++++------------
 3 files changed, 127 insertions(+), 31 deletions(-)

-- 
Chuck Lever

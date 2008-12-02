From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] AF_INET6 support for probe_bothports()
Date: Tue, 02 Dec 2008 12:59:44 -0500
Message-ID: <20081202175403.5206.91389.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:31736 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902AbYLBSAl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2008 13:00:41 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Here's the next step.

This small series of patches rewires probe_bothports() to support
AF_INET6 addresses, now that the underlying functions can handle them.

Since legacy code in other parts of the mount command still use
probe_bothports() and the clnt_addr_t data type, I've added a new
function call to do the IPv6 duties.  The old API still exists and
continues to support only AF_INET, but under the covers it calls the
new code.

Again, for the time being, this is used only for the legacy binary
mount(2) interface.  We will need this for umount later, and that is
used to support both binary and text-based mounts.

---

Chuck Lever (3):
      mount command: AF_INET6 support for probe_bothports()
      mount command: support AF_INET6 in probe_nfsport() and probe_mntport()
      mount command: full support for AF_INET6 addresses in probe_port()


 utils/mount/network.c |  178 +++++++++++++++++++++++++++++++++++++++----------
 utils/mount/network.h |    3 +
 2 files changed, 144 insertions(+), 37 deletions(-)

-- 
Chuck Lever

From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Three more nfs-utils clean ups
Date: Tue, 06 Jan 2009 18:22:38 -0500
Message-ID: <20090106231909.24661.92964.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:63206 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbZAFXYm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 18:24:42 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

While digging through the last set of bugs in 2008, I constructed
these three fairly simple patches.  The middle one is probably the
most interesting, as it provides a little more flexibility about
how nfs-utils is built when libtirpc is present on the build system.

---

Chuck Lever (3):
      showmount command: Quiesce warning when TI-RPC is disabled
      configure: Add new build option "--enable-tirpc"
      configure: Remove inet_ntop(3) check from configure.ac


 configure.ac                |   34 +++++++++++++++++++++++-----------
 utils/showmount/showmount.c |   14 +++++++-------
 2 files changed, 30 insertions(+), 18 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>

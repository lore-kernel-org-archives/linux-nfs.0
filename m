From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] RFC: Proposed rpc.statd clean up
Date: Tue, 02 Sep 2008 17:53:42 -0400
Message-ID: <20080902215132.31328.44934.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com, neilb@suse.de, okir@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:39077 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbYIBVzD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2008 17:55:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi guys-

Here's a start at removing the RESTRICTED_STATD macro from rpc.statd.  It
would make IPv6 support a little simpler.

Comments welcome.

---

Chuck Lever (2):
      rpc.statd: eliminate --secure_statd
      rpc.statd: refactor check to see if call is from loopback address


 configure.ac          |    9 -----
 utils/statd/monitor.c |   93 +++++++++++++------------------------------------
 utils/statd/simu.c    |   38 ++++++++------------
 3 files changed, 40 insertions(+), 100 deletions(-)

-- 
Chuck Lever

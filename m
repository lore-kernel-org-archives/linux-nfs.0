Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0920C04EBF
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 15:13:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9FFA3206B7
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 15:13:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lglUwRNq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FFA3206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726541AbeLDPNd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 10:13:33 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:47624 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726385AbeLDPNd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 10:13:33 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=e7vyEkyz/X2BVBP4kyW2GLzhf+F6xx2hwY3TNSIWEBo=; b=lglUwRNqt1yvBXH7xochnbitf
        EiUKQx+q537DWhUpLojUb+5Pwd1Bv2qqLOkOrqVwLZwDbraG4KxpFLkNDeFHHtx54xH245Bf/fW4u
        e/vLo+GOKdf2uZ7lbWB4aGFQzEi5Bv7evT04vFyzJYDrXHOzYnwPbdZUJjzZsYsH3R6uBiQm+MGkY
        4PzddBotGXl2A/UbxnDecK4lnaV3YGF85zwkwXQgpigT6zDoRARBUWBYg7diJZDMgo0qku+Zqdwmf
        fLNeEkru/Cps1V2PkoB43uNyHsZsPJ2pawYEcGhcaNMHSOWsbfikq89UEHvPvgfLYU2FkKAntRwDh
        PUxzs4kxw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gUCOC-0001mv-GO; Tue, 04 Dec 2018 15:13:32 +0000
Date:   Tue, 4 Dec 2018 07:13:32 -0800
From:   Christoph Hellwig <hch@infradead.org>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Dave Chinner <david@fromorbit.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 01/11] vfs: copy_file_range source range over EOF should
 fail
Message-ID: <20181204151332.GA32245@infradead.org>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-2-david@fromorbit.com>
 <CAOQ4uxhOQY8M5rbgHKREN5qpeDGHv0-xK3r37Lj6XfqFoE4qjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxhOQY8M5rbgHKREN5qpeDGHv0-xK3r37Lj6XfqFoE4qjg@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 03, 2018 at 02:46:20PM +0200, Amir Goldstein wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> >
> > The man page says:
> >
> > EINVAL Requested range extends beyond the end of the source file
> >
> > But the current behaviour is that copy_file_range does a short
> > copy up to the source file EOF. Fix the kernel behaviour to match
> > the behaviour described in the man page.

I think the behavior implemented is a lot more useful than the one
documented..

> > +       /* If the source range crosses EOF, fail the copy */
> > +       if (pos_in >= i_size(inode_in) || pos_in + len > i_size(inode_in))
> > +               return -EINVAL;
> > +
> 
> i_size_read()...
> 
> Otherwise
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Looks like this doesn't even compile?

Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30213C65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 19:43:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CE60720811
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 19:43:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JHM7AxK9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE60720811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727102AbeLLTnB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 14:43:01 -0500
Received: from bombadil.infradead.org ([198.137.202.133]:44874 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726243AbeLLTnB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 14:43:01 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=cCV9FTYqNWT8eebWjimH3Bfsru2ZFqg0HLmmKpeonR0=; b=JHM7AxK9vqSeoPD9C+bDaGuis
        wKeKu1HXJECukKezhk5CbYUNaT85Qr60qPmzMsju6fB2E+MCc8OKz7BUAaaFA1pL4wgnmu6BiElSQ
        ah41Xft/6T9yfe67WJXFqOfKNVdj82xZGTijAwV8MSWj4Bm4FDZYswzn4DURsXcd23onmZGHBqWZM
        1t6Y5k7mtDEtX2BDbG/5rWpk5++UQjVZoy397fDB9rVfn0jQHEU9hhXnsv9qxSP7BihdOlyP0e624
        gIUs2QIZKcfxof6moIcJPhbK5eLRZDAdJWONwfQIcfVHM6kx53TQe1DRU/pnybLnemHpy9WYf0ST4
        lfjvBYW6w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gXAPL-0003n6-1l; Wed, 12 Dec 2018 19:42:59 +0000
Date:   Wed, 12 Dec 2018 11:42:58 -0800
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     lhenriques@suse.com, david@fromorbit.com,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 04/11] vfs: add missing checks to copy_file_range
Message-ID: <20181212194258.GK6830@bombadil.infradead.org>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-5-david@fromorbit.com>
 <87a7lbrng4.fsf@suse.com>
 <CAN-5tyHNGtLxeFyEO6qX_+8=K4tpkgYjB11OkfCTdWfokfAyEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyHNGtLxeFyEO6qX_+8=K4tpkgYjB11OkfCTdWfokfAyEg@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 12, 2018 at 01:55:28PM -0500, Olga Kornievskaia wrote:
> On Wed, Dec 12, 2018 at 6:31 AM Luis Henriques <lhenriques@suse.com> wrote:
> > I was wondering if, with the above check, it would make sense to also
> > have an extra patch changing some filesystems (ceph, nfs and cifs) to
> > simply return -EOPNOTSUPP (instead of -EINVAL) when inode_in ==
> > inode_out.  Something like the diff below (not tested!).

> > +++ b/fs/nfs/nfs4file.c
> > @@ -136,7 +136,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
> >         ssize_t ret;
> >
> >         if (file_inode(file_in) == file_inode(file_out))
> > -               return -EINVAL;
> > +               return -EOPNOTSUPP;
> 
> Please don't change the NFS bits. This is against the NFS
> specifications. RFC 7862 15.2.3
> 
> (snippet)
> SAVED_FH and CURRENT_FH must be different files.  If SAVED_FH and
>    CURRENT_FH refer to the same file, the operation MUST fail with
>    NFS4ERR_INVAL.

I don't see how that applies.  That refers to a requirement _in the
protocol_ that determines what the server MUST do if the client sends
it two FHs which refer to the same file.

What we're talking about here is how a Linux filesystem behaves when
receiving a copy_file_range() referring to the same file.  As long as
the Linux filesystem doesn't react by sending out one of these invalid
protocol messages, I don't see the problem.

Return-Path: <SRS0=Mg8c=NI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FF52C46475
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Oct 2018 02:39:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C53A12082D
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Oct 2018 02:39:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tPBUtG/z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C53A12082D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728898AbeJ1LW0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 28 Oct 2018 07:22:26 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:59724 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728720AbeJ1LW0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Oct 2018 07:22:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=GxD/rqxiNbxBpTzGdLyMMRD6KXpYjqSobXt7qmeOB3k=; b=tPBUtG/zI+kXHRxO3ugDvC61g
        lWKEjCMaZwFahBmSk5OkSqbFqA5pVDatMGizOiYGvtxBAZIGDiekxVLy/CcoRMdpc5UmxAMKE0SoJ
        anglCiuP/rFx6clS5BmEWuPH/xMPuDtKjtUBMR52TAcdCNJafjo/m4sDmG4dkr4Q2So0RB14CIO+I
        ZpScR2aw1Py1wwUpTzqCI95NKcChuKi8/A653XXseuQWjiGze0WQwLoVpClcLY+816rmEqQuOLsID
        gqeqwDK1GMPgCJlYuBO9P0UUyaIDK1LAoaYEv3NPmW8pZsFEavt4FlbmQaEnDo1jer3gOJr9AzQPl
        NWZcX9jPA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gGayv-0002f2-Eb; Sun, 28 Oct 2018 02:39:13 +0000
Date:   Sat, 27 Oct 2018 19:39:13 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Dave Chinner <david@fromorbit.com>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device
 copies
Message-ID: <20181028023913.GB25444@bombadil.infradead.org>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-3-olga.kornievskaia@gmail.com>
 <20181027091240.GK6311@dastard>
 <20181027132339.GZ25444@bombadil.infradead.org>
 <20181028013307.GM6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181028013307.GM6311@dastard>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Oct 28, 2018 at 12:33:07PM +1100, Dave Chinner wrote:
> On Sat, Oct 27, 2018 at 06:23:39AM -0700, Matthew Wilcox wrote:
> > I mentioned this in my last review, and Olga pointed out that one of
> > the changes in this patch means the kernel will do the copy using
> > do_splice_direct if the filesystem doesn't support cross-device copying.
> > We should keep this error documented for those on old kernels, but the
> > kernel will never return -EXDEV any more.
> 
> Uh, wot? Where's the patch named "VFS: enable copy_file_range() for
> all filesystems"? That shoul dnot be a detail hidden inside some
> other patch that multiple people completely miss during review.

Yes, I completely agree.

I'd actually suggest doing the patches the other way around; first push
the -EXDEV check into the filesystems, then make an EXDEV return cause a
call to do_splice_direct().  I think that makes for a more understandable
patch series (ie it's just splitting the last hunk from the existing
patch 1 into a separate patch with an appropriate changelog).

> If we are completely changing the kernel's behaviour, the patch
> should be explicitly named to call out the change of behaviour, and
> the commit message should clearly explain the change being made and
> why.
>  
> /me goes looking.
> 
> Yup, it is only mentione din passing as a side-effect of an
> implementation change. That's back to front. Describe the behaviour
> change, what users will see and the reasons for making the change,
> leave the code to describe exactly what the change is. Then you can
> describe the actions needed to make the new functionality work. e.g.
> The first patch shoul dbe described as:
> 
> VFS: generic cross-device copy_file_range() support for all filesystems
> 
> From: ....
> 
> In preparation for enabling cross-device offloading of
> copy_file_range() functionality, first enable generic cross-device
> support by allowing copy_file_range() to fall back to a page cache
> based physical data copy. This means the copy_file_range() syscall
> will never fail with EXDEV, and so in future userspace will not need
> to detect or provide a fallback for failed cross-device copies
> anymore.
> 
> This requires pushing the cross device support checks down into the
> filesystem ->copy_file_range methods and falling back to the page
> cache copy if they return EXDEV.
> 
> Further, clone_file_range() is only supported within a filesystem,
> so we must also check that the files belong to the same superblock
> before calling ->clone_file_range(). If they are on different
> superblocks, skip the attempt to clone the file and instead try to
> copy the file.
> 
> S-o-B: .....
> 
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

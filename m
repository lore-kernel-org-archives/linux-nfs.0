Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF81FC004D3
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 19:06:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BDDC420645
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 19:06:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pm02CmLn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDDC420645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728591AbeJWD0H (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 23:26:07 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:41970 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728289AbeJWD0G (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2018 23:26:06 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=cuc20oOD0h444p9IEGd3kj/N2z2Mjrpz/mRoplB9nk4=; b=pm02CmLnE8RFo5WJFe5cJZ0f/
        bpDqdRRxFR5CMD3UOaD3++52Cp8yY47JvdGShB2CfmtX5ph9rGZl7ELj3Fk2iZiCr5P8yGRAtufUV
        H43bQ5Y8tRAk8n9Km8eK2cg+uRn4QvxEbM1Cf8/fccfeufa68al7uqT/DG9Se+Im+RhgckDpiyQxS
        aR/uV/ttcXldmM+P29NTJaKhNEKJL/dwWN9qyIIE0Ov3ZUp/wj6sB0SrGdMONuZZe/2DudUP/Iz+k
        +W9K6RzeolB+PHfFMl0NbYanEiyvtXHqxokKfsSM2WU+30d7e6qiLhJC/VZ/OEnOZPAgL8I+CIwIF
        wsoAMY7dg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gEfWu-0003yE-Hd; Mon, 22 Oct 2018 19:06:20 +0000
Date:   Mon, 22 Oct 2018 12:06:20 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     Amir Goldstein <amir73il@gmail.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>,
        Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
Message-ID: <20181022190620.GA8863@bombadil.infradead.org>
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com>
 <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
 <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 22, 2018 at 02:45:04PM -0400, Olga Kornievskaia wrote:
> On Sat, Oct 20, 2018 at 4:54 AM Amir Goldstein <amir73il@gmail.com> wrote:
> > Another thing is the commit message claims to:
> > "Allow copy_file_range to copy between different superblocks but only
> > of the same file system types"
> >
> > But what the patch actually does is:
> > "Allow copy_file_range() syscall to copy between different filesystems
> > AND allow calling the filesystems' copy_file_range() method
> > between different superblocks but only of the same file system types"
> >
> > It's probably OK and quite useful to do the former, but maybe man page
> > should be fixed to explicitly mention that the copy is expected to work
> > across filesystems since kernel version XXX (?)
> >
> > If you don't wish to change cross filesystem type behavior and only
> > relax cross super block limitation, then you should replace the
> > same inode->i_sb check above with same inode->i_sb->s_type
> > check instead of doing the check only for calling the filesystem
> > copy_file_range() method.
> 
> Thank you for the feedback. In the next version, I will remove the
> check for the functions and instead check for the same file system
> types.

Jeff and I agree that this is the wrong way to go.  Instead, the
cross-device check should be in the individual instances, not the top
level code.


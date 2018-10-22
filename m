Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8153FC67863
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 20:29:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C6E0520651
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 20:29:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WBwVuIFL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6E0520651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726652AbeJWEt4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 00:49:56 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:51610 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726169AbeJWEtz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 00:49:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=XlOgYyDamJMR8hF/M643pOUIGTdQCiN9B18mwGCpRow=; b=WBwVuIFLefFsujqxYZ+PctgqV
        DrJppbEJeghFI0JWUHZn3E5U/Tq5lbb9JIDlR8gZ/nm9FdLKKzPczFGKETvwPMLd+iXu5UwLH7bj2
        jTmbuixiiXc+zN6LI2885ZlLsY6yp4KyjwgsdIgRHFX1I5o5s66ube2f24xbiIAIkltawvWyLHFVI
        SUUcGxCl8wuvQB4v4HJhwEFjBdUfkA2H3m4hf5dBdEgChddbrhH8fCQCcmQvWwC04JNWFdB24qnAr
        oMKVqygWOwN/z7xaaPOoHvEbSgvDK2kTZjzZIoY+Jna0aqtN9m1bkMro9T9Q+kTAdZbyzoQnZYeP0
        SwHEJLohQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gEgpm-0005WR-1m; Mon, 22 Oct 2018 20:29:54 +0000
Date:   Mon, 22 Oct 2018 13:29:53 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        fweimer@redhat.com, Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>, linux-api@vger.kernel.org
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
Message-ID: <20181022202953.GA20085@bombadil.infradead.org>
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com>
 <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
 <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
 <20181022190620.GA8863@bombadil.infradead.org>
 <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
 <CAOQ4uxjJgghh48LUsqCofS0uiuA35CQT-zEMvMESkqniLfv2fA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxjJgghh48LUsqCofS0uiuA35CQT-zEMvMESkqniLfv2fA@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 22, 2018 at 10:48:10PM +0300, Amir Goldstein wrote:
> On Mon, Oct 22, 2018 at 10:35 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> > So remove the check all together for the VFS (that was my original
> > patch to begin with (like #1 not this one). So am I missing the point
> > again, I keep getting different corrections every time.
> 
> Because there are different opinions... although you did get the opinion
> of the VFS maintainer, which was: compare i_sb->s_type.
> 
> Jeff, Matthew, really, what's the use of "allowing" cross fs type copy inside
> filesystem code? and which method is going to be called?
> file_out->f_op->copy_file_range()?
> file_in->f_op->copy_file_range()?

The destination's method, as Olga originally had.

> Do we need to check if both are implemented? either?
> This is just confusing Olga and gives no real value to anyone.
> If we ever have a filesystem copy_file_range() method that can deal
> with cross fs type copy, we can change it then when we know the
> required semantics of that future call.

Wrong.  Go back and read my reasoning earlier this thread.

> That is not to say that we cannot relax same fs type from copy_file_range()
> syscall. That has already been done with the current patch, just not officially
> declared in commit message.
> 
> Thanks,
> Amir.

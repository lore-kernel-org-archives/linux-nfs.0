Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC934C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 17:24:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 948A020834
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 17:24:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="q1VO28WZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 948A020834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727518AbeJZB6N (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 21:58:13 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:43440 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727462AbeJZB6N (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 21:58:13 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=n65pfQnMHZ0Nipx04+r6nmQFGqoPTb9LwJqWBO83yXg=; b=q1VO28WZehoTGjlqLw7pFFWnT
        xH9EemVDIs+n9YXBDCdaTlaIJv+D8xXTxc03qqR5U5EnUOiyzwPRs6mhFUANXOvq1zaDnDRkH34iJ
        1axoZdyHcXI/+oqqaEZ+lGZOqTmp4HQwsm6rFTimF5XBXXCUY+itkhcZFfZvuZzcDjO5xE1YFqvrA
        41SF+Y96gM8ja3e/jt80InjAZNsYVKQwaX6RS4a8t0D8XhgReuZ4JX4Cofbpxl4a6iT2iMRXwDlxO
        rwtzja2SAjijyaBg2bEMrQmsCk/PjEtWx7E2v7mSGSij9B2sOPQGVecT50NqU9DdR5JwipqaGCty7
        ctJq9Wzjw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gFjMw-0001xl-Ga; Thu, 25 Oct 2018 17:24:26 +0000
Date:   Thu, 25 Oct 2018 10:24:26 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        overlayfs <linux-unionfs@vger.kernel.org>,
        linux-man@vger.kernel.org
Subject: Re: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device
 copies
Message-ID: <20181025172426.GI25444@bombadil.infradead.org>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
 <20181024195837.35532-3-olga.kornievskaia@gmail.com>
 <CAOQ4uxhM=Uw3NMsJOhzWE7PPHAUktpy3z_gtaRCkpV5YnDf3Tw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxhM=Uw3NMsJOhzWE7PPHAUktpy3z_gtaRCkpV5YnDf3Tw@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Oct 25, 2018 at 07:28:10AM +0300, Amir Goldstein wrote:
> On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > A proposed VFS change removes the check for the files to reside
> > under the same file system. Instead, a file system driver implementation
> > is allowed to perform a cross-device copy_file_range() and if
> > the file system fails to support it instead fallback to doing
> > a do_splice copy. Therefore, EXDEV is no longer a possible error.
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  man2/copy_file_range.2 | 7 ++-----
> >  1 file changed, 2 insertions(+), 5 deletions(-)
> >
> > diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
> > index 20374ab..723b2d0 100644
> > --- a/man2/copy_file_range.2
> > +++ b/man2/copy_file_range.2
> > @@ -39,7 +39,8 @@ The
> >  .BR copy_file_range ()
> >  system call performs an in-kernel copy between two file descriptors
> >  without the additional cost of transferring data from the kernel to user space
> > -and then back into the kernel.
> > +and then back into the kernel. Since kernel version 4.21(???) passed in
> > +file descriptors are not required to be under the same mounted file system.
> >  It copies up to
> >  .I len
> >  bytes of data from file descriptor
> > @@ -128,10 +129,6 @@ Out of memory.
> >  .B ENOSPC
> >  There is not enough space on the target filesystem to complete the copy.
> >  .TP
> > -.B EXDEV
> > -The files referred to by
> > -.IR file_in " and " file_out
> > -are not on the same mounted filesystem.
> 
> Man page serves users of old kernels as well. You should not delete this
> expected error, but you can add "... and kernel does not support cross
> filesystem copy".

I'd rather see this worded as:

 .B EXDEV
 The files referred to by
 .IR file_in " and " file_out
-are not on the same mounted filesystem.
+cannot be copied due to being on incompatible filesystems


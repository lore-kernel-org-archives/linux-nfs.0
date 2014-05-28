Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f173.google.com ([209.85.128.173]:60523 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaE1XCP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 19:02:15 -0400
Received: by mail-ve0-f173.google.com with SMTP id pa12so13451362veb.32
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 16:02:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
Date: Wed, 28 May 2014 19:02:14 -0400
Message-ID: <CAHQdGtTEceDpfjnUMotTgqkwMoTQaRYgSwWGLXudTsg0U+opDA@mail.gmail.com>
Subject: Re: [PATCH v3 00/17] NFS: Create a common path used by reads and writes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 6, 2014 at 9:12 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> I noticed that much of the read and write code was almost identical, with
> only minor differences in argument types and names.  These patches seek to
> unify these two codepaths wherever possible in order to make future changes
> easier.
>
> Table of contents:
>         Patches 01 - 05: Set up common data structures.
>         Patches 06 - 10: Set up a shared rpc_call_ops struct.
>         Patches 11 - 15: Set up a shared nfs_pageio_ops struct.
>
> Some of the commit setup was moved into common code, but I'm willing to
> move this back into write.c if this looks to be a problem.
>
> Future work:
>         I have rough pNFS patches to combine the read and write paths in
>         pnfs.c.  They apply on top of Dros' multiple requests work and
>         should get more testing before I submit.
>
> Testing:
>         I tested every version of NFS using the cthon and xfs tests without
>         hitting anything new.  Any extra testing would be great seeing how
>         the read and write paths are vitally important.
>
> Changes in v3:
>         Instead of creating a new "pageio.c" file, I now put the combined
>         code into pagelist.c (good luck, Dros!)
>
>         I also renamed a few functions, and did a better job checking what
>         pagelist.c functions can now be static.
>
> Questions?  Comments?  Thoughts?
>

Thanks for working on this! Applied...

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:34659 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbbGMHgm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 03:36:42 -0400
Received: by iebmu5 with SMTP id mu5so228829952ieb.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 00:36:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150713065851.GD26245@infradead.org>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com> <20150713065851.GD26245@infradead.org>
From: Peng Tao <tao.peng@primarydata.com>
Date: Mon, 13 Jul 2015 15:36:22 +0800
Message-ID: <CAKVebiXYYzL=yhMBUjxKk=7p+Aunm1UFPRCzXsqYi5R7Fj7=gg@mail.gmail.com>
Subject: Re: [PATCH 0/7] nfs: minor cleanups and NFSv42 CLONE support
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 2:58 PM, Christoph Hellwig <hch@infradead.org> wrote:
> Also please include a server side implementation.  Adding Linux NFS
> client features that don't also have server support have been proven
> to be untestable.
>
> Here is my prototype for an older draft, which can be brought forward
> easily: http://git.infradead.org/users/hch/pnfs.git/shortlog/refs/heads/clone
So the main change is .copy_file_range syscall. Was it rejected before
or can we just push it forward as it is?

If there are objections against a new syscall, we can drop it and move
on with vfs helper and the new copy_file_range file operation, in
order to just make nfsd clone work.

Cheers,
Tao

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:42180 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbbBTQWu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Feb 2015 11:22:50 -0500
Received: by mail-vc0-f177.google.com with SMTP id hy10so3246167vcb.8
        for <linux-nfs@vger.kernel.org>; Fri, 20 Feb 2015 08:22:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150220161903.GA17874@infradead.org>
References: <1424448985.3641.1.camel@primarydata.com>
	<20150220161903.GA17874@infradead.org>
Date: Fri, 20 Feb 2015 08:22:48 -0800
Message-ID: <CAHQdGtSStjt7YmFS49JifTb6iNAL+-KyJvTdkKP59xe39s=ZOQ@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client updates
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 20, 2015 at 8:19 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, Feb 20, 2015 at 08:16:25AM -0800, Trond Myklebust wrote:
>>       NFS: struct nfs_commit_info.lock must always point to inode->i_lock
>
> Is there any point in even keeping that lock pointer around then?

We either have to pass a pointer to the lock or to the inode itself.
I'm fine with either, but I figured the more conservative option would
be keeping what we have now.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

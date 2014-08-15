Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:64302 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbaHOOgt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 10:36:49 -0400
Received: by mail-ig0-f177.google.com with SMTP id hn18so1958444igb.16
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 07:36:49 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 0/2] RFC: Fix nfs_generic_pgio page vector issues
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1408052373-4306-1-git-send-email-dros@primarydata.com>
Date: Fri, 15 Aug 2014 10:36:45 -0400
Cc: =?windows-1252?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Message-Id: <BBF98A73-8235-4609-BB95-DC8C900E2134@primarydata.com>
References: <1408052373-4306-1-git-send-email-dros@primarydata.com>
To: linux-nfs list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This survived a full day of running trinity on one system and a full day of various iozone / fio on another.

It’s good to go from my perspective.

-dros


On Aug 14, 2014, at 5:39 PM, Weston Andros Adamson <dros@primarydata.com> wrote:

> This patchset fixes a few issues with the creation of nfs_pageio_descriptor
> page vectors, which are passed to nfs_pgio_header structures.
> 
> These were first found by Toralf Förster <toralf.foerster@gmx.de> by running
> trinity, but I've since received a report of a real world usecase that
> hit a related issue: kvm with cache=none.
> 
> There are two problems that are closely related and seem to only be triggered
> by direct i/o writev()/readv() calls.
> 
> The fixes are:
>  - do not coalesce pages unless they are contiguous in file position *and*
>    within / betwen pages.
> 
>  - do not allow duplicated pages in the pagevector
> 
> 
> I'm still testing these, but I thought I'd share what I have with the list.
> 
> -dros
> 
> Weston Andros Adamson (2):
>  nfs: disallow duplicate pages in pgio page vectors
>  nfs: can_coalesce_requests must enforce contiguity
> 
> fs/nfs/pagelist.c | 30 +++++++++++++++++++++++++++---
> 1 file changed, 27 insertions(+), 3 deletions(-)
> 
> -- 
> 1.8.5.2 (Apple Git-48)
> 


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:60339 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932143AbaESQZE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 12:25:04 -0400
Received: by mail-ie0-f175.google.com with SMTP id y20so5577639ier.20
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 09:25:04 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH 7/8] nfs: clean up function decls in nfs_page.h
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140519152919.GA9712@umich.edu>
Date: Mon, 19 May 2014 12:25:01 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <689E72F2-F0AA-4DA1-A8E0-C9B8F78292F3@primarydata.com>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com> <1400512508-7530-8-git-send-email-dros@primarydata.com> <20140519152919.GA9712@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 19, 2014, at 11:29 AM, Jim Rees <rees@umich.edu> wrote:

> Weston Andros Adamson wrote:
> 
>  For consistency, remove argument names in function declarations
> 
> This conflicts with the style guide:

Well, then so do many (most?) function declarations in nfs-land.

> 
> Chapter 6: Functions
> 
> In function prototypes, include parameter names with their data types.
> Although this is not required by the C language, it is preferred in Linux
> because it is a simple way to add valuable information for the reader.


I personally disagree that function names provide “valuable information”.
“struct page *page” -> “oh, it’s a page!” ;)

I can just drop this patch if people don’t like it...

-dros
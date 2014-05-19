Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:38271 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145AbaESQ4P convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 12:56:15 -0400
Received: by mail-ie0-f177.google.com with SMTP id y20so2908492ier.36
        for <linux-nfs@vger.kernel.org>; Mon, 19 May 2014 09:56:14 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH 7/8] nfs: clean up function decls in nfs_page.h
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140519163620.GA10271@umich.edu>
Date: Mon, 19 May 2014 12:56:11 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <84EC0D4A-968C-4002-B0BF-849D4F41F145@primarydata.com>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com> <1400512508-7530-8-git-send-email-dros@primarydata.com> <20140519152919.GA9712@umich.edu> <689E72F2-F0AA-4DA1-A8E0-C9B8F78292F3@primarydata.com> <20140519163620.GA10271@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 19, 2014, at 12:36 PM, Jim Rees <rees@umich.edu> wrote:

> Consistency often trumps style guidelines, and I have no strong objection to
> this change. Just wanted to point it out.

Right and I appreciate you pointing it out. I mistakenly thought I was following the
guidelines!

So, I can see how it’d be useful to have names when using basic types or when
passing several arguments of the same type. Maybe we could just remove
super redundant names (i.e. “struct page *page”)?

On the other hand, maybe we don’t open this can of worms and I just drop this
patch from the patchset..

-dros


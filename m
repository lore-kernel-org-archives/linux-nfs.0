Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:54821 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989AbbAHQCg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 11:02:36 -0500
Received: by mail-ig0-f181.google.com with SMTP id a13so3496054igq.2
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 08:02:35 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Subject: Re: [PATCH v3 00/49] *** Add Flexfile Layout Module ***
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20150108144559.GA11530@infradead.org>
Date: Thu, 8 Jan 2015 11:02:34 -0500
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <0CA807B5-8850-4413-95C0-D5BF7A52D4F4@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com> <20150108144559.GA11530@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 8, 2015, at 9:45 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> Do you also have a git tree available?  I'd like to test that the
> core pnfs changes don't cause regressions for the block layout driver.
> 
> Talking about testing, where can I get the flexfiles server to test this
> layout?

We have pynfs patches that I can push out soon. It hands out flexfile
layouts for real data servers (not pynfs dataservers), but doesn’t properly
handle fencing. Good for some basic testing, but not much else.

-dros


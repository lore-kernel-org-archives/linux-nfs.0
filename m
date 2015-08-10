Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33307 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbbHJQfL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 12:35:11 -0400
Received: by ioii16 with SMTP id i16so174932972ioi.0
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2015 09:35:10 -0700 (PDT)
Message-ID: <1439224487.5233.2.camel@primarydata.com>
Subject: Re: xfstests crash with trond/testing
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 10 Aug 2015 12:34:47 -0400
In-Reply-To: <CAHQdGtTbStw1OinHNPVAFtGfFyNZ+estxD+RZ1B+a6oEB+O83w@mail.gmail.com>
References: <20150808142040.GA9456@lst.de> <20150810120820.GA11618@lst.de>
	 <CAHQdGtTbStw1OinHNPVAFtGfFyNZ+estxD+RZ1B+a6oEB+O83w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2015-08-10 at 10:19 -0400, Trond Myklebust wrote:
> On Mon, Aug 10, 2015 at 8:08 AM, Christoph Hellwig <hch@lst.de> 
> wrote:
> > Correction:  This was a plain 4.1 mount, not using pnfs at all, it
> > reproduces every time I do a full xfstests run.
> 
> Thanks! I'll look into it.

The following patch should fix it. Do you mind if I just squash it in
to the existing one?

Cheers
  Trond

8<-------------------------------------------------------------------

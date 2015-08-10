Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:32948 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472AbbHJOTF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 10:19:05 -0400
Received: by obbhe7 with SMTP id he7so28389549obb.0
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2015 07:19:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150810120820.GA11618@lst.de>
References: <20150808142040.GA9456@lst.de>
	<20150810120820.GA11618@lst.de>
Date: Mon, 10 Aug 2015 10:19:04 -0400
Message-ID: <CAHQdGtTbStw1OinHNPVAFtGfFyNZ+estxD+RZ1B+a6oEB+O83w@mail.gmail.com>
Subject: Re: xfstests crash with trond/testing
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 10, 2015 at 8:08 AM, Christoph Hellwig <hch@lst.de> wrote:
> Correction:  This was a plain 4.1 mount, not using pnfs at all, it
> reproduces every time I do a full xfstests run.

Thanks! I'll look into it.

Cheers
  Trond

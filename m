Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f170.google.com ([209.85.128.170]:51132 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbaE1XBS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 19:01:18 -0400
Received: by mail-ve0-f170.google.com with SMTP id db11so13347031veb.15
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 16:01:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1397653642-17833-1-git-send-email-hch@lst.de>
References: <1397653642-17833-1-git-send-email-hch@lst.de>
Date: Wed, 28 May 2014 19:01:17 -0400
Message-ID: <CAHQdGtRU9f-u+=MVqU1gQMMTZiVJK9j-XTHMwLEo+91SJf2jMg@mail.gmail.com>
Subject: Re: pageio_init simplifications, V2
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 16, 2014 at 9:07 AM, Christoph Hellwig <hch@lst.de> wrote:
> Changes since last version:
>
>  - add the missing exports as pointed out by Anna
>  - handle the pnfs fallback to MDS case correctly
>

Thanks! Applied...


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

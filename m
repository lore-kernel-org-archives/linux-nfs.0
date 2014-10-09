Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:53924 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbaJISg3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Oct 2014 14:36:29 -0400
Received: by mail-vc0-f176.google.com with SMTP id hq11so1469811vcb.7
        for <linux-nfs@vger.kernel.org>; Thu, 09 Oct 2014 11:36:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141009160214.GA32766@infradead.org>
References: <1412801200-17936-1-git-send-email-trond.myklebust@primarydata.com>
	<20141009160214.GA32766@infradead.org>
Date: Thu, 9 Oct 2014 14:36:28 -0400
Message-ID: <CAHQdGtRP_p0Mf+DNK5CATo9ikOqUmPTScMnuerrZ+W2qgeBQPg@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1/pnfs: replace broken pnfs_put_lseg_async
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 9, 2014 at 12:02 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Oct 08, 2014 at 04:46:40PM -0400, Trond Myklebust wrote:
>> You cannot call pnfs_put_lseg_async() more than once per lseg, so it
>> is really an inappropriate way to deal with a refcount issue.
>>
>> Instead, replace it with a function that decrements the refcount, and
>> puts the final 'free' operation (which is incompatible with locks) on
>> the workqueue.
>
> How about calling the clear_request_commit layout driver operation
> from a workqueue?  That seems like a much saner approach.

That unfortunately suffers from worse problems that above. We'd have
to embed a struct work in the nfs_page (which is already a little on
the large size), and we'd still have no guarantee that
clear_request_commit would be complete if we need to call it twice
(which can happen).

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com

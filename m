Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:36101 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752466AbdFVRNH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jun 2017 13:13:07 -0400
Received: by mail-qt0-f174.google.com with SMTP id i2so16911613qta.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jun 2017 10:13:06 -0700 (PDT)
Message-ID: <1498151583.30388.7.camel@redhat.com>
Subject: Re: [PATCH v2 19/19] sunrpc: Disable splice for krb5i
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Thu, 22 Jun 2017 13:13:03 -0400
In-Reply-To: <20170619153018.GA2667@infradead.org>
References: <20170616151535.14210.34926.stgit@klimt.1015granger.net>
         <20170616152254.14210.48071.stgit@klimt.1015granger.net>
         <20170617150705.GA27917@infradead.org>
         <A573E1EB-48DB-4E4A-B710-34914B0CF016@oracle.com>
         <20170618073438.GA15358@infradead.org>
         <14AD4311-5092-441C-8A3B-F7EC7E801358@oracle.com>
         <20170619153018.GA2667@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-06-19 at 08:30 -0700, Christoph Hellwig wrote:
> On Mon, Jun 19, 2017 at 11:22:41AM -0400, Chuck Lever wrote:
> > I'm going to submit this again with a comment change and
> > Jeff's Reviewed-by. Can I add your Reviewed-by as well?
> 
> It looks ok as a quick fix for me but at least needs a big comment.
> I'd also be much happier if we could find and fix the root cause.

Don't we already know the root cause?

There's nothing that holds the data stable, so we calculate the checksum
but by the time we get to transmitting the frame it's no longer valid.
Is there something else that should be preventing this?

In any case, I do agree that some comments explaining this would be a
good thing.
-- 
Jeff Layton <jlayton@redhat.com>

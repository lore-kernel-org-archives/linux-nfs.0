Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34931 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751100AbdEINao (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 09:30:44 -0400
Received: by mail-qk0-f181.google.com with SMTP id a72so505446qkj.2
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 06:30:44 -0700 (PDT)
Message-ID: <1494336641.2659.5.camel@redhat.com>
Subject: Re: [PATCH 02/32] sunrpc: fix encoder callback prototypes
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@lst.de>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Date: Tue, 09 May 2017 09:30:41 -0400
In-Reply-To: <20170509131108.GA15042@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
         <20170509092010.30752-3-hch@lst.de>
         <779451235.5133504.1494323029528.JavaMail.zimbra@desy.de>
         <20170509131108.GA15042@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-05-09 at 15:11 +0200, Christoph Hellwig wrote:
> On Tue, May 09, 2017 at 11:43:49AM +0200, Mkrtchyan, Tigran wrote:
> > just out of curiosity: you are talking about increasing type safety, but
> > at the same time replaces arguments to 'const void *data', which will accept
> > everything. Is there something special which I don't understand?
> 
> Nothing special - cast are potentially dangerous in general, and
> function pointer cases are especially dangerous as there is no
> verify the caller and callee signatures match at all.  As generic
> method call patterns need to have private data of some points they
> need to have a void pointer somewhere - either in the signature or
> as a pointer from a passed structure.  For those the compiler at least
> can do some basic sanity checking, and good static analysis tools can
> even verify we get the proper object using whole program analysis.

Strong ACK on all of this.

I've been bitten before (in userland code) by having a function that
took 3 arguments cast to something that took 2. So the callers ends up
passing in too few arguments, and the function then just ends up using
junk out of a register or off the the stack to satisfy the missing one.
Not fun to track down.

Christoph, for the first 13 patches, you can add:

Reviewed-by: Jeff Layton <jlayton@redhat.com>

I'll look over the remaining ones later.

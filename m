Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:45103 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753210AbdEINLJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 May 2017 09:11:09 -0400
Date: Tue, 9 May 2017 15:11:08 +0200
From: Christoph Hellwig <hch@lst.de>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/32] sunrpc: fix encoder callback prototypes
Message-ID: <20170509131108.GA15042@lst.de>
References: <20170509092010.30752-1-hch@lst.de> <20170509092010.30752-3-hch@lst.de> <779451235.5133504.1494323029528.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <779451235.5133504.1494323029528.JavaMail.zimbra@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 09, 2017 at 11:43:49AM +0200, Mkrtchyan, Tigran wrote:
> just out of curiosity: you are talking about increasing type safety, but
> at the same time replaces arguments to 'const void *data', which will accept
> everything. Is there something special which I don't understand?

Nothing special - cast are potentially dangerous in general, and
function pointer cases are especially dangerous as there is no
verify the caller and callee signatures match at all.  As generic
method call patterns need to have private data of some points they
need to have a void pointer somewhere - either in the signature or
as a pointer from a passed structure.  For those the compiler at least
can do some basic sanity checking, and good static analysis tools can
even verify we get the proper object using whole program analysis.

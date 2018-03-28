Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59518 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753214AbeC1SEW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Mar 2018 14:04:22 -0400
Date: Wed, 28 Mar 2018 14:04:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Eric Biggers <ebiggers@google.com>
Cc: Michael Young <m.a.young@durham.ac.uk>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS mounts failing when keytab present on client
Message-ID: <20180328180422.GC3354@fieldses.org>
References: <alpine.LFD.2.21.1803272126070.3013@austen3.home>
 <20180327222950.GB257332@google.com>
 <20180328154628.GA3038@fieldses.org>
 <20180328175051.GB185597@google.com>
 <20180328180334.GB3354@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180328180334.GB3354@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2018 at 02:03:34PM -0400, J. Bruce Fields wrote:
> Thanks, got it.  Do you know how to find a commit id for that change?
> It's not entirely fair to blame the crypto change for what was really a
> latent nfs bug, but it might still be worth adding a Fixes: line just so
> people know where it needs backporting.

Whoops, I see you already did that.  I should finish my inbox before
responding!

--b.

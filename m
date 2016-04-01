Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161AbcDAO5O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Apr 2016 10:57:14 -0400
Date: Fri, 1 Apr 2016 10:57:11 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>
cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <schumakeranna@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: hang on xfstests generic/074
In-Reply-To: <20150211123448.GA30174@infradead.org>
Message-ID: <alpine.OSX.2.19.9992.1604011055480.20689@planck>
References: <20150210154306.GF28949@fieldses.org> <20150211123448.GA30174@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 11 Feb 2015, Christoph Hellwig wrote:

> On Tue, Feb 10, 2015 at 10:43:06AM -0500, J. Bruce Fields wrote:
> > I finally got around to running xfstests as part of my regular testing
> > and ran across a reproduceable hang on generic/074:
>
> Yes, I reported this about half a year ago.  It was caused (or at least
> unhidden) by commit 2aca5b869ace67a63aab895659e5dc14c33a4d6e ("SUNRPC:
> Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT"). Reverting
> that commit fixes the issue for me.

I just ran into this.

Now that we have SO_REUSEPORT, can we get rid of
RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT?

Ben

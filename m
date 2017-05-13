Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:35650 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751018AbdEMHZ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 13 May 2017 03:25:59 -0400
Date: Sat, 13 May 2017 09:25:57 +0200
From: hch <hch@lst.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: hch <hch@lst.de>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: remove function pointer casts and constify function tables
Message-ID: <20170513072557.GA14602@lst.de>
References: <20170512161701.22468-1-hch@lst.de> <1494620040.19467.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1494620040.19467.1.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 12, 2017 at 08:14:03PM +0000, Trond Myklebust wrote:
> How should we proceed to merge this series? Given that it is changing a
> lot of function headers, but not actually changing functionality, might
> it be possible to merge it out-of-band with the merge window (e.g. next
> week) in order to minimise the amount of work needed to fix up future
> patches?

I'd be ok with that, but someone would have to sign up to take the
heat when Linus doesn't like it, and it won't be me :)

Otherwiase a shared stable branch sounds fine.  I can provide one
for you on infradead or one of you could sign up for it.

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50755 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932167AbdECUic (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 16:38:32 -0400
Date: Wed, 3 May 2017 13:38:24 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Joe Perches <joe@perches.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
Message-ID: <20170503203824.GA31097@bombadil.infradead.org>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
 <1493835238.3180.7.camel@poochiereds.net>
 <1493835998.22125.15.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1493835998.22125.15.camel@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 03, 2017 at 11:26:38AM -0700, Joe Perches wrote:
> On Wed, 2017-05-03 at 14:13 -0400, Jeff Layton wrote:
> > On Wed, 2017-05-03 at 17:04 +0100, David Howells wrote:
> > > +		oo = kmalloc((opts->num_mnt_opts + 1) * sizeof(char *),
> > > +			     GFP_KERNEL);

If we're picking nits, then this should be kcalloc in case somebody
passed in 2^31 in num_mnt_opts.


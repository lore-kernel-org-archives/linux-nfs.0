Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46456 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751144AbdECVRw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 17:17:52 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170503203824.GA31097@bombadil.infradead.org>
References: <20170503203824.GA31097@bombadil.infradead.org> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk> <1493835238.3180.7.camel@poochiereds.net> <1493835998.22125.15.camel@perches.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: dhowells@redhat.com, Joe Perches <joe@perches.com>,
        Jeff Layton <jlayton@poochiereds.net>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 03 May 2017 22:17:49 +0100
Message-ID: <8602.1493846269@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Matthew Wilcox <willy@infradead.org> wrote:

> On Wed, May 03, 2017 at 11:26:38AM -0700, Joe Perches wrote:
> > On Wed, 2017-05-03 at 14:13 -0400, Jeff Layton wrote:
> > > On Wed, 2017-05-03 at 17:04 +0100, David Howells wrote:
> > > > +		oo = kmalloc((opts->num_mnt_opts + 1) * sizeof(char *),
> > > > +			     GFP_KERNEL);
> 
> If we're picking nits, then this should be kcalloc in case somebody
> passed in 2^31 in num_mnt_opts.

A few lines previously there is:

	if (opts->num_mnt_opts > 3) {
		mc->error = "SELinux: Too many options";
		return -EINVAL;
	}

David

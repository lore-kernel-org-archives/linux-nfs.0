Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53359 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694Ab3KGP6h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 10:58:37 -0500
Date: Thu, 7 Nov 2013 07:58:37 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: cut down log chatter in gssd_search_krb5_keytab
Message-ID: <20131107155837.GA16658@infradead.org>
References: <1383839253-8223-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1383839253-8223-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 07, 2013 at 10:47:33AM -0500, Jeff Layton wrote:
> Because the kernel now looks for krb5 creds by default when mounting, we
> need to always have clients run rpc.gssd to avoid the 15s hang on the
> first mount attempt.

Not sure if it's the same hangs, but I see about the same length of a
hang on my Debian wheezy systems when accessing the first file for a
data operation, with rpc.gssd running or not.  Funnily enough this also
happens when trying to read a non-existand file, but not for things like
a simple readdir.

Still looking into it, but being a non-interruptible sleep it's fairly
annoying.

That being said Debian wheezy also only starts rpc.gssd from the init
scripts if it sees a krb option in /etc/fstab, which I don't have.


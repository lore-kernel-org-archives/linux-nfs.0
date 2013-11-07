Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6428 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753123Ab3KGQJx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Nov 2013 11:09:53 -0500
Date: Thu, 7 Nov 2013 11:09:28 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: cut down log chatter in gssd_search_krb5_keytab
Message-ID: <20131107110928.68244ea7@tlielax.poochiereds.net>
In-Reply-To: <20131107155837.GA16658@infradead.org>
References: <1383839253-8223-1-git-send-email-jlayton@redhat.com>
	<20131107155837.GA16658@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 7 Nov 2013 07:58:37 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Nov 07, 2013 at 10:47:33AM -0500, Jeff Layton wrote:
> > Because the kernel now looks for krb5 creds by default when mounting, we
> > need to always have clients run rpc.gssd to avoid the 15s hang on the
> > first mount attempt.
> 
> Not sure if it's the same hangs, but I see about the same length of a
> hang on my Debian wheezy systems when accessing the first file for a
> data operation, with rpc.gssd running or not.  Funnily enough this also
> happens when trying to read a non-existand file, but not for things like
> a simple readdir.
> 
> Still looking into it, but being a non-interruptible sleep it's fairly
> annoying.
> 
> That being said Debian wheezy also only starts rpc.gssd from the init
> scripts if it sees a krb option in /etc/fstab, which I don't have.
> 

It may be the same issue. IIRC, the attempt to use krb5i by default
is done in the SETCLIENTID call (see kernel commit 4edaa30888 for some
background, but there were some later tweaks to this approach).

-- 
Jeff Layton <jlayton@redhat.com>

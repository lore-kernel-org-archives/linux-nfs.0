Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750805Ab3IZPfx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 11:35:53 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1380209415.17366.66.camel@joe-AO722>
References: <1380209415.17366.66.camel@joe-AO722> <20130926144502.29424.21633.stgit@warthog.procyon.org.uk> <20130926144525.29424.11130.stgit@warthog.procyon.org.uk>
To: Joe Perches <joe@perches.com>
Cc: dhowells@redhat.com, bfields@fieldses.org, Trond.Myklebust@netapp.com,
        olof@lixom.net, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] SunRPC: Use no_printk() for the null dprintk() and dfprintk()
Date: Thu, 26 Sep 2013 16:35:43 +0100
Message-ID: <30597.1380209743@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:

> no_printk doesn't prevent any argument side-effects
> from being optimized away by the compiler.
> 
> ie:
> 	dprintk("%d", func())
> func is now always called when before it wasn't.

Yes, I know.  There are half a dozen places where this is the case.  Those
I've wrapped in ifdebug(FACILITY) { ... } in the code.  It's not the nicest,
but at least the compiler always gets to see everything, rather than bits of
it getting hidden by the preprocessor - which means the call points will be
less likely to bit rot over time.

David

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:29319 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752775Ab3IZPmn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 11:42:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: David Howells <dhowells@redhat.com>, Joe Perches <joe@perches.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "olof@lixom.net" <olof@lixom.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 3/4] SunRPC: Use no_printk() for the null dprintk() and
 dfprintk()
Date: Thu, 26 Sep 2013 15:42:41 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9467EB252@SACEXCMBX04-PRD.hq.netapp.com>
References: <1380209415.17366.66.camel@joe-AO722>
 <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
 <20130926144525.29424.11130.stgit@warthog.procyon.org.uk>
 <30597.1380209743@warthog.procyon.org.uk>
In-Reply-To: <30597.1380209743@warthog.procyon.org.uk>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: David Howells [mailto:dhowells@redhat.com]
> Sent: Thursday, September 26, 2013 10:36 AM
> To: Joe Perches
> Cc: dhowells@redhat.com; bfields@fieldses.org; Myklebust, Trond;
> olof@lixom.net; linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH 3/4] SunRPC: Use no_printk() for the null dprintk() and
> dfprintk()
> 
> Joe Perches <joe@perches.com> wrote:
> 
> > no_printk doesn't prevent any argument side-effects from being
> > optimized away by the compiler.
> >
> > ie:
> > 	dprintk("%d", func())
> > func is now always called when before it wasn't.
> 
> Yes, I know.  There are half a dozen places where this is the case.  Those I've
> wrapped in ifdebug(FACILITY) { ... } in the code.  It's not the nicest, but at
> least the compiler always gets to see everything, rather than bits of it getting
> hidden by the preprocessor - which means the call points will be less likely to
> bit rot over time.

Your assumption is that RPC_DEBUG is disabled for most compiles. That is not the case.

Trond

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093Ab3IZPmz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 11:42:55 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1380209888.17366.68.camel@joe-AO722>
References: <1380209888.17366.68.camel@joe-AO722> <1380209415.17366.66.camel@joe-AO722> <20130926144502.29424.21633.stgit@warthog.procyon.org.uk> <20130926144525.29424.11130.stgit@warthog.procyon.org.uk> <30597.1380209743@warthog.procyon.org.uk>
To: Joe Perches <joe@perches.com>
Cc: dhowells@redhat.com, bfields@fieldses.org, Trond.Myklebust@netapp.com,
        olof@lixom.net, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] SunRPC: Use no_printk() for the null dprintk() and dfprintk()
Date: Thu, 26 Sep 2013 16:42:47 +0100
Message-ID: <30738.1380210167@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:

> No code is eliminated by the preprocessor
> with the #define I suggest.

Sorry, I misunderstood.  I assumed you meant comparing to:

	#ifdef RPC_DEBUG
	#define dfprintk(...) ...
	#else
	#define dfprintk(...) do {} while(0)
	#endif

sort of thing which would certainly eliminate code in cpp.

So, yes, you're right.  So I shouldn't need to put the

	ifdebug(FACILITY) { ... }

clauses into the code as the function calls in the argument list will be
behind the if-statement anyway.

David

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: High load in 2.6.27, NFS / rpcauth_lookup_credcache()?
Date: Fri, 24 Oct 2008 14:09:23 -0400
Message-ID: <1224871763.22672.33.camel@localhost>
References: <20081022091207.GA12996@squirrel.roonstrasse.net>
	 <20081023123628.GA18549@squirrel.roonstrasse.net>
	 <1224773745.7625.4.camel@localhost>
	 <20081024083913.GA15197@squirrel.roonstrasse.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:38723 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbYJXSJ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Oct 2008 14:09:28 -0400
In-Reply-To: <20081024083913.GA15197-2pNSKKP3PSJxEiad3KpGLI/oZP4lHnOC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-10-24 at 10:39 +0200, Max Kellermann wrote:
> On 2008/10/23 16:55, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > Can you add a '-v' to the rpc.gssd daemon startup line? I'd like to see
> > how often you are creating new gss contexts.
> 
> There is no rpc.gssd running on any of these servers, we're using
> plain NFSv3 without (protocol based) authentication.  Do you want me
> to start it anyway?

Sorry. I misread your email. I read it as saying that you had krb5
enabled on your mountpoint, but what you really said was just that you
have compiled up the module.

OK, could you please describe your environment a bit. Do you have lots
of different users logged in at the same time, or do you perhaps use
newgrp or su to switch uid/gids a lot on your processes?
I'm trying to see if there might be a reason for the lookup in the
credcache being such a heavy duty operation in your setup.

Cheers
  Trond


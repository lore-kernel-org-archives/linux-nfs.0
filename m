From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Patch?: linux-2.5.42/net/sunrpc/sunrpc_syms.c - symbols needed by new nfsd
Date: Mon, 14 Oct 2002 08:55:17 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15785.63957.167015.415347@notabene.cse.unsw.edu.au>
References: <20021013112452.A286@baldur.yggdrasil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: okir@monad.swb.de, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <adam@yggdrasil.com>) (for <okir@monad.swb.de>)
	(for <nfs@lists.sourceforge.net>)
	(for <linux-kernel@vger.kernel.org>) By tone With Smtp ;
	Mon, 14 Oct 2002 08:55:27 +1000
To: "Adam J. Richter" <adam@yggdrasil.com>
In-Reply-To: message from Adam J. Richter on Sunday October 13
List-ID: <nfs.lists.sourceforge.net>

On Sunday October 13, adam@yggdrasil.com wrote:
> 	nfsd in 2.5.42 needs a bunch of symbols that the sunrpc module
> does not export.  This patch adds them to net/sunrpc/sunrpc_syms.c.
> I am now running the nfsd and sunrpc modules based on this patch.

Thanks.  A similar patch has been sent to Linus and hopefully will
appear in bk soon...

NeilBrown

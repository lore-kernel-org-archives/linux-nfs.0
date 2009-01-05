From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/3] SUNRPC: svc_xprt_enqueue should not refuse to
 enqueue 'XPT_DEAD' transports
Date: Mon, 05 Jan 2009 15:48:38 -0500
Message-ID: <1231188518.7127.30.camel@heimdal.trondhjem.org>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>
	 <1225539927.2221.3.camel@localhost.localdomain>
	 <1225546878.4390.3.camel@heimdal.trondhjem.org>
	 <1227596962.16868.22.camel@localhost.localdomain>
	 <1227619696.7057.19.camel@heimdal.trondhjem.org>
	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>
	 <1227621434.7057.33.camel@heimdal.trondhjem.org>
	 <1227621877.9425.102.camel@zakaz.uk.xensource.com>
	 <1227737539.31008.2.camel@localhost.localdomain>
	 <1228090631.7112.11.camel@heimdal.trondhjem.org>
	 <1228090815.7112.15.camel@heimdal.trondhjem.org>
	 <49491C58.9@opengridcomputing.com>
	 <1229540877.7257.97.camel@heimdal.trondhjem.org>
	 <495E8AB2.8020805@opengridcomputing.com>
	 <1231096358.7363.6.camel@heimdal.trondhjem.org>
	 <1231097131.7363.11.camel@heimdal.trondhjem.org>
	 <49623DB4.6090103@opengridcomputing.com>
	 <1231175613.7127.6.camel@heimdal.trondhjem.org>
	 <49626085.9020609@opengridcomputing.com>
	 <1231185115.7127.28.camel@heimdal.trondhjem.org>
	 <49627092.3090405@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:53360 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbZAEUso (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2009 15:48:44 -0500
In-Reply-To: <49627092.3090405@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-01-05 at 14:41 -0600, Tom Tucker wrote:
> Trond, this version removes the extra unnecessary spin locks.
> 
> If it's ok, do you want me to resend to Bruce, or
> do you want to couple it with your other patch?

As long as it applies on top of my patch, then just send it on to Bruce.

Cheers
  Trond


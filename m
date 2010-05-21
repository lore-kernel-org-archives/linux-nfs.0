From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: fix leak on error on socket xprt setup
Date: Fri, 21 May 2010 09:16:19 -0400
Message-ID: <1274447779.3692.8.camel@heimdal.trondhjem.org>
References: <20100521002508.GA30928@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14032 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752561Ab0EUNQU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 May 2010 09:16:20 -0400
In-Reply-To: <20100521002508.GA30928@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-05-20 at 20:25 -0400, J. Bruce Fields wrote: 
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> Also collect exit code together while we're at it.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  net/sunrpc/xprtsock.c |   29 ++++++++++++++++++-----------
>  1 files changed, 18 insertions(+), 11 deletions(-)
> 
> I think I sent this before, but it must have fallen through the cracks.

The patch doesn't really ring a bell, but it looks correct. On the other
hand, this doesn't look like a bug we'd ever hit in practice, so I'll
probably delay merging it until I've got a few more critical bugfixes
queued up.

Unless, of course, you'd prefer to merge it yourself?

Cheers
  Trond

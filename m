From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/13] sunrpc: Compact the xprtsock code a bit
Date: Mon, 11 Oct 2010 19:47:11 -0400
Message-ID: <20101011234711.GC16442@fieldses.org>
References: <4CA9CDA8.4010407@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond@netapp.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41139 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753561Ab0JKXrM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 19:47:12 -0400
In-Reply-To: <4CA9CDA8.4010407@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 04, 2010 at 04:50:48PM +0400, Pavel Emelyanov wrote:
> Hi!
> 
> This set removes some unused parts of code and merges together
> routines that are related to the sockets creation.
> 
> After all the changes the result is
> 
>  net/sunrpc/xprtsock.c: 77 insertions(+), 206 deletions(-)
> 
> from the code-lines point of view and
> 
>   add/remove: 2/11 grow/shrink: 4/1 up/down: 879/-1626 (-747)
> 
> from the bloat-o-meter's point of view.

I'm assuming Trond is taking these.  Let me know if that doesn't
work....

--b.

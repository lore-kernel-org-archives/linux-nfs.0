Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45900 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab0KPPdB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Nov 2010 10:33:01 -0500
Date: Tue, 16 Nov 2010 10:33:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] sunrpc: fix two server-side race problems.
Message-ID: <20101116153259.GD23781@fieldses.org>
References: <20101115002634.19121.7027.stgit@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101115002634.19121.7027.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Nov 15, 2010 at 11:27:01AM +1100, NeilBrown wrote:
> 
> Hi Bruce,
>  I found these while trying to diagnose why a customer hit the
>  	BUG_ON(xprt->xpt_pool != NULL);
>  in svc_xprt_enqueue (in a 2.6.27 based kernel).  I don't think either
>  of these actually explain the problem, but they seem to be bugs
>  none-the-less.

Yes.  Inclined to queue these up for the next merge window, though, as
neither seems urgent.

--b.

From: Dave Chinner <dchinner@redhat.com>
Subject: Re: [PATCH] SUNRPC auth: add context argument to shrinker callback
Date: Thu, 22 Jul 2010 10:13:55 +1000
Message-ID: <20100722001355.GB31881@devil>
References: <1279698095-17287-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab0GVAPG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 20:15:06 -0400
In-Reply-To: <1279698095-17287-1-git-send-email-mkl@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 21, 2010 at 09:41:35AM +0200, Marc Kleine-Budde wrote:
> Hello,
> 
> I found this regression in the current mainline tree.

The fix is already in Linus' current git tree (commit
567c7b0edec0200c5c6613f07c3d3b4034fdc836 ("mm: add context argument to
shrinker callback to remaining shrinkers"). Thanks for catching
it, anyway.

Cheers,

Dave.
-- 
Dave Chinner
dchinner@redhat.com

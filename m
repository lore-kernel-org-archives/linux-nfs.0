Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64756 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756254Ab0J0WUu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 18:20:50 -0400
Date: Thu, 28 Oct 2010 00:20:37 +0200
From: Dan Carpenter <error27@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [patch] nfsd: fix NULL dereference in setattr()
Message-ID: <20101027222037.GO6062@bicker>
References: <20101027211904.GJ6062@bicker> <20101027215025.GB29477@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101027215025.GB29477@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Oct 27, 2010 at 05:50:25PM -0400, J. Bruce Fields wrote:
> On Wed, Oct 27, 2010 at 11:19:04PM +0200, Dan Carpenter wrote:
> > The original code would oops if this were called from nfsd4_setattr()
> > because "filpp" is NULL.
> 
> I believe it's impossible to reach this case: we never give out write
> delegations, so the preceding nfs4_check_delegmode will always fail when
> called from setattr.
> 
> We should do this anyway, but I'll probably queue it up for the next
> merge window.

Sounds good.  This was a static checker patch not a run time bug (as
you obviously realized).

regards,
dan carpenter


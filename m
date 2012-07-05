Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36523 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755138Ab2GETN0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jul 2012 15:13:26 -0400
Date: Thu, 5 Jul 2012 15:13:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Eldad Zack <eldad@fogrefinery.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] sunrpc/cache.h: replace simple_strtoul
Message-ID: <20120705191323.GA3051@fieldses.org>
References: <1341442827-21339-1-git-send-email-eldad@fogrefinery.com>
 <1341442827-21339-2-git-send-email-eldad@fogrefinery.com>
 <20120704235921.GA26797@fieldses.org>
 <alpine.DEB.2.02.1207052030500.6309@debianer>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.02.1207052030500.6309@debianer>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 05, 2012 at 09:04:03PM +0200, Eldad Zack wrote:
> 
> On Wed, 4 Jul 2012, J. Bruce Fields wrote:
> > On Thu, Jul 05, 2012 at 01:00:26AM +0200, Eldad Zack wrote:
> > > This patch replaces the usage of simple_strtoul with kstrtoint in
> > > get_int().
> > 
> > Why?
> 
> Since the simple_str* family don't account for overflow and AFAIK
> deprecated. Also, in this specific case, the long from strtol is 
> silently converted to an int by the caller.

OK, thanks.  Please use that as the changelog when you resend.  ("This
patch replaces..." tells me nothing I couldn't figure out from looking
at the patch.)

--b.

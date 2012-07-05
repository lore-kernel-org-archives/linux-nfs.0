Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47586 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666Ab2GET5P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jul 2012 15:57:15 -0400
Received: by eeit10 with SMTP id t10so3375768eei.19
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jul 2012 12:57:14 -0700 (PDT)
Date: Thu, 5 Jul 2012 21:57:05 +0200 (CEST)
From: Eldad Zack <eldad@fogrefinery.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] sunrpc/cache.h: replace simple_strtoul
In-Reply-To: <20120705191323.GA3051@fieldses.org>
Message-ID: <alpine.DEB.2.02.1207052122001.10395@debianer>
References: <1341442827-21339-1-git-send-email-eldad@fogrefinery.com> <1341442827-21339-2-git-send-email-eldad@fogrefinery.com> <20120704235921.GA26797@fieldses.org> <alpine.DEB.2.02.1207052030500.6309@debianer> <20120705191323.GA3051@fieldses.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Thu, 5 Jul 2012, J. Bruce Fields wrote:

> On Thu, Jul 05, 2012 at 09:04:03PM +0200, Eldad Zack wrote:
> > 
> > On Wed, 4 Jul 2012, J. Bruce Fields wrote:
> > > On Thu, Jul 05, 2012 at 01:00:26AM +0200, Eldad Zack wrote:
> > > > This patch replaces the usage of simple_strtoul with kstrtoint in
> > > > get_int().
> > > 
> > > Why?
> > 
> > Since the simple_str* family don't account for overflow and AFAIK
> > deprecated. Also, in this specific case, the long from strtol is 
> > silently converted to an int by the caller.
> 
> OK, thanks.  Please use that as the changelog when you resend.  ("This
> patch replaces..." tells me nothing I couldn't figure out from looking
> at the patch.)

Will do, sorry about that.

Eldad

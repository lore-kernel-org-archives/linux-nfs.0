Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:47816 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751029Ab0IVPtk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 11:49:40 -0400
Subject: Re: [PATCH 2/2] lockd: Mostly remove BKL from the server
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4C9A2406.6070100@netapp.com>
References: <4C9917B4.1010607@netapp.com>
	 <20100922153702.GD15560@fieldses.org>  <4C9A2406.6070100@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 22 Sep 2010 11:49:32 -0400
Message-ID: <1285170572.4811.48.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-09-22 at 11:43 -0400, Bryan Schumaker wrote:
> On 09/22/2010 11:37 AM, J. Bruce Fields wrote:
> > On Tue, Sep 21, 2010 at 04:38:12PM -0400, Bryan Schumaker wrote:
> >> lockd: Mostly remove BKL from the server
> >>
> >> This patch removes all but one call to lock_kernel() from the server.
> > 
> > Thanks.  Does this need to go in any particular order with respect to
> > the other BKL patches, or should I just apply this whenever?
> > 
> > --b.
> 
> It doesn't use lock_flocks(), so you should be able to apply it whenever.  

Note that a patch defining lock_flocks() in terms of the BKL went into
Linus' tree last night, so we no longer have to worry about that
dependency.

Cheers
  Trond


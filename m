Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36251 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262Ab3JAOrS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 10:47:18 -0400
Date: Tue, 1 Oct 2013 10:47:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Cc: Jongman Heo <jongman.heo@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Re: Regression caused by commit 4bdc33ed ("NFSDv4.2: Add NFS
 v4.2 support to the NFS server")
Message-ID: <20131001144716.GK26382@fieldses.org>
References: <42.19.15034.896B3425@epcpsbgx2.samsung.com>
 <20130926174742.GA5066@fieldses.org>
 <CABgxfbHyE04V_7YH2Zcqm+TAgCjT73kKWVGmKD30YxsriT+FMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CABgxfbHyE04V_7YH2Zcqm+TAgCjT73kKWVGmKD30YxsriT+FMw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 11:35:46AM -0700, Wendy Cheng wrote:
> On Thu, Sep 26, 2013 at 10:47 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > (BTW, out of curiosity: what kind of client is this that only supports
> > NFSv2 and NFSv3?  Even for an embedded system that's a bit surprising.)
> >
> 
> There are few floating around - at least I'm working on one at this moment.
> 
> Look to me the upgrade issue is with user space packages (e.g. where
> "mount" lives). Embedded systems can take their user space packages
> from certain "distribution"s that are not necessarily sync well with
> individual linux upstream tool distribution, even the kernel itself is
> reasonably updated.
> 
> And don't shoot a messenger :) .. I'm just describing the practices I
> have been observed.

OK.  I'm not sure what standard to hold this sort of change to.  I'm
inclined to use the same "it's OK if and only if nobody notices"
standard as for normal kernel interfaces.  Which means we've already got
enough evidence to put off dropping NFSv2 support for a few more years,
at least on the server side....

--b.

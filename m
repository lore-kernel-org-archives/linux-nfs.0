From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Mon, 29 Sep 2008 13:26:30 -0400
Message-ID: <20080929172630.GB23212@fieldses.org>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com> <RTPCLUEXC2-PRDM3SOl0000001f@RTPMVEXC1-PRD.hq.netapp.com> <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com> <RTPCLUEXC2-PRDNXRPm0000003a@RTPMVEXC1-PRD.hq.netapp.com> <b66ddc900809260857o39c4ef31h75af8e7eaf9448fc@mail.gmail.com> <1222445161.10150.4.camel@localhost> <b66ddc900809260913r6c009658p958d88aa2e1be99e@mail.gmail.com> <RTPCLUEXC2-PRDIIZS20000003d@RTPMVEXC1-PRD.hq.netapp.com> <b66ddc900809282121t6953e068n62870810f1d0874@mail.gmail.com> <b66ddc900809282153yb873d8ayf82f2a61eca9cc18@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: howard chen <howachen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47056 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819AbYI2R0d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 13:26:33 -0400
In-Reply-To: <b66ddc900809282153yb873d8ayf82f2a61eca9cc18-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 29, 2008 at 12:53:16PM +0800, howard chen wrote:
> Hello all,
> 
> On Mon, Sep 29, 2008 at 12:21 PM, howard chen <howachen@gmail.com> wrote:
> >
> > Yes, tested, and same error... Also tried "no_root_squash"...
> >
> > Really have no idea what is going on...
> >
> 
> Problem solved by adding the following line in fstab, according to
> this site: http://www.linuxforums.org/forum/linux-networking/44779-nfs-permission-denied-error.html

Huh.  Surely mountd or knfsd could have given a more helpful error
message, at least....

> nfsd /proc/fs/nfsd nfsd auto,defaults 0 0
> 
> 
> This is really funny as I never have this option in my other NFS servers....
> 
> Anyone know the reason? Redhat's bug?

It looks like nfsd is supposed to be mounted on load of the nfsd module,
by a line in /etc/modprobe.d/modprobe.conf.

(Maybe you built a new kernel with nfsd built-in instead of built as a
module?)

But I thought nfs-utils was supposed to fall back on old behavior when
the nfsd filesystem wasn't found.

--b.

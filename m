From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Tue, 30 Sep 2008 14:51:57 -0400
Message-ID: <20080930185157.GD12268@fieldses.org>
References: <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com> <RTPCLUEXC2-PRDNXRPm0000003a@RTPMVEXC1-PRD.hq.netapp.com> <b66ddc900809260857o39c4ef31h75af8e7eaf9448fc@mail.gmail.com> <1222445161.10150.4.camel@localhost> <b66ddc900809260913r6c009658p958d88aa2e1be99e@mail.gmail.com> <RTPCLUEXC2-PRDIIZS20000003d@RTPMVEXC1-PRD.hq.netapp.com> <b66ddc900809282121t6953e068n62870810f1d0874@mail.gmail.com> <b66ddc900809282153yb873d8ayf82f2a61eca9cc18@mail.gmail.com> <20080929172630.GB23212@fieldses.org> <b66ddc900809300651i11d07caudd32831d6954f02d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: howard chen <howachen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56922 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767AbYI3SwA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2008 14:52:00 -0400
In-Reply-To: <b66ddc900809300651i11d07caudd32831d6954f02d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 30, 2008 at 09:51:08PM +0800, howard chen wrote:
> Hello,
> 
> On Tue, Sep 30, 2008 at 1:26 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > It looks like nfsd is supposed to be mounted on load of the nfsd module,
> > by a line in /etc/modprobe.d/modprobe.conf.
> >
> > (Maybe you built a new kernel with nfsd built-in instead of built as a
> > module?)
> >
> > But I thought nfs-utils was supposed to fall back on old behavior when
> > the nfsd filesystem wasn't found.
> 
> 
> Are there any related docs I should read?

The "exportfs" man page explains a little about the "legacy" vs "new"
modes of mountd/exportfs operation.

> As mentioned before, the server was working before the reboot, really
> don't understand why it behave in this way...Need to find out the
> reason.

As I said, two things happened:
	1. The "nfsd" filesystem didn't get mounted under /proc/ as it's
	   suppose to be.
	2. The server therefore should have been using the "legacy" mode
	   of operation.  But it didn't work for some reason.

I'm not sure in either case.

If you do put an explicit nfsd mount in the fstab, then you won't see
this problem again.

--b.

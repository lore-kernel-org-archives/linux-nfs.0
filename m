From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problems with crossmnt since 1.2.1
Date: Mon, 1 Mar 2010 16:52:22 -0500
Message-ID: <20100301215222.GL23539@fieldses.org>
References: <20100228100643.GG26178@teal.hq.k1024.org> <20100301204010.GE23539@fieldses.org> <20100301211306.GA16341@teal.hq.k1024.org> <20100301213952.GK23539@fieldses.org> <20100301214116.GB16341@teal.hq.k1024.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43308 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315Ab0CAVvO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 16:51:14 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1NmDXK-0006XJ-Dh
	for linux-nfs@vger.kernel.org; Mon, 01 Mar 2010 16:52:22 -0500
In-Reply-To: <20100301214116.GB16341-kWFYwFCQMdQkLqoNrXjPMti2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 01, 2010 at 10:41:16PM +0100, Iustin Pop wrote:
> On Mon, Mar 01, 2010 at 04:39:52PM -0500, J. Bruce Fields wrote:
> > On Mon, Mar 01, 2010 at 10:13:06PM +0100, Iustin Pop wrote:
> > > For reference, here is the exports file I use for tests:
> > > /srv/nfs       client(sec=sys,ro,sync,fsid=0,subtree_check,crossmnt)
> > > /srv/nfs/homes client(sec=sys,rw,sync,subtree_check)
> > 
> > Is /srv/nfs/homes a mountpoint, or are both of these on the same
> > filesystem?
> 
> It is a mountpoint, in all my tests. I'll try tomorrow to run a test with them
> being on the same filesystem.

No, no point, the no-mountpoint case is the case we already *know*
doesn't work.

So, OK, I'll try this here.

--b.

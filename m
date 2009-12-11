From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: starting 90-second grace period
Date: Fri, 11 Dec 2009 15:09:31 -0500
Message-ID: <1260562171.15701.40.camel@localhost>
References: <f5b5ebae0912110300t78ceb985oc7a21b20a3429a52@mail.gmail.com>
	 <1629BB1E-EB8B-478C-8170-60413A5140A2@netapp.com>
	 <f5b5ebae0912110925o510667far7201adf429c18a5@mail.gmail.com>
	 <1260554515.15701.0.camel@localhost>
	 <f5b5ebae0912111009i4c665758gab583a34dbaea0d9@mail.gmail.com>
	 <1260555643.15701.4.camel@localhost>  <20091211195047.GA15758@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>,
	Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:45743 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779AbZLKUJa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 15:09:30 -0500
In-Reply-To: <20091211195047.GA15758@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-11 at 14:50 -0500, J. Bruce Fields wrote: 
> On Fri, Dec 11, 2009 at 01:20:43PM -0500, Trond Myklebust wrote:
> > On Fri, 2009-12-11 at 23:39 +0530, Tharindu Rukshan Bamunuarachchi
> > wrote: 
> > > then why is it 90 by default ... is it RFC/Protocol requirement ?
> > 
> > The purpose of the grace period is to give the clients enough time to
> > notice that the server has rebooted, and to reclaim their existing locks
> > without danger of having somebody else steal the lock from them.
> > 
> > It is not a protocol requirement, but it is definitely a strongly
> > recommended feaature if you don't want to see corruption in your
> > mailbox/database/logfile/... that relies on those locks.
> 
> There are a few things we could do to lessen the pain of the grace
> period, though--such as ending it when we know it's done.  (In the v4
> case, that's just when we know there are no clients to recover state; in
> the v4.1 case, that's when all the RECLAIM_COMPLETE's are done.)

You can't clear the grace period unless you know that all 3 protocols
are done. I.e. the list of NSM monitored clients was empty, the list of
NFSv4 clients was empty, and the NFSv4.1 reclaim_completes are all done
(or the list was empty).

In no case should it be done by adjusting the duration of the lease
period.

Trond


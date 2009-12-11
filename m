From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: starting 90-second grace period
Date: Fri, 11 Dec 2009 14:50:47 -0500
Message-ID: <20091211195047.GA15758@fieldses.org>
References: <f5b5ebae0912110300t78ceb985oc7a21b20a3429a52@mail.gmail.com> <1629BB1E-EB8B-478C-8170-60413A5140A2@netapp.com> <f5b5ebae0912110925o510667far7201adf429c18a5@mail.gmail.com> <1260554515.15701.0.camel@localhost> <f5b5ebae0912111009i4c665758gab583a34dbaea0d9@mail.gmail.com> <1260555643.15701.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>,
	Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44611 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755596AbZLKTup (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 14:50:45 -0500
In-Reply-To: <1260555643.15701.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 11, 2009 at 01:20:43PM -0500, Trond Myklebust wrote:
> On Fri, 2009-12-11 at 23:39 +0530, Tharindu Rukshan Bamunuarachchi
> wrote: 
> > then why is it 90 by default ... is it RFC/Protocol requirement ?
> 
> The purpose of the grace period is to give the clients enough time to
> notice that the server has rebooted, and to reclaim their existing locks
> without danger of having somebody else steal the lock from them.
> 
> It is not a protocol requirement, but it is definitely a strongly
> recommended feaature if you don't want to see corruption in your
> mailbox/database/logfile/... that relies on those locks.

There are a few things we could do to lessen the pain of the grace
period, though--such as ending it when we know it's done.  (In the v4
case, that's just when we know there are no clients to recover state; in
the v4.1 case, that's when all the RECLAIM_COMPLETE's are done.)

I'm hoping to work on that for 2.6.34.

--b.

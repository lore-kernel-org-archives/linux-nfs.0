Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:59029 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757948AbZLKSUl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 13:20:41 -0500
Subject: Re: starting 90-second grace period
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <f5b5ebae0912111009i4c665758gab583a34dbaea0d9@mail.gmail.com>
References: <f5b5ebae0912110300t78ceb985oc7a21b20a3429a52@mail.gmail.com>
	 <1629BB1E-EB8B-478C-8170-60413A5140A2@netapp.com>
	 <f5b5ebae0912110925o510667far7201adf429c18a5@mail.gmail.com>
	 <1260554515.15701.0.camel@localhost>
	 <f5b5ebae0912111009i4c665758gab583a34dbaea0d9@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 11 Dec 2009 13:20:43 -0500
Message-Id: <1260555643.15701.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-12-11 at 23:39 +0530, Tharindu Rukshan Bamunuarachchi
wrote: 
> then why is it 90 by default ... is it RFC/Protocol requirement ?

The purpose of the grace period is to give the clients enough time to
notice that the server has rebooted, and to reclaim their existing locks
without danger of having somebody else steal the lock from them.

It is not a protocol requirement, but it is definitely a strongly
recommended feaature if you don't want to see corruption in your
mailbox/database/logfile/... that relies on those locks.

Trond

> On Fri, Dec 11, 2009 at 11:31 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Fri, 2009-12-11 at 22:55 +0530, Tharindu Rukshan Bamunuarachchi
> > wrote:
> >> thankx a lot for the info.
> >>
> >> btw, if i set nfs4leasetime to ~10 seconds ... is there any negative effect ?
> >>
> >
> > You mean aside from the very likely event that your clients will lose
> > all their locks when the server reboots?
> >
> > Trond
> >
> >
> 
> 
> 




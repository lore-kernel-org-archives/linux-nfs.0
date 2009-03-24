From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: nfsd: Improve NFS server performance
Date: Wed, 25 Mar 2009 00:27:55 +0530
Message-ID: <OF797B0CB7.5BCB437F-ON65257583.0067F4DB-65257583.00682E3B@in.ibm.com>
References: <20081230104245.9409.30030.sendpatchset@localhost.localdomain> <20090204231958.GB20917@fieldses.org> <OF46E14C36.93250375-ON65257554.0050CEC8-65257554.005328DC@in.ibm.com> <20090205202401.GH9200@fieldses.org> <OFC7146FC3.ABEF6E81-ON65257556.001EB1D9-65257556.0032B679@in.ibm.com> <20090209190648.GA13636@fieldses.org> <01164826-9C05-41E0-A763-825A9C6E8CFF@oracle.com> <20090209210427.GJ13636@fieldses.org> <OFFC9EFD50.9BF4778E-ON65257583.0054B0F0-65257583.0056621F@in.ibm.com> <20090324180036.GB19389@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:45017 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbZCXTAO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2009 15:00:14 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2OJ09ie028508
	for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2009 00:30:09 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2OIucf63358784
	for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2009 00:26:39 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2OJ08wt029706
	for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2009 06:00:08 +1100
In-Reply-To: <20090324180036.GB19389@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK, I will break the attachments into text files tomorrow :) I will send
everything but the
profile data once again.

thanks,
- KK

"J. Bruce Fields" <bfields@fieldses.org> wrote on 03/24/2009 11:30:36 PM:

> "J. Bruce Fields" <bfields@fieldses.org>
> 03/24/2009 11:30 PM
>
> To
>
> Krishna Kumar2/India/IBM@IBMIN
>
> cc
>
> Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
>
> Subject
>
> Re: nfsd: Improve NFS server performance
>
> On Tue, Mar 24, 2009 at 09:13:32PM +0530, Krishna Kumar2 wrote:
> > Hi Bruce,
> >
> > I am sorry about the delay due to some unavoidable circumstances.
However,
> > I have
> > got most of the details that you and Jeff had asked for. I am
including:
> >
> > 1. Patch (on latest git tree):
> >       (See attached file: patch0)            (See attached file:
patch1)
> >
> > 2. Results (for org, using daemon, using workqueue):
> >       (See attached file: result.daemon)    (See attached file:
result.wq)
> >   (See attached file: result.summary)
> >
> > 3. Profile data (for org, using daemon, using workqueue):
> >       (See attached file: profiles.bz2)
> >
> > 4. A small write up:
> >       (See attached file: write_up)
> >
> > 5. The test program:
> >       (See attached file: read_files.c)
> >
> > Sorry about the large attachment in step #3 above, I didn't know if I
> > should put it some place. Also if required, I can submit patches
breaking
> > up this monolithic one.
>
> Thanks, I'll take a look (maybe not immediately).  Probably Jeff will
> too, but as long as a) there's a large monolithic patch, and b) all of
> this is in attachments--I'm afraid nobody else may bother.
>
> So it'd be more helpful to send this information in the body of email
> (more than one email if needed)--that way there's a greater chance other
> people will pay attention, and (with luck) have some useful idea to
> contribute.
>
> Thanks!--b.


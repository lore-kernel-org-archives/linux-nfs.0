Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50341 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853Ab0J3Vlb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Oct 2010 17:41:31 -0400
Subject: Re: Error: state manager failed on NFSv4 server linux with error
 127
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1288474164.32627.383.camel@pc>
References: <1287334833.4871.6.camel@pc>
	 <1287340520.5266.70.camel@heimdal.trondhjem.org>
	 <1288460514.32627.105.camel@pc>
	 <1288461151.3238.9.camel@heimdal.trondhjem.org>
	 <1288461562.32627.151.camel@pc>
	 <1288462786.3238.16.camel@heimdal.trondhjem.org>
	 <1288474164.32627.383.camel@pc>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 30 Oct 2010 17:41:26 -0400
Message-ID: <1288474886.8621.3.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-10-30 at 17:29 -0400, Brian J. Murrell wrote: 
> On Sat, 2010-10-30 at 14:19 -0400, Trond Myklebust wrote: 
> > 
> > BTW: Do you have the following patches applied?
> >   http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=b0ed9dbc24f1fd912b2dd08b995153cafc1d5b1c
> > and
> >   http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=ae1007d37e00144b72906a4bdc47d517ae91bcc1
> 
> These patches both deal with recovery issues, which you mentioned seems
> to be the state the previously posted stack traces where in also.
> 
> Since the server has not been rebooted or even had its export list
> reread/reexported, I wonder why recovery would have been triggered, to
> cause this client problem.
> 
> Does recovery actually get invoked on the client for events other than
> an outright restart of NFS on the server?  NFS on the server here should
> have been entirely stable over the period of time in which this client
> went bad.

There are 2 cases which can trigger recovery: server reboot, and network
partition (i.e. a networking fault that causes the client to be unable
to contact the server in time in order to renew its lease).

If none of the above apply, then we need to look at whether it is the
client or the server that is screwed up.

Trond


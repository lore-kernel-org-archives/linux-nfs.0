Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45117 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282Ab0J3UYv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Oct 2010 16:24:51 -0400
Subject: Re: Error: state manager failed on NFSv4 server linux with error
 127
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1288468435.32627.279.camel@pc>
References: <1287334833.4871.6.camel@pc>
	 <1287340520.5266.70.camel@heimdal.trondhjem.org>
	 <1288460514.32627.105.camel@pc>
	 <1288461151.3238.9.camel@heimdal.trondhjem.org>
	 <1288461562.32627.151.camel@pc>
	 <1288462786.3238.16.camel@heimdal.trondhjem.org>
	 <1288468435.32627.279.camel@pc>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 30 Oct 2010 16:24:46 -0400
Message-ID: <1288470286.3238.17.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-10-30 at 15:53 -0400, Brian J. Murrell wrote:
> On Sat, 2010-10-30 at 14:19 -0400, Trond Myklebust wrote: 
> > 
> > It will be running a process with a name of the form "<server IP
> > address>-manager", and will be running the function
> > nfs4_run_state_manager().
> 
> I will keep an eye out for that the next time I see this problem.
> 
> > BTW: Do you have the following patches applied?
> >   http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=b0ed9dbc24f1fd912b2dd08b995153cafc1d5b1c
> > and
> >   http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=ae1007d37e00144b72906a4bdc47d517ae91bcc1
> 
> Nope.
> 
> > They are not yet in the stable kernel series,
> 
> Which would be why I don't have them.  I am working with a 2.6.35
> kernel.
> 
> > AFAIK, but are slated to
> > be merged soon.
> 
> I take that mentioning them in this context means they would be good to
> have?  Safe to apply to 2.6.35.4ish kernel?

Yes.


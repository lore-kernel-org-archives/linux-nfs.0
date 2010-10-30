Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63856 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755053Ab0J3SUE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Oct 2010 14:20:04 -0400
Subject: Re: Error: state manager failed on NFSv4 server linux with error
 127
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1288461562.32627.151.camel@pc>
References: <1287334833.4871.6.camel@pc>
	 <1287340520.5266.70.camel@heimdal.trondhjem.org>
	 <1288460514.32627.105.camel@pc>
	 <1288461151.3238.9.camel@heimdal.trondhjem.org>
	 <1288461562.32627.151.camel@pc>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 30 Oct 2010 14:19:46 -0400
Message-ID: <1288462786.3238.16.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-10-30 at 13:59 -0400, Brian J. Murrell wrote:
> On Sat, 2010-10-30 at 13:52 -0400, Trond Myklebust wrote: 
> > 
> > The processes appeared to be waiting for state recovery to complete, but
> > your trace didn't contain any evidence that a state recovery thread was
> > running.
> 
> To be clear, the trace was only that of blocked processes (echo w
> > /proc/sysrq-trigger).  I'm not sure if we should have expected the
> state recovery thread to have been included (i.e. it was blocked too).
> 
> > Did you over-edit the trace output, or was this really all?
> 
> Other than the usual post-show-blocked-state output, yes, this really
> was all there was.
> 
> What does the state recovery thread look like in the process table so
> that I can look for it next time?

It will be running a process with a name of the form "<server IP
address>-manager", and will be running the function
nfs4_run_state_manager().

BTW: Do you have the following patches applied?
  http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=b0ed9dbc24f1fd912b2dd08b995153cafc1d5b1c
and
  http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=ae1007d37e00144b72906a4bdc47d517ae91bcc1

They are not yet in the stable kernel series, AFAIK, but are slated to
be merged soon.

Cheers
  Trond

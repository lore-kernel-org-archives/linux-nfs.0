Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16639 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754833Ab0J3RxH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Oct 2010 13:53:07 -0400
Subject: Re: Error: state manager failed on NFSv4 server linux with error
 127
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1288460514.32627.105.camel@pc>
References: <1287334833.4871.6.camel@pc>
	 <1287340520.5266.70.camel@heimdal.trondhjem.org>
	 <1288460514.32627.105.camel@pc>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 30 Oct 2010 13:52:31 -0400
Message-ID: <1288461151.3238.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-10-30 at 13:41 -0400, Brian J. Murrell wrote:
> On Sun, 2010-10-17 at 14:35 -0400, Trond Myklebust wrote: 
> > 
> > Error 127 is EKEYEXPIRED. It means that the RPCSEC_GSS context for at
> > least one of your threads has expired.
> > 
> > Sigh... It looks as if we have a really poor handling of that in the
> > recovery threads.
> > 
> > Does the following patch help?
> 
> Well, while I don't seem to have had any of the state manager failed
> errors, I did have a number of processes blocked in NFS4 today with the
> patched kernel running:
> 
> [316999.281908] SysRq : Show Blocked State
> [316999.285576]   task                PC stack   pid father
> [316999.285576] rhythmbox     D f32d1c9c     0 12726  12614 0x00000000
<snip>
> 
> Maybe the above is an unrelated problem?

The processes appeared to be waiting for state recovery to complete, but
your trace didn't contain any evidence that a state recovery thread was
running. Did you over-edit the trace output, or was this really all?

Trond

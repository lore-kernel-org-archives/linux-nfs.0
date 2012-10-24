Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:49433 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934915Ab2JXO45 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 10:56:57 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chris Perl <chris.perl@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: RPC Race Condition
Date: Wed, 24 Oct 2012 14:56:55 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA90928F920@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121022180339.GC24763@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909289403@SACEXCMBX04-PRD.hq.netapp.com>
 <20121022202611.GA27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928AB39@SACEXCMBX04-PRD.hq.netapp.com>
 <20121023134551.GB27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928C74A@SACEXCMBX04-PRD.hq.netapp.com>
 <20121023200855.GC27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928DCDD@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024124047.GD27191@nyc-qws-132.nyc.delacy.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90928F571@SACEXCMBX04-PRD.hq.netapp.com>
 <20121024142333.GE27191@nyc-qws-132.nyc.delacy.com>
In-Reply-To: <20121024142333.GE27191@nyc-qws-132.nyc.delacy.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Chris Perl [mailto:chris.perl@gmail.com]
> Sent: Wednesday, October 24, 2012 10:24 AM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: RPC Race Condition
> 
> On Wed, Oct 24, 2012 at 01:04:16PM +0000, Myklebust, Trond wrote:
> > Cool! Would you mind if I add "Tested-by" tags?
> 
> Wouldn't mind at all.
> 
> I've also run several of the filebench [1] workload personalities with this
> patched kernel for ten minutes a piece (i.e. the `fileserver' and `networkfs'
> personalities) and experienced no problems.  During the tests I also added
> the blackhole route to the server several times (along with restarting the NFS
> server) and it recovered each time.  I did this for filebench running
> SCHED_OTHER and SCHED_RR with a priority of 50.
> 
> > Sure. I'll let you know as soon as I push them out later today...
> 
> Cool, I'll keep an eye out.

OK, I've now posted the patches in the "bugfixes" branch of

       git://git.linux-nfs.org/projects/trondmy/linux-nfs.git

By the way, you said that you were using a set of systemtap scripts to debug these races? If you'd be OK sharing those scripts, I'd love to see them. Debugging this kind of race is always difficult...

Cheers
  Trond

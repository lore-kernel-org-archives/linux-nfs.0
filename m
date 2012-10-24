Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:34028 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934800Ab2JXOXh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 10:23:37 -0400
Received: by mail-gg0-f174.google.com with SMTP id k5so81990ggd.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 07:23:37 -0700 (PDT)
Date: Wed, 24 Oct 2012 10:23:33 -0400
From: Chris Perl <chris.perl@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RPC Race Condition
Message-ID: <20121024142333.GE27191@nyc-qws-132.nyc.delacy.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90928F571@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 24, 2012 at 01:04:16PM +0000, Myklebust, Trond wrote:
> Cool! Would you mind if I add "Tested-by" tags?

Wouldn't mind at all.

I've also run several of the filebench [1] workload personalities with
this patched kernel for ten minutes a piece (i.e. the `fileserver' and
`networkfs' personalities) and experienced no problems.  During the
tests I also added the blackhole route to the server several times
(along with restarting the NFS server) and it recovered each time.  I
did this for filebench running SCHED_OTHER and SCHED_RR with a priority
of 50.

> Sure. I'll let you know as soon as I push them out later today...

Cool, I'll keep an eye out.

Chris

[1] http://sourceforge.net/apps/mediawiki/filebench/index.php?title=Filebench

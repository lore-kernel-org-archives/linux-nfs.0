Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44707 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864Ab0HZKml (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Aug 2010 06:42:41 -0400
Date: Thu, 26 Aug 2010 20:42:29 +1000
From: Neil Brown <neilb@suse.de>
To: sfaibish <sfaibish@emc.com>
Cc: "Peng Yu" <pengyu.ut@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Does the machine need to be restarted after RPCNFSDCOUNT in
 /etc/default/nfs-kernel-server (ubuntu) is edited?
Message-ID: <20100826204229.28aa9459@notabene>
In-Reply-To: <op.vh1ivtybunckof@usensfaibisl2e.eng.emc.com>
References: <AANLkTi=8rnEtOikhVqsH5Pj1QUhc5MiSHMfncZO1xCem@mail.gmail.com>
	<20100826093648.26d03c1c@notabene>
	<op.vh0qucfsunckof@usensfaibisl2e.eng.emc.com>
	<20100826103152.05627abb@notabene>
	<op.vh1ivtybunckof@usensfaibisl2e.eng.emc.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 26 Aug 2010 06:17:43 -0400
sfaibish <sfaibish@emc.com> wrote:

> On Wed, 25 Aug 2010 20:31:52 -0400, Neil Brown <neilb@suse.de> wrote:
> 
> > On Wed, 25 Aug 2010 20:12:02 -0400
> > sfaibish <sfaibish@emc.com> wrote:
> >
> >> On Wed, 25 Aug 2010 19:36:48 -0400, Neil Brown <neilb@suse.de> wrote:
> >>
> >> > On Wed, 25 Aug 2010 15:02:14 -0500
> >> > Peng Yu <pengyu.ut@gmail.com> wrote:
> >> >
> >> >> Hi,
> >> >>
> >> >> I changed the value of RPCNFSDCOUNT in /etc/default/nfs-kernel-server
> >> >> (ubuntu). Do I need to restart the machine?
> >> >>
> >> >> Or I need to restart nfsd? If so, would you please let me know how to
> >> >> restart nfsd?
> >> >>
> >> >
> >> > Easiest thing to do is simply
> >> >
> >> >    rpc.nfsd $NUMBER
> >> >
> >> > it will change the number of running threads to match the number that  
> >> you
> >> > give.
> >> You still need to stop and restart the nfs for this to take effect.
> >
> > Have you tried it?
> Have you? Obviously not.
> 
> >
> > I assure you that running rpc.nfsd like this does change the number of
> > threads from whatever it is to the given number. (I should know, I wrote  
> > the
> > code :-)
> No it does not if you check how many daemons are running (ps) you will see  
> that it only
> changed the value not the number of running daemons.

We must be talking about different things.

sh-4.1# ps axgu | grep nfsd
root      2771  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd4]
root      2772  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2773  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2774  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2775  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2776  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2777  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2778  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2779  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      9621  0.0  0.0 112308   868 pts/14   S+   20:39   0:00 grep nfsd
sh-4.1# rpc.nfsd 16
sh-4.1# ps axgu | grep nfsd
root      2771  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd4]
root      2772  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2773  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2774  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2775  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2776  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2777  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2778  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2779  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      9623  0.0  0.0      0     0 ?        S    20:39   0:00 [nfsd]
root      9624  0.0  0.0      0     0 ?        S    20:39   0:00 [nfsd]
root      9625  0.0  0.0      0     0 ?        S    20:39   0:00 [nfsd]
root      9626  0.0  0.0      0     0 ?        S    20:39   0:00 [nfsd]
root      9627  0.0  0.0      0     0 ?        S    20:39   0:00 [nfsd]
root      9628  0.0  0.0      0     0 ?        S    20:39   0:00 [nfsd]
root      9629  0.0  0.0      0     0 ?        S    20:39   0:00 [nfsd]
root      9630  0.0  0.0      0     0 ?        S    20:39   0:00 [nfsd]
root      9632  0.0  0.0 112308   868 pts/14   S+   20:39   0:00 grep nfsd
sh-4.1# rpc.nfsd 3
sh-4.1# ps axgu | grep nfsd
root      2771  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd4]
root      2772  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2773  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      2774  0.0  0.0      0     0 ?        S    Aug20   0:00 [nfsd]
root      9635  0.0  0.0 112308   864 pts/14   S+   20:39   0:00 grep nfsd
sh-4.1# 


So when I run "rpc.nfsd N" and I check with "ps" how many deamons are
running, I find that N are running.

Maybe you mean something different??

NeilBrown

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56532 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752357Ab0HZAcD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Aug 2010 20:32:03 -0400
Date: Thu, 26 Aug 2010 10:31:52 +1000
From: Neil Brown <neilb@suse.de>
To: sfaibish <sfaibish@emc.com>
Cc: "Peng Yu" <pengyu.ut@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Does the machine need to be restarted after RPCNFSDCOUNT in
 /etc/default/nfs-kernel-server (ubuntu) is edited?
Message-ID: <20100826103152.05627abb@notabene>
In-Reply-To: <op.vh0qucfsunckof@usensfaibisl2e.eng.emc.com>
References: <AANLkTi=8rnEtOikhVqsH5Pj1QUhc5MiSHMfncZO1xCem@mail.gmail.com>
	<20100826093648.26d03c1c@notabene>
	<op.vh0qucfsunckof@usensfaibisl2e.eng.emc.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 25 Aug 2010 20:12:02 -0400
sfaibish <sfaibish@emc.com> wrote:

> On Wed, 25 Aug 2010 19:36:48 -0400, Neil Brown <neilb@suse.de> wrote:
> 
> > On Wed, 25 Aug 2010 15:02:14 -0500
> > Peng Yu <pengyu.ut@gmail.com> wrote:
> >
> >> Hi,
> >>
> >> I changed the value of RPCNFSDCOUNT in /etc/default/nfs-kernel-server
> >> (ubuntu). Do I need to restart the machine?
> >>
> >> Or I need to restart nfsd? If so, would you please let me know how to
> >> restart nfsd?
> >>
> >
> > Easiest thing to do is simply
> >
> >    rpc.nfsd $NUMBER
> >
> > it will change the number of running threads to match the number that you
> > give.
> You still need to stop and restart the nfs for this to take effect.

Have you tried it?

I assure you that running rpc.nfsd like this does change the number of
threads from whatever it is to the given number. (I should know, I wrote the
code :-)

NeilBrown

> 
> /Sorin
> 
> >
> > NeilBrown
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> >
> 
> 
> 


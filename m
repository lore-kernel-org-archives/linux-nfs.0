From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: nfs-utils atomicio.c
Date: Mon, 19 Jul 2010 12:30:25 -0400
Message-ID: <1279557025.8180.6.camel@moss-terrapins.epoch.ncsc.mil>
References: <20100716193508.GA14878@merit.edu>
	 <1279310952.8180.0.camel@moss-terrapins.epoch.ncsc.mil>
	 <20100716205355.GA7962@merit.edu> <4C40C8DF.8030107@RedHat.com>
	 <20100716220609.GA7828@merit.edu>
	 <1279319622.8180.2.camel@moss-terrapins.epoch.ncsc.mil>
	 <4C447034.4020006@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.65.40]:35233 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936439Ab0GSQku (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jul 2010 12:40:50 -0400
In-Reply-To: <4C447034.4020006-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-07-19 at 11:33 -0400, Steve Dickson wrote:
> 
> On 07/16/2010 06:33 PM, David P. Quigley wrote:
> > On Fri, 2010-07-16 at 18:06 -0400, Jim Rees wrote:
> >> Steve Dickson wrote:
> >>
> >>   > strlcat and strlcpy should probably go too.
> >>   Anything else?
> >>
> >> I don't see any other library functions that should move.  Configure should
> >> check for strlcat and strlcpy, and not compile them if there are system
> >> versions.  Again, I'll do that if no one beats me to it.
> >>
> >> On a related note, I've been using benny's pnfs-nfs-utils.git tree as a base
> >> for adding the block layout helper, as suggested by the wiki.  Is that
> >> correct?
> > 
> > Just got back from dinner and I'm heading out soon for the weekend but
> > here is the patch that I have. It should apply on top of
> > 2ef57222b10a91f4b96a06808d05a47e8f4c14f7 and moves strlcat and strlcpy
> > as well. The only think you might have to check is I know at some point
> > some changes were made to cfg.c and cfg.h make sure the ones I have in
> > this patch are the new ones instead of the old ones. I'd take a closer
> > look but I'm short on time here.
> > 
> >
> Question: Is there a reason need a private version of queue.h, instead
> of using the one ins /usr/include/sys?
> 
> steved.

Hello Steve,
   At one point there was a cfg.c and cfg.h for idmapd. That was
probably when I first made this patch a year or so ago. I use guilt for
patch management so I've been rebasing those patches onto newer versions
for a while. Its possible that those files were moved or removed since
then. I think I remember hearing that someone redid the config files for
nfs. If that is the case cfg.c and cfg.h can go away. It is very
possible that they were just rolled forward with the patch rebasing.
Additionally if queue.h from /usr/include/sys is what is being used now
we can get rid of the private copy from my patch as well. I didn't have
a reason for keeping a private copy other than the fact the idmapd was
using it and I was going to as well so I moved it into the support
directory. I should have given the patch a bit more of a look over
before I left for the weekend but I was running really short on time
when I sent it out.

Dave


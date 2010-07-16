From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: nfs-utils atomicio.c
Date: Fri, 16 Jul 2010 16:09:12 -0400
Message-ID: <1279310952.8180.0.camel@moss-terrapins.epoch.ncsc.mil>
References: <20100716193508.GA14878@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.65.40]:45054 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755136Ab0GPUSv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jul 2010 16:18:51 -0400
In-Reply-To: <20100716193508.GA14878-8f4Pc2RrbJmHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-07-16 at 15:35 -0400, Jim Rees wrote:
> Someone should move atomicio.c into nfs-utils/support/nfs.  There are
> currently two copies, in idmapd and spnfsd, and I'm about to add a third.
> I'll move it if no one has a better idea or beats me to it.

I agree with this move as I have a label mapping daemon based off of
idmapd which uses it as well (although not merged yet). My patch set
actually moves this file to support/nfs as well.

Dave


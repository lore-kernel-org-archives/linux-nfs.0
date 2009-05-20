From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFS-CIFS locking
Date: Wed, 20 May 2009 12:47:23 -0400
Message-ID: <20090520124723.163172b1@tlielax.poochiereds.net>
References: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAA@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
	<20090520112233.40e0b905@tlielax.poochiereds.net>
	<A7DEA48C84FD0B48AAAE33F328C02014030F3FAF@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
	<20090520122357.43c33fd7@tlielax.poochiereds.net>
	<A7DEA48C84FD0B48AAAE33F328C02014030F3FB1@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>
To: "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44249 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753217AbZETQrd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 May 2009 12:47:33 -0400
In-Reply-To: <A7DEA48C84FD0B48AAAE33F328C02014030F3FB1-WnaG5mLaJUsadWZoJ9kThg@public.gmane.org_nt.nt.pmc-sierra.bc.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 20 May 2009 09:38:21 -0700
"Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org> wrote:

> Hi Jeff,
> 
> Thanks much for your inputs.
> 
> I have tried to get some info from samba list but no luck.
> 
> My proposed system is a fileserver which is supposed to be share point
> for both windows and Linux ( CIFS and NFS). So I can't point one
> particular application. Basically I want to rule out file corruption
> while sharing single file across multiple protocols.
> 

That's a very different situation than what you originally asked. You
asked about cross-protocol locking. That's achievable, but it depends
on using applications that actually do lock the files and some
understanding about what you get when you lock the files in this way.

If you don't have well-behaved apps that lock files to guard against
concurrent access, then you'll have problems even if you're not using
NFS and samba together.

-- 
Jeff Layton <jlayton@redhat.com>

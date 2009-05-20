From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFS-CIFS locking
Date: Wed, 20 May 2009 12:23:57 -0400
Message-ID: <20090520122357.43c33fd7@tlielax.poochiereds.net>
References: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAA@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
	<20090520112233.40e0b905@tlielax.poochiereds.net>
	<A7DEA48C84FD0B48AAAE33F328C02014030F3FAF@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>
To: "Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58354 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753825AbZETQYK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 May 2009 12:24:10 -0400
In-Reply-To: <A7DEA48C84FD0B48AAAE33F328C02014030F3FAF-WnaG5mLaJUsadWZoJ9kThg@public.gmane.org_nt.nt.pmc-sierra.bc.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 20 May 2009 09:12:24 -0700
"Anoop P.A." <Anoop_P.A-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org> wrote:

> Hi Jeff,
> 
> Thanks for your reply. Basically what I want is "the file which is used under CIFS share should not get overwritten from  a nfs share and vice versa." . I might be looking for mandatory file locking in nfs share. 
> 

That may be tricky.

Mandatory locking under unix is rather rare. Most unix apps use
advisory locking. Windows however uses mandatory locking pretty much
exclusively. The semantics of windows locks are quite different -- they
don't necessarily map 1:1, particularly when you get into how
overlapping byte ranges are handled and such.

The best advice I can offer is to understand how your apps use locking
and to do some testing to simulate those use cases. That should help
outline where the differences are.

Again, the samba lists are probably a better forum for this discussion.
The developers that lurk on those lists generally have a good
understanding of the subtleties involved in mapping file locks between
the two platforms.

With more specific questions you may be able to get more helpful
answers as well.

-- 
Jeff Layton <jlayton@redhat.com>

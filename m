From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: RE: should we make --enable-tirpc the default in current nfs-utils?
Date: Mon, 8 Jun 2009 08:36:34 -0700
Message-ID: <7A24DF798E223B4C9864E8F92E8C93EC031D1B02@SACMVEXC1-PRD.hq.netapp.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <20090606160230.247d3ca3@tlielax.poochiereds.net> <861F88E5-EF00-48C8-8D1D-F0830D547DFA@oracle.com> <200906081023.58679.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Jeff Layton" <jlayton@redhat.com>, <linux-nfs@vger.kernel.org>
To: "Mike Frysinger" <vapier@gentoo.org>,
	"Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24152 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754997AbZFHPgy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2009 11:36:54 -0400
In-Reply-To: <200906081023.58679.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 

> -----Original Message-----
> From: Mike Frysinger [mailto:vapier@gentoo.org] 
> Sent: Monday, June 08, 2009 7:24 AM
> To: Chuck Lever
> Cc: Jeff Layton; Muntz, Daniel; linux-nfs@vger.kernel.org
> Subject: Re: should we make --enable-tirpc the default in 
> current nfs-utils?
> 
> On Monday 08 June 2009 10:16:07 Chuck Lever wrote:
> > Frankly, I think dropping back automatically is not a good 
> idea.  The 
> > torrent of messages that configure normally spits out means that 
> > messages about a missing libtirpc are going to be missed in most 
> > cases, and folks will think that because they specified 
> --enable-tirpc 
> > on the configure command line, that's the build they got.
> 
> the automatic fallback is when no tirpc option is specified.  
> if --enable- tirpc is specified, then it should fail (and 
> that is what the proposed patch does).
> -mike
> 

When libnfsidmap, libgssglue, etc. are not present the build fails.  The
builder didn't specify any particular --enable-X flag, and the build
doesn't just do something like fall back and build v3-only.  Why would I
want the build to nondeterministically (to the extent that one might not
be aware of what libraries are installed) generate different code?

  -Dan

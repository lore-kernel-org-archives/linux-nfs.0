Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59594 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753325Ab3LQPY4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Dec 2013 10:24:56 -0500
Date: Tue, 17 Dec 2013 10:24:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: nfs-utils-1.2.9 does not play well with linux 3.10.x
Message-ID: <20131217152454.GB9019@fieldses.org>
References: <OFDD407A92.688D29A1-ONC1257C43.00634FC8-C1257C43.00645775@transmode.se>
 <20131216185419.GB31816@fieldses.org>
 <20131216200301.GD31816@fieldses.org>
 <OF149AE409.624B2B0A-ONC1257C43.006F77D7-C1257C43.006FCED2@transmode.se>
 <20131216202345.GF31816@fieldses.org>
 <OF942071D7.5EC379B1-ONC1257C43.007AB858-C1257C43.007B0CFB@transmode.se>
 <20131217033849.GA3490@fieldses.org>
 <OF378044B8.DD299A9C-ONC1257C44.002378D5-C1257C44.0023C391@transmode.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF378044B8.DD299A9C-ONC1257C44.002378D5-C1257C44.0023C391@transmode.se>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 17, 2013 at 07:30:38AM +0100, Joakim Tjernlund wrote:
> "J. Bruce Fields" <bfields@fieldses.org> wrote on 2013/12/17 04:38:49:
> > 
> > On Mon, Dec 16, 2013 at 11:24:03PM +0100, Joakim Tjernlund wrote:
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote on 2013/12/16 21:23:45:
> > > 
> > > > From: "J. Bruce Fields" <bfields@fieldses.org>
> > > > To: Joakim Tjernlund <joakim.tjernlund@transmode.se>, 
> > > > Cc: linux-nfs@vger.kernel.org, steved@redhat.com
> > > > Date: 2013/12/16 21:23
> > > > Subject: Re: nfs-utils-1.2.9 does not play well with linux 3.10.x
> > > > 
> > > > On Mon, Dec 16, 2013 at 09:21:15PM +0100, Joakim Tjernlund wrote:
> > > > > I tested this on my system(which has the above kernel patch) and I 
> 
> > > noticed
> > > > > a difference:
> > > > 
> > > > Thanks!
> > > > 
> > > > >   rpc.nfsd: Writing version string to kernel: -2 +3 +4 
> > > > > which is different than previous
> > > > >  rpc.nfsd: Writing version string to kernel: +4.1 -4.2 -2 +3 +4
> > > > > 
> > > > > The "+4.1" is missing.
> > > > 
> > > > Yes, that's intentional.  Is it causing you any problem?
> > > 
> > > I don't know yet, but I don't think it would be a problem for me.
> > > However, are you not changing the defaults here? In that
> > > case someone else relying on 4.1 might have a problem I guess.
> > 
> > That's just restoring the behavior we had before
> > 12a590f8d556c00a9502eeebaa763d906222d521, and will still result in 4.1
> > being turned on if the kernel is recent enough.
> 
> What is an recent enough kernel? Does not 3.10.24 patched with the patch I 
> mentioned
> earlier? I thought it would make 3.10 look like a 3.11 which have 4.2 
> supported.
> If I am mistaken we good I guess.

Sorry, I don't understand exactly what your concern is.

--b.

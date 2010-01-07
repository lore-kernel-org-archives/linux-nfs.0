From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS Server Not Responding after hw change (svc: transport
	busy, not enqueued)
Date: Thu, 7 Jan 2010 09:41:46 -0500
Message-ID: <20100107144146.GB24418@fieldses.org>
References: <alpine.DEB.1.10.1001052221550.22025@asgard.binrock.net> <20100106204017.GN6612@fieldses.org> <alpine.DEB.1.10.1001061958560.22025@asgard.binrock.net> <20100107143557.GA24418@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
To: Scott Sturdivant <scott@binrock.net>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20100107143557.GA24418@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oops--trying again with address fixed.

On Thu, Jan 07, 2010 at 09:35:58AM -0500, J. Bruce Fields wrote:
> On Wed, Jan 06, 2010 at 08:02:14PM -0500, Scott Sturdivant wrote:
> > On Wed, 6 Jan 2010, J. Bruce Fields wrote:
> >> On a quick skim I don't see an obvious reason; one approach (if you're
> >> *positive* there weren't also any software changes) might be just to try
> >> swapping the hardware back (starting with the LAN?) and see if you can
> >> reliably turn the problem on/off with just one hardware change.
> >>
> >> --b.
> >
> > Thank you for the good suggestion! I have done this and have verified 
> > that indeed the onboard LAN is the root of the problem.
> 
> Woo-hoo!
> 
> > However, as the  
> > onboard LAN is able to handle Samba / scp but fails with NFS, I'm curious 
> > if this is an actual hardware problem or a driver issue?  Does anyone 
> > know where the appropriate place for this problem would be?  Is there an 
> > atl1c list?
> 
> Adding netdev@vger.kernel.org....  Could you repeat any details about
> the exact models of the network interfaces?
> 
> --b.

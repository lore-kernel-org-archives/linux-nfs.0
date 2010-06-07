Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58417 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751583Ab0FGStF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jun 2010 14:49:05 -0400
Date: Mon, 7 Jun 2010 14:49:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: sfaibish <sfaibish@emc.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Performance results with exofs
Message-ID: <20100607184902.GI25257@fieldses.org>
References: <op.vdxrrgf1unckof@usensfaibisl2e.eng.emc.com> <4C0D195B.8030401@panasas.com> <4C0D1AAB.4070304@panasas.com> <op.vdxxhfqsunckof@usensfaibisl2e.eng.emc.com> <20100607182948.GF25257@fieldses.org> <4C0D3D59.4000305@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C0D3D59.4000305@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jun 07, 2010 at 09:41:29PM +0300, Boaz Harrosh wrote:
> On 06/07/2010 09:29 PM, J. Bruce Fields wrote:
> >>> On 06/07/2010 07:07 PM, Boaz Harrosh wrote:
> >>>> I did not yet publish the Document. It's stuck behind my dis-talent for
> >>>> writing and the pnfs bugs de jur.
> > 
> > Untalented writing we can fix, as long as the details are there!
> > 
> >>>>
> >>>> Basically all machines:
> >>>> - connected by a 1 GBit link.
> >>>> - All clients doing a dd write of 8GB file from /dev/zero
> >>>> - 3of8 is the special raid-groups arrangement of exofs && objlayout
> >>>>   where out of 8 devices each file is striped over 3 devices in a
> >>>>   round robin fashion. (*With a small dirty trick)
> > 
> > Random stupid questions:
> > 
> > 	- why do you think the 3of8 arrangement is scaling better than
> > 	  the 8of8?
> 
> It's a know problem with a network storage cluster. What happens is
> that with 8of8 all the clients exercise all of the nodes at the same
> time so they are clashing on the network.

OK, so if two clients are both trying to send a stripe of data to the
same OSD data at the same time, absent a switch that could somehow
afford to queue up a full stripe-unit's worth of data, packets get lost?

(Also, out of curiosity: do you know of any papers or documentation that
describe that problem in more detail?)

--b.

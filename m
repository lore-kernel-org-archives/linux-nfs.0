From: "Paul B. Henson" <henson@acm.org>
Subject: Re: NFS over TCP idle timeout
Date: Mon, 28 Jan 2008 19:33:53 -0800 (PST)
Message-ID: <Pine.GSO.4.55.0801281932350.15248@loogie.intranet.csupomona.edu>
References: <Pine.GSO.4.55.0801251516550.21@loogie.intranet.csupomona.edu>
 <20080129003223.GC16785@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sparky.unx.csupomona.edu ([134.71.247.19]:45434 "EHLO
	sparky.unx.csupomona.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbYA2Ddy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 22:33:54 -0500
In-Reply-To: <20080129003223.GC16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Jan 2008, J. Bruce Fields wrote:

> On Fri, Jan 25, 2008 at 04:41:00PM -0800, Paul B. Henson wrote:
> >
> > Does the Linux server implementation of NFS over TCP implement an idle
> > timeout that automatically disconnects clients after some amount of
> > inactivity?
>
> That sounds like a server bug to me.  Have you checked whether it still
> behaves that way on more recent kernels?

No. I'll probably be upgrading the server to 2.6.23 within the next few
weeks, but given the dearth of information I found in my searches, was
curious whether or not it was supposed to in the first place.

Thanks...


-- 
Paul B. Henson  |  (909) 979-6361  |  http://www.csupomona.edu/~henson/
Operating Systems and Network Analyst  |  henson@csupomona.edu
California State Polytechnic University  |  Pomona CA 91768

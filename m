Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34621 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754654Ab2GXR0S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jul 2012 13:26:18 -0400
Date: Tue, 24 Jul 2012 13:26:16 -0400
To: Maiko Langelaar <maiko@physics.umanitoba.ca>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 2 NFS server for the same mount point ?
Message-ID: <20120724172616.GJ8570@fieldses.org>
References: <500EBB69.5000205@physics.umanitoba.ca>
 <20120724155304.GA9721@us.ibm.com>
 <500ED5E4.1050902@physics.umanitoba.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <500ED5E4.1050902@physics.umanitoba.ca>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 24, 2012 at 12:05:40PM -0500, Maiko Langelaar wrote:
> > Yes, you can.
> 
> Just to be on the safe side, I should be a bit more clear on this.
> 
> Both of the NFS servers will be running simultaneously, both
> exporting the same mount points for the same subnet.

If you're asking whether it's safe for A and B to both be exporting
something named (for example) "/home"--sure, that's fine.

(If you want the exports from both servers to actually see the same
data, with changes made through A reflected on B and vice versa--at that
point you need a cluster filesystem backing the exports and things
become more complicated.  But I think that's not what you're asking
for.)

--b.

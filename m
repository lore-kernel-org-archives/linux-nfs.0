From: Jim Rees <rees@umich.edu>
Subject: Re: nfs-utils atomicio.c
Date: Fri, 16 Jul 2010 16:53:55 -0400
Message-ID: <20100716205355.GA7962@merit.edu>
References: <20100716193508.GA14878@merit.edu>
 <1279310952.8180.0.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:47451 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758829Ab0GPUx4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jul 2010 16:53:56 -0400
In-Reply-To: <1279310952.8180.0.camel-88+Bj4OksMGWPftkNcioYDMZycKHmlmlfvIqQ387n9k@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David P. Quigley wrote:

  I agree with this move as I have a label mapping daemon based off of
  idmapd which uses it as well (although not merged yet). My patch set
  actually moves this file to support/nfs as well.

I don't suppose you'd like to isolate just the move and submit that?

strlcat and strlcpy should probably go too.

From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 00/38] RPC Transport Switch
Date: Thu, 29 Nov 2007 20:01:00 -0600
Message-ID: <1196388060.16169.51.camel@trinity.ogc.int>
References: <20071129225510.15275.82660.stgit@dell3.ogc.int>
	 <20071130002748.GA10394@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:53663 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933811AbXK3B46 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 20:56:58 -0500
In-Reply-To: <20071130002748.GA10394@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I just resent the patchset to myself and forwarded #23. We'll see if it
makes it. I wonder if my description had a keyword or something that
caused vger to kill it. 


Tom

On Thu, 2007-11-29 at 19:27 -0500, J. Bruce Fields wrote:
> On Thu, Nov 29, 2007 at 04:55:10PM -0600, Tom Tucker wrote:
> > This patchset implements the RDMA Transport Driver for the 
> > SVC Transport Switch. This patchset has been tested with iozone
> > and Connectathon over NFS v3.
> > 
> > This patchset is against 2.6.24-rc3.
> > 
> > This patchset along with the SVC transport switch and client
> > side marshalling fix are also available in this git tree:
> > 
> > git://linux-nfs.org/~tomtucker/nfs-rdma-dev-2.6.git
> > 
> > -- 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Somehow patch 23 never made it through....
> 
> --b.


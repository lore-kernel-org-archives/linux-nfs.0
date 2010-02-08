From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] nfs-utils: nfsstat fix for 2.6.33
Date: Mon, 08 Feb 2010 10:38:18 -0500
Message-ID: <4B702FEA.8070905@RedHat.com>
References: <4B3B6981.8030807@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752890Ab0BHPiW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Feb 2010 10:38:22 -0500
In-Reply-To: <4B3B6981.8030807@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/30/2009 09:53 AM, Benny Halevy wrote:
> Steve,
> 
> The first patch in this series adds reclaim_complete to the client stats.
> The second one cleans up the array size definitions for nfs ops.
> 
> [PATCH 1/2] nfsstat: update cltproc4info for 2.6.33
> [PATCH 2/2] nfsstat: use symbolic constants for operation array sizes
> 
Committed...

steved.

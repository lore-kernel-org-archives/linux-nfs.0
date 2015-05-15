Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46293 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754865AbbEOTUj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2015 15:20:39 -0400
Date: Fri, 15 May 2015 15:20:37 -0400
To: Benjamin ESTRABAUD <be@mpstor.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bc@mpstor.com" <bc@mpstor.com>, Christoph Hellwig <hch@infradead.org>
Subject: Re: Issue running buffered writes to a pNFS (NFS 4.1 backed by SAN)
 filesystem.
Message-ID: <20150515192037.GB29627@fieldses.org>
References: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 15, 2015 at 10:44:13AM -0700, Benjamin ESTRABAUD wrote:
> I've been using pNFS for a while since recently, and I am very pleased
> with its overall stability and performance.
> 
> A pNFS MDS server was setup with SAN storage in the backend (a RAID0
> built ontop of multiple LUNs). Clients were given access to the same
> RAID0 using the same LUNs on the same SAN.
> 
> However, I've been noticing a small issue with it that prevents me
> from using pNFS to its full potential: If I run non-direct IOs (for
> instance "dd" without the "oflag=direct" option), IOs run excessively
> slowly (3-4MB/sec) and the dd process hangs until forcefully
> terminated.

And that's reproduceable every time?

Can you get network captures and figure out (for example), whether the
slow writes are going over iSCSI or NFS, and if they're returning errors
in either case?

> The same behaviour can be observed laying out an IO file
> with FIO for instance, or using some applications which do not use the
> ODIRECT flag. When using direct IO I can observe lots of iSCSI
> traffic, at extremely good performance (same performance as the SAN
> gets on "raw" block devices).
> 
> All the systems are running CentOS 7.0 with a custom kernel 4.1-rc2
> (pNFS enabled) apart from the storage nodes which are running a custom
> minimal Linux distro with Kernel 3.18.
> 
> The SAN is all 40G Mellanox Ethernet, and we are not using the OFED
> driver anywhere (Everything is only "standard" upstream Linux).

What's the non-SAN network (that the NFS traffic goes over)?

--b.

> 
> Would anybody have any ideas where this issue could be coming from?
> 
> Regards, Ben - MPSTOR.-- To unsubscribe from this list: send the line
> "unsubscribe linux-nfs" in the body of a message to
> majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

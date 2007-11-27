From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [NFS] Current limit on number of NFS mounts, in 2.6  kernels?
Date: Tue, 27 Nov 2007 10:04:47 -0500
Message-ID: <EXNANE01g9MvuHdPtnh00000a32@exnane01.hq.netapp.com>
References: <20071127094330.465c4554@impertigo.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Erik Forsberg <forsberg+nfs-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ix1zl-0003Rt-3o
	for nfs@lists.sourceforge.net; Tue, 27 Nov 2007 07:05:05 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ix1zp-0001ZJ-S6
	for nfs@lists.sourceforge.net; Tue, 27 Nov 2007 07:05:11 -0800
In-Reply-To: <20071127094330.465c4554-BuKZgzNFOO9LeQEbcWVKXqOdP2EOjF1D@public.gmane.org>
References: <20071127094330.465c4554-BuKZgzNFOO9LeQEbcWVKXqOdP2EOjF1D@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

At 03:43 AM 11/27/2007, Erik Forsberg wrote:
>I assume there's no way to tell the kernel NFS client that it's OK to
>use port numbers higher than 1024 for outbound connections?

Sure, you can change the min_resvport/max_resvport sysctl variables
to any range you wish. However, you may have to configure your NFS
server's exports to accept requests from these ports - many servers by
default insist on client ports < 1024, for both mount and nfs requests.
For Linux, this means adding "insecure" to the appropriate /etc/exports
lines.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


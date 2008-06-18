From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/4] NFS mounting with raw IPv6 server hostnames
Date: Tue, 17 Jun 2008 20:07:24 -0400
Message-ID: <1213747644.7288.98.camel@localhost>
References: <20080617181622.3215.61295.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12278 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754934AbYFRAIA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jun 2008 20:08:00 -0400
In-Reply-To: <20080617181622.3215.61295.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-06-17 at 14:17 -0400, Chuck Lever wrote:
> Hi Trond-
> 
> Something meatier today.
> 
> These four patches introduce the ability to mount NFS servers using a raw
> IPv6 address.  This support requires the ability to handle colons in the
> passed-in server hostname, and the ability to handle an IPv6 interface
> identifier in the passed-in server hostname.
> 
> IPv6 addresses contain colons.  A colon is also used to separate the server
> name from the export path.  By enclosing an IPv6 address inside square
> brackets we effectively escape the colons in the IPv6 address and allow them
> to pass unrecognized through the device name parser.
> 
> As an added bonus, I also include the patch that changes
> nfs_parse_server_address() to take a name length.  This allows the passed-in
> address string to have no '\0'-termination, which will help us support IPv6
> for NFSv4 referrals.
> 
> Please consider these for 2.6.27.
> 
> ---
> 
> Chuck Lever (4):
>       NFS: handle interface identifiers in incoming IPv6 addresses
>       NFS: Add string length argument to nfs_parse_server_address
>       NFS: Support raw IPv6 address hostnames during NFS mount operation
>       NFS: Use common device name parsing logic for NFSv4 and NFSv2/v3
> 
> 
>  fs/nfs/super.c |  336 ++++++++++++++++++++++++++++++++++++++++++++------------
>  1 files changed, 261 insertions(+), 75 deletions(-)
> 

All 4 patches applied to the 'devel' branch.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

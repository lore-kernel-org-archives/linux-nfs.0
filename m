From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: RPC service registration timeout
Date: Fri, 04 Apr 2008 16:45:33 -0400
Message-ID: <1207341933.13540.30.camel@heimdal.trondhjem.org>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
	 <EXNANE01XvpFVjCRGry00000233@exnane01.hq.netapp.com>
	 <1207330103.11655.3.camel@heimdal.trondhjem.org>
	 <0FE09339-FB7A-4E9E-B56F-61648EFD121A@oracle.com>
	 <EXNANE017a0xtAEHLB800000238@exnane01.hq.netapp.com>
	 <1207337153.13540.15.camel@heimdal.trondhjem.org>
	 <EXNANE01TrBHxvZ9aZ10000023b@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50025 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959AbYDDUpg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2008 16:45:36 -0400
In-Reply-To: <EXNANE01TrBHxvZ9aZ10000023b-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-04-04 at 15:33 -0400, Talpey, Thomas wrote:
> If it fails with a server-provided error such as this, the caller can and
> should decide what to do - if that caller is NFS, it can apply soft/hard
> to the retry decision. But Chuck's example, for instance, is NFSD.

Note that ECONNREFUSED doesn't necessarily mean that the service is
down; it may also indicate a SYN backlog.

In most cases, you therefore definitely want to try to handle this type
of error in the RPC layer, not the caller. If you fault back to the
caller, then you lose RPC level information, and in particular, you will
lose the XID. If you were trying to reconnect in order to replay the RPC
request, then that can be a real problem...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

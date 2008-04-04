From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: RPC service registration timeout
Date: Fri, 04 Apr 2008 15:33:55 -0400
Message-ID: <EXNANE01TrBHxvZ9aZ10000023b@exnane01.hq.netapp.com>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
 <EXNANE01XvpFVjCRGry00000233@exnane01.hq.netapp.com>
 <1207330103.11655.3.camel@heimdal.trondhjem.org>
 <0FE09339-FB7A-4E9E-B56F-61648EFD121A@oracle.com>
 <EXNANE017a0xtAEHLB800000238@exnane01.hq.netapp.com>
 <1207337153.13540.15.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37528 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752389AbYDDTeR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2008 15:34:17 -0400
In-Reply-To: <1207337153.13540.15.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
 <EXNANE01XvpFVjCRGry00000233-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
 <1207330103.11655.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
 <0FE09339-FB7A-4E9E-B56F-61648EFD121A@oracle.com>
 <EXNANE017a0xtAEHLB800000238-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
 <1207337153.13540.15.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 03:25 PM 4/4/2008, Trond Myklebust wrote:
>> Bottom line, I think it might actually be a useful default. Why does
>> the client currently retry ECONNREFUSED for port resolution?
>
>The client currently doesn't retry in the case of a connection failing
>for a soft RPC request. For hard RPC requests then it _must_ retry the
>connection, but it does so using an exponential backoff rule.

Yes, for the NFS client this is true, and necessary. I'm wondering why
the rpcbind/portmap client retries on ECONNREFUSED. Seems overly
heroic, to me - the destination responded, and said "go away".

If it fails with a server-provided error such as this, the caller can and
should decide what to do - if that caller is NFS, it can apply soft/hard
to the retry decision. But Chuck's example, for instance, is NFSD.

Tom.


From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: RPC service registration timeout
Date: Fri, 04 Apr 2008 15:39:51 -0400
Message-ID: <EXNANE013ednHM3SOlb0000023c@exnane01.hq.netapp.com>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
 <EXNANE01XvpFVjCRGry00000233@exnane01.hq.netapp.com>
 <1207330103.11655.3.camel@heimdal.trondhjem.org>
 <0FE09339-FB7A-4E9E-B56F-61648EFD121A@oracle.com>
 <EXNANE017a0xtAEHLB800000238@exnane01.hq.netapp.com>
 <CA26795C-23B5-4E9B-806B-49CCF3AB1BC1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2850 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757088AbYDDTkA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2008 15:40:00 -0400
In-Reply-To: <CA26795C-23B5-4E9B-806B-49CCF3AB1BC1@oracle.com>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
 <EXNANE01XvpFVjCRGry00000233-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
 <1207330103.11655.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
 <0FE09339-FB7A-4E9E-B56F-61648EFD121A@oracle.com>
 <EXNANE017a0xtAEHLB800000238-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
 <CA26795C-23B5-4E9B-806B-49CCF3AB1BC1@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 03:28 PM 4/4/2008, Chuck Lever wrote:
>It could be waiting for the remote to come up.  In which case, a few  
>retries after ECONNREFUSED is useful, even preferred.

If the remote rpcbind is coming up, then there's no need to deregister.
I would certainly not advocate bailing the registration of course!

>I'm going to try prototyping a new RPC_CLNT_ flag.

Sure what the heck. If the RPC client needs to serve all upper layers
then a new behavior makes sense. I fondly recall Rick Macklem's
"spongy" mounts, in-between hard and soft, that retried nonidempotent
ops harder than others.

Since you're exploring something on the other side of soft, may I
suggest "squishy"? :-)

Tom.


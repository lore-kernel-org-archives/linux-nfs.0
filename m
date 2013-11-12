Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:17024 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab3KLRdf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 12:33:35 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: Thread overran stack, or stack corrupted BUG on mount
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1384277451.4779.24.camel@leira.trondhjem.org>
Date: Tue, 12 Nov 2013 12:33:28 -0500
Cc: Jeff Layton <jlayton@redhat.com>, Weston Andros Adamson <dros@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <6EF1AA2E-18B4-42F9-8ADD-8BBF86A9FD4A@oracle.com>
References: <2C73011F-0939-434C-9E4D-13A1EB1403D7@netapp.com> <20131112105539.4f804fc6@tlielax.poochiereds.net> <20131112112021.1a0a60ca@tlielax.poochiereds.net> <E4B641E5-34C5-4779-8FAB-DCB6C74D1546@oracle.com> <1384277451.4779.24.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2013, at 12:30 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-11-12 at 11:23 -0500, Chuck Lever wrote:
>> On Nov 12, 2013, at 11:20 AM, Jeff Layton <jlayton@redhat.com> wrote:
>>> Ok, I think I see the problem. The looping comes from this block in
>>> nfs4_discover_server_trunking:
>>> 
>>> -----------------[snip]-----------------
>>>       case -NFS4ERR_CLID_INUSE:
>>>       case -NFS4ERR_WRONGSEC:
>>>               clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
>>>               if (IS_ERR(clnt)) {
>>>                       status = PTR_ERR(clnt);
>>>                       break;
>>>               }
>>>               /* Note: this is safe because we haven't yet marked the
>>>                * client as ready, so we are the only user of
>>>                * clp->cl_rpcclient
>>>                */
>>>               clnt = xchg(&clp->cl_rpcclient, clnt);
>>>               rpc_shutdown_client(clnt);
>>>               clnt = clp->cl_rpcclient;
>>>               goto again;
>>> -----------------[snip]-----------------
>>> 
>>> ...so in the case of the reproducer, we get back -NFS4ERR_CLID_IN_USE,
>>> at that point we call rpc_clone_client_set_auth(), which creates a new
>>> rpc_clnt, but it's created as a child of the original.
>>> 
>>> When rpc_shutdown_client is called, the original clnt is not destroyed
>>> because the child still holds a reference to it. So, we go and try the
>>> call again and it fails with the same error over and over again, and we
>>> end up with a long chain of rpc_clnt's.
>>> 
>>> How that ends up smashing the stack, I'm not sure though. I'm also not
>>> sure of the remedy. It seems like we might ought to have some upper
>>> bound on the number of SETCLIENTID attempts?
>> 
>> CLID_INUSE is supposed to be a permanent error now.  I think one retry, if any, is all that is appropriate.
> 
> Right. If we hit CLID_INUSE in nfs4_discover_server_trunking then
> 
> a) we know this is a server that we've already mounted
> b) we know that either nfs4_init_client set us up with RPC_AUTH_UNIX to
> begin with, or that rpc.gssd was started only after we'd already sent a
> SETCLIENTID/EXCHANGE_ID using RPC_AUTH_UNIX to this server
> 
> so the correct thing to do is to retry once if we know that we're not
> already using AUTH_SYS, and then to EPERM.

Agree.  Sorry I didn't spell that out.


> Now that said, I agree that this should not be able to trigger a stack
> overflow. Is this NFSv4 or NFSv4.1/NFSv4.2? Have either of you (Jeff and
> Dros) tried enabling DEBUG_STACKOVERFLOW?
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:33111 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753327Ab3KLRbO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 12:31:14 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Jeff Layton <jlayton@redhat.com>, Weston Andros Adamson <dros@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: Thread overran stack, or stack corrupted BUG on mount
Date: Tue, 12 Nov 2013 17:30:53 +0000
Message-ID: <1384277451.4779.24.camel@leira.trondhjem.org>
References: <2C73011F-0939-434C-9E4D-13A1EB1403D7@netapp.com>
	 <20131112105539.4f804fc6@tlielax.poochiereds.net>
	 <20131112112021.1a0a60ca@tlielax.poochiereds.net>
	 <E4B641E5-34C5-4779-8FAB-DCB6C74D1546@oracle.com>
In-Reply-To: <E4B641E5-34C5-4779-8FAB-DCB6C74D1546@oracle.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-11-12 at 11:23 -0500, Chuck Lever wrote:
+AD4- On Nov 12, 2013, at 11:20 AM, Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4- wrote:
+AD4- +AD4- Ok, I think I see the problem. The looping comes from this block in
+AD4- +AD4- nfs4+AF8-discover+AF8-server+AF8-trunking:
+AD4- +AD4- 
+AD4- +AD4- -----------------+AFs-snip+AF0------------------
+AD4- +AD4-        case -NFS4ERR+AF8-CLID+AF8-INUSE:
+AD4- +AD4-        case -NFS4ERR+AF8-WRONGSEC:
+AD4- +AD4-                clnt +AD0- rpc+AF8-clone+AF8-client+AF8-set+AF8-auth(clnt, RPC+AF8-AUTH+AF8-UNIX)+ADs-
+AD4- +AD4-                if (IS+AF8-ERR(clnt)) +AHs-
+AD4- +AD4-                        status +AD0- PTR+AF8-ERR(clnt)+ADs-
+AD4- +AD4-                        break+ADs-
+AD4- +AD4-                +AH0-
+AD4- +AD4-                /+ACo- Note: this is safe because we haven't yet marked the
+AD4- +AD4-                 +ACo- client as ready, so we are the only user of
+AD4- +AD4-                 +ACo- clp-+AD4-cl+AF8-rpcclient
+AD4- +AD4-                 +ACo-/
+AD4- +AD4-                clnt +AD0- xchg(+ACY-clp-+AD4-cl+AF8-rpcclient, clnt)+ADs-
+AD4- +AD4-                rpc+AF8-shutdown+AF8-client(clnt)+ADs-
+AD4- +AD4-                clnt +AD0- clp-+AD4-cl+AF8-rpcclient+ADs-
+AD4- +AD4-                goto again+ADs-
+AD4- +AD4- -----------------+AFs-snip+AF0------------------
+AD4- +AD4- 
+AD4- +AD4- ...so in the case of the reproducer, we get back -NFS4ERR+AF8-CLID+AF8-IN+AF8-USE,
+AD4- +AD4- at that point we call rpc+AF8-clone+AF8-client+AF8-set+AF8-auth(), which creates a new
+AD4- +AD4- rpc+AF8-clnt, but it's created as a child of the original.
+AD4- +AD4- 
+AD4- +AD4- When rpc+AF8-shutdown+AF8-client is called, the original clnt is not destroyed
+AD4- +AD4- because the child still holds a reference to it. So, we go and try the
+AD4- +AD4- call again and it fails with the same error over and over again, and we
+AD4- +AD4- end up with a long chain of rpc+AF8-clnt's.
+AD4- +AD4- 
+AD4- +AD4- How that ends up smashing the stack, I'm not sure though. I'm also not
+AD4- +AD4- sure of the remedy. It seems like we might ought to have some upper
+AD4- +AD4- bound on the number of SETCLIENTID attempts?
+AD4- 
+AD4- CLID+AF8-INUSE is supposed to be a permanent error now.  I think one retry, if any, is all that is appropriate.

Right. If we hit CLID+AF8-INUSE in nfs4+AF8-discover+AF8-server+AF8-trunking then

a) we know this is a server that we've already mounted
b) we know that either nfs4+AF8-init+AF8-client set us up with RPC+AF8-AUTH+AF8-UNIX to
begin with, or that rpc.gssd was started only after we'd already sent a
SETCLIENTID/EXCHANGE+AF8-ID using RPC+AF8-AUTH+AF8-UNIX to this server

so the correct thing to do is to retry once if we know that we're not
already using AUTH+AF8-SYS, and then to EPERM.


Now that said, I agree that this should not be able to trigger a stack
overflow. Is this NFSv4 or NFSv4.1/NFSv4.2? Have either of you (Jeff and
Dros) tried enabling DEBUG+AF8-STACKOVERFLOW?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 03 Nov 2008 12:50:31 -0500
Message-ID: <1225734631.2247.76.camel@brian-laptop>
References: <1225724721.2247.29.camel@brian-laptop>
	 <1225731544.6958.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:2581 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbYKCRuf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 12:50:35 -0500
Received: from linux.interlinx.bc.ca (d193-213-184.home3.cgocable.net [67.193.213.184])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 767A42805
	for <linux-nfs@vger.kernel.org>; Mon,  3 Nov 2008 12:50:33 -0500 (EST)
Received: from [10.75.22.172] (brian-laptop.ilinx [10.75.22.172])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 7F767800A
	for <linux-nfs@vger.kernel.org>; Mon,  3 Nov 2008 12:50:31 -0500 (EST)
In-Reply-To: <1225731544.6958.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-03 at 11:59 -0500, Trond Myklebust wrote:
> 
> BTW: NFSv4 + soft == BAD BAD BAD!

Ahh.  OK.

> You will see weird behaviour, as the
> client and the server will have divergent opinions on what happened
> if/when an RPC call fails.

I have removed the soft option from the auto map and killed the
in-progress mount.nfs4.  Seems the new one is not using soft any more:

root     22731 22730  0 12:06 ?        00:00:00 /sbin/mount.nfs4 linux:/home/share /autohome/share -s -o rw,sec=krb5i,intr,rsize=8192,wsize=8192

> Otherwise, have you checked on the state of your rpc.gssd? It looked as
> if several of those traces were waiting around RPCSEC_GSS upcalls...
I thought it was working.  I killed it and restarted it with -vvv -rrr
and this is what it said when automount re-issued the above mount:

Nov  3 12:02:15 pc rpc.gssd[21773]: rpcsec_gss: debug level is 3
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_create_default()
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_create()
Nov  3 12:06:00 pc rpc.gssd[21774]: authgss_create: name is 0x8ab8d88
Nov  3 12:06:00 pc rpc.gssd[21774]: authgss_create: gd->name is 0x8ab8ed0
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_refresh()
Nov  3 12:06:00 pc rpc.gssd[21774]: struct rpc_gss_sec: 
Nov  3 12:06:00 pc rpc.gssd[21774]:      mechanism_OID: { 1 2 134 72 134 247 18 1 2 2 } 
Nov  3 12:06:00 pc rpc.gssd[21774]:      qop: 0 
Nov  3 12:06:00 pc rpc.gssd[21774]:      service: 1 
Nov  3 12:06:00 pc rpc.gssd[21774]:      cred: 0x8abb830 
Nov  3 12:06:00 pc rpc.gssd[21774]:      req_flags: 00000002 
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_marshal()
Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_buf: encode success ((nil):0)
Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_cred: encode success (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_wrap()
Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_buf: encode success (0x8abbeb8:483)
Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_init_args: encode success (token 0x8abbeb8:483)
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_validate()
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_unwrap()
Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_buf: decode success (0x8abbe98:4)
Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_buf: decode success (0x8abc110:114)
Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_init_res decode success (ctx 0x8abbe98:4, maj 0, min 0, win 128, token 0x8abc110:114)
Nov  3 12:06:00 pc rpc.gssd[21774]: authgss_create_default: freeing name 0x8ab8d88
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_get_private_data()
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_free_private_data()
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_destroy()
Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_destroy_context()
Nov  3 12:06:00 pc rpc.gssd[21774]: authgss_destroy: freeing name 0x8ab8ed0

The kdc logged:

Nov  3 12:06:00 linux krb5kdc[5006]: AS_REQ (1 etypes {1}) 10.75.22.1: ISSUE: authtime 1225731960, etypes {rep=1 tkt=16 ses=1}, nfs/pc.interlinx.bc.ca@ILINX for krbtgt/ILINX@ILINX
Nov  3 12:06:00 linux krb5kdc[5006]: TGS_REQ (1 etypes {1}) 10.75.22.1: ISSUE: authtime 1225731960, etypes {rep=1 tkt=1 ses=1}, nfs/pc.interlinx.bc.ca@ILINX for nfs/linux.interlinx.bc.ca@ILINX

in correlation to the new mount request, but the mount.nfs4 didn't
complete.

b.



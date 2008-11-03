From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 3 Nov 2008 14:58:57 -0500
Message-ID: <4d569c330811031158r26963e0w5bcf8331e0fb14b7@mail.gmail.com>
References: <1225724721.2247.29.camel@brian-laptop>
	 <1225731544.6958.6.camel@heimdal.trondhjem.org>
	 <1225734631.2247.76.camel@brian-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:64209 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbYKCT66 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 14:58:58 -0500
Received: by wf-out-1314.google.com with SMTP id 27so2715414wfd.4
        for <linux-nfs@vger.kernel.org>; Mon, 03 Nov 2008 11:58:57 -0800 (PST)
In-Reply-To: <1225734631.2247.76.camel@brian-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 3, 2008 at 12:50 PM, Brian J. Murrell <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org> wrote:
> On Mon, 2008-11-03 at 11:59 -0500, Trond Myklebust wrote:
>
>> Otherwise, have you checked on the state of your rpc.gssd? It looked as
>> if several of those traces were waiting around RPCSEC_GSS upcalls...
>
> I thought it was working.  I killed it and restarted it with -vvv -rrr
> and this is what it said when automount re-issued the above mount:
>
> Nov  3 12:02:15 pc rpc.gssd[21773]: rpcsec_gss: debug level is 3
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_create_default()
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_create()
> Nov  3 12:06:00 pc rpc.gssd[21774]: authgss_create: name is 0x8ab8d88
> Nov  3 12:06:00 pc rpc.gssd[21774]: authgss_create: gd->name is 0x8ab8ed0
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_refresh()
> Nov  3 12:06:00 pc rpc.gssd[21774]: struct rpc_gss_sec:
> Nov  3 12:06:00 pc rpc.gssd[21774]:      mechanism_OID: { 1 2 134 72 134 247 18 1 2 2 }
> Nov  3 12:06:00 pc rpc.gssd[21774]:      qop: 0
> Nov  3 12:06:00 pc rpc.gssd[21774]:      service: 1
> Nov  3 12:06:00 pc rpc.gssd[21774]:      cred: 0x8abb830
> Nov  3 12:06:00 pc rpc.gssd[21774]:      req_flags: 00000002
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_marshal()
> Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_buf: encode success ((nil):0)
> Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_cred: encode success (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_wrap()
> Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_buf: encode success (0x8abbeb8:483)
> Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_init_args: encode success (token 0x8abbeb8:483)
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_validate()
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_unwrap()
> Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_buf: decode success (0x8abbe98:4)
> Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_buf: decode success (0x8abc110:114)
> Nov  3 12:06:00 pc rpc.gssd[21774]: xdr_rpc_gss_init_res decode success (ctx 0x8abbe98:4, maj 0, min 0, win 128, token 0x8abc110:114)
> Nov  3 12:06:00 pc rpc.gssd[21774]: authgss_create_default: freeing name 0x8ab8d88
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_get_private_data()
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_free_private_data()
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_destroy()
> Nov  3 12:06:00 pc rpc.gssd[21774]: in authgss_destroy_context()
> Nov  3 12:06:00 pc rpc.gssd[21774]: authgss_destroy: freeing name 0x8ab8ed0

These are all from librpcsecgss (from the -rrr).  I don't see an error here.

You should have gotten output from gssd itself as well.  You might
also look for any errors on the server from rpc.svcgssd.

> The kdc logged:
>
> Nov  3 12:06:00 linux krb5kdc[5006]: AS_REQ (1 etypes {1}) 10.75.22.1: ISSUE: authtime 1225731960, etypes {rep=1 tkt=16 ses=1}, nfs/pc.interlinx.bc.ca@ILINX for krbtgt/ILINX@ILINX
> Nov  3 12:06:00 linux krb5kdc[5006]: TGS_REQ (1 etypes {1}) 10.75.22.1: ISSUE: authtime 1225731960, etypes {rep=1 tkt=1 ses=1}, nfs/pc.interlinx.bc.ca@ILINX for nfs/linux.interlinx.bc.ca@ILINX

This looks fine.  (Assuming linux.interlinx.bc.ca is the NFS server
and pc.interlinx.bc.ca is the client.)


> in correlation to the new mount request, but the mount.nfs4 didn't
> complete.
>

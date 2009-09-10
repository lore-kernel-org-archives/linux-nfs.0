From: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Subject: Re: [pnfs] [PATCH v2 02/12] nfsd41: sunrpc: Added rpc server-side
	backchannel handling
Date: Thu, 10 Sep 2009 06:19:35 -0700
Message-ID: <5e24e8930909100619t23be1ffn7a059fec00ad165e@mail.gmail.com>
References: <4AA8C597.8080809@panasas.com>
	 <1252574717-30074-1-git-send-email-bhalevy@panasas.com>
	 <1252583366.8722.121.camel@heimdal.trondhjem.org>
	 <4AA8F229.2060404@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexandros Batsakis <batsakis@netapp.com>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f172.google.com ([209.85.221.172]:52674 "EHLO
	mail-qy0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbZIJNTc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 09:19:32 -0400
Received: by qyk2 with SMTP id 2so89269qyk.21
        for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2009 06:19:36 -0700 (PDT)
In-Reply-To: <4AA8F229.2060404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

you are right. It was changed to be similar to the pre-existing code,
but there is no need. The timeout value should to be set explicitly to
0 as Benny suggested.

-alexandros

On Thu, Sep 10, 2009 at 5:33 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On Sep. 10, 2009, 14:49 +0300, Trond Myklebust <Trond.Myklebust@netap=
p.com> wrote:
>> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>> > > index f412a85..f577e5a 100644
>> > > --- a/net/sunrpc/xprt.c
>> > > +++ b/net/sunrpc/xprt.c
>> > > @@ -832,6 +832,11 @@ static void xprt_timer(struct rpc_task *tas=
k)
>> > > =A0 spin_unlock_bh(&xprt->transport_lock);
>> > > =A0}
>> > >
>> > > +static inline int xprt_has_timer(struct rpc_xprt *xprt)
>> > > +{
>> > > + return xprt->idle_timeout !=3D (~0);
>> > > +}
>>
>> Why did this change again?
>>
>> It's a disconnect timer, and the idle_timeout sets the timeout perio=
d. A
>> test for whether or not that period is 0 therefore makes sense (a ze=
ro
>> timeout being a nonsense value for a timer).
>>
>> Testing for arbitrary non-zero values is more dubious, and forces th=
e
>> backchannel to explicitly set a non-zero value. What value does that
>> add?
>>
>
> Good question. I agree with your direction.
>
> Alexandros, why was this !=3D 0 in PATCH 3/3 v2:
> http://linux-nfs.org/pipermail/pnfs/2009-September/009057.html
> but changed back to ~0 in PATCH 3/3 v2.1?
> http://linux-nfs.org/pipermail/pnfs/2009-September/009059.html
>
> With this in mind, xs_setup_bc_tcp can simply initialize idle_timeout
> to zero, right?
> =A0 =A0 =A0 =A0xprt->bind_timeout =3D 0;
> =A0 =A0 =A0 =A0xprt->connect_timeout =3D 0;
> =A0 =A0 =A0 =A0xprt->reestablish_timeout =3D 0;
> - =A0 =A0 =A0 xprt->idle_timeout =3D (~0);
> + =A0 =A0 =A0 xprt->idle_timeout =3D 0;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * The backchannel uses the same socket connection as =
the
>
> Benny
>
>>
>> --
>> Trond Myklebust
>> Linux NFS client maintainer
>>
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
>>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>

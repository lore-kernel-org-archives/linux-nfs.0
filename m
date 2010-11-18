Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:58218 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758501Ab0KROqJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Nov 2010 09:46:09 -0500
Subject: Re: [PATCH 1/3] NFS add minorversion to nfs_find_client search
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: benny@panasas.com, linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTi=9RvncYzh1pRUNH1vZ9gwDxczc=5A7CeNvf=w-@mail.gmail.com>
References: <1289964990-4480-1-git-send-email-andros@netapp.com>
	 <1289964990-4480-2-git-send-email-andros@netapp.com>
	 <1290035454.3070.15.camel@heimdal.trondhjem.org>
	 <AANLkTi=9RvncYzh1pRUNH1vZ9gwDxczc=5A7CeNvf=w-@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 18 Nov 2010 09:46:02 -0500
Message-ID: <1290091562.3187.16.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-11-18 at 09:11 -0500, William A. (Andy) Adamson wrote:
> On Wed, Nov 17, 2010 at 6:10 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Tue, 2010-11-16 at 22:36 -0500, andros@netapp.com wrote:
> >>  static int nfs_callback_authenticate(struct svc_rqst *rqstp)
> >>  {
> >>       struct nfs_client *clp;
> >>       RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
> >> +     u32 minorversion = svc_is_backchannel(rqstp) ? 1 : 0;
> >
> > Hmm... Nope. minorversion == CB_COMPOUND4args->minorversion.
> 
> Nope. We are in the pg_authenticate method called from
> svc_process_common in the RPC layer. We know nothing in the NFS layer.
> We won't know what CB_COMPOUND4args says until after decode.

My point is we shouldn't call it 'minorversion', 'cos it isn't...

> What's ugly is that the session information really belongs in the RPC layer.
> 
> The other way I was thinking of coding this is to not share the
> svc_program for v4 and v4.1 callback services. Each svc_program can
> then declare it's own pg_authenticate method which will know if it's
> v4.0 or v4.1.

As I said below: you _know_ which socket this came from, so you know if
it is a session backchannel or not. That's all you care about here.

> >
> >>       int ret = SVC_OK;
> >>
> >>       /* Don't talk to strangers */
> >> -     clp = nfs_find_client(svc_addr(rqstp), 4);
> >> +     clp = nfs_find_client(svc_addr(rqstp), 4, minorversion);
> >
> > Why do we need this at all in the NFSv4.1 case? Unlike minor version ==
> > 0, we _know_ that it arrived on a socket that is associated to a
> > specific session. Can't we find a way to pass that information down to
> > the callback server thread?
> 
> As long as we only support a single session to a server, and a single
> back channel using the fore channel connection, doesn't using the
> minorversion has the same effect? I believe there is only one
> nfs_client struct associated with the <rqstp->rq_addr, nfsversion,
> minorversion> tuple.  By adding the minorversion, nfs_find_client now
> uses the same criteria as nfs_match_client which decides when to
> create a new nfs_client or use an existing one.

The 'as long as we only support' bit is exactly the problem. We
shouldn't assume that we have 1 session per server because in the
long-term that isn't going to be the case.

> Knowing which session is associated with the callback thread won't do
> us any good here where we have yet to decode the request session from
> CB_SEQUENCE.

Then we shouldn't be caring too much about whether or not the server is
talking minor version 0 or 1 here. Do it when we know more about the
CB_COMPOUND.

> >
> >>       if (clp == NULL)
> >> -             return SVC_DROP;
> >> +             return SVC_DENIED;
> >
> > Nope. SVC_DROP is correct. We shouldn't reply to unsolicited callbacks
> > at all...
> 
> Should nfsd also do the same? In nfsd's pg_authenticate routine
> svcauth_gss_set_client, if the auth domain is not found - which I
> think is the same as not finding a matching nfs_client in the callback
> server, SVC_DENIED is returned.   The other nfsd pg_authenticate
> routine, svcauth_unix_set_client,  also returns SVC_DENIED when the
> ip_map_cache or lookup fails. So, nfsd replys with an rpc auth error
> to unsolicited requests.

I can see why the NFS server would care to let the client quickly
whether or not the RPC request is denied, but why do we care on the
backchannel case? If a server is sending us callbacks, and we don't
recognise that server, why should we waste computing and networking
cycles by replying at all?

Trond


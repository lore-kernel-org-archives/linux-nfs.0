From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/8] SUNRPC: Split portmap unregister API into separate
	function
Date: Wed, 23 Jul 2008 12:58:42 -0400
Message-ID: <20080723165842.GI12595@fieldses.org>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net> <20080630224545.24887.61618.stgit@ellison.1015granger.net> <20080718232123.GA15850@fieldses.org> <76bd70e30807202017hec9d1der1bbbf5c5dcedac45@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36242 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394AbYGWQ6r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2008 12:58:47 -0400
In-Reply-To: <76bd70e30807202017hec9d1der1bbbf5c5dcedac45-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 20, 2008 at 11:17:02PM -0400, Chuck Lever wrote:
> On Fri, Jul 18, 2008 at 7:21 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Mon, Jun 30, 2008 at 06:45:45PM -0400, Chuck Lever wrote:
> >> Create a separate server-level interface for unregistering RPC services.
> >>
> >> The mechanics of and the API for registering and unregistering RPC
> >> services will diverge further as support for IPv6 is added.
> >>
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >>
> >>  net/sunrpc/svc.c |   71 +++++++++++++++++++++++++++++++++++++++++++++---------
> >>  1 files changed, 59 insertions(+), 12 deletions(-)
> >>
> >>
> >> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> >> index d0e7865..a41b163 100644
> >> --- a/net/sunrpc/svc.c
> >> +++ b/net/sunrpc/svc.c
> >> @@ -27,6 +27,8 @@
> >>
> >>  #define RPCDBG_FACILITY      RPCDBG_SVCDSP
> >>
> >> +static void svc_unregister(const struct svc_serv *serv);
> >> +
> >>  #define svc_serv_is_pooled(serv)    ((serv)->sv_function)
> >>
> >>  /*
> >> @@ -426,9 +428,8 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
> >>               spin_lock_init(&pool->sp_lock);
> >>       }
> >>
> >> -
> >>       /* Remove any stale portmap registrations */
> >> -     svc_register(serv, 0, 0);
> >> +     svc_unregister(serv);
> >>
> >>       return serv;
> >>  }
> >> @@ -496,8 +497,7 @@ svc_destroy(struct svc_serv *serv)
> >>       if (svc_serv_is_pooled(serv))
> >>               svc_pool_map_put();
> >>
> >> -     /* Unregister service with the portmapper */
> >> -     svc_register(serv, 0, 0);
> >> +     svc_unregister(serv);
> >>       kfree(serv->sv_pools);
> >>       kfree(serv);
> >>  }
> >> @@ -758,12 +758,10 @@ int
> >>  svc_register(struct svc_serv *serv, int proto, unsigned short port)
> >>  {
> >>       struct svc_program      *progp;
> >> -     unsigned long           flags;
> >>       unsigned int            i;
> >>       int                     error = 0, dummy;
> >>
> >> -     if (!port)
> >> -             clear_thread_flag(TIF_SIGPENDING);
> >> +     BUG_ON(proto == 0 && port == 0);
> >>
> >>       for (progp = serv->sv_program; progp; progp = progp->pg_next) {
> >>               for (i = 0; i < progp->pg_nvers; i++) {
> >> @@ -791,13 +789,62 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
> >>               }
> >>       }
> >>
> >> -     if (!port) {
> >> -             spin_lock_irqsave(&current->sighand->siglock, flags);
> >> -             recalc_sigpending();
> >> -             spin_unlock_irqrestore(&current->sighand->siglock, flags);
> >> +     return error;
> >> +}
> >
> > The "port" in the (port && !dummy) check in this loop should also go.
> 
> If this patch were by itself, yes.  But all this is cleaned out in the
> next subsequent patch.  I don't think it makes a difference here,
> unless you think there is a good possibility these patches will be
> separated.

Yeah, I hadn't noticed that you caught that in the next patch, thanks.

That change does logically belong in this patch, though.

> >> +/*
> >> + * The local rpcbind daemon listens on either only IPv6 or only
> >> + * IPv4.  The kernel can't tell how it's configured.
> >> + *
> >> + * However, AF_INET addresses are mapped to AF_INET6 in IPv6-only
> >> + * configurations, so even an unregistration request on AF_INET
> >> + * will get to a local rpcbind daemon listening only on AF_INET6.
> >> + *
> >> + * So we always unregister via AF_INET (the loopback address is
> >> + * fairly unambiguous anyway).
> >> + *
> >> + * At this point we don't need rpcbind version 4 for unregistration:
> >> + * A v2 UNSET request will clear all transports (netids), addresses,
> >> + * and address families for [program, version].
> >> + *
> >> + * This should allow automatic support for both an all-IPv4 and
> >> + * an all-IPv6 configuration.
> >> + */
> >> +static void __svc_unregister(struct svc_program *program, u32 version)
> >> +{
> >> +     int error, boolean;
> >> +
> >> +     error = rpcb_register(program->pg_prog, version, 0, 0, &boolean);
> >> +     dprintk("svc: svc_unregister(%sv%u), error %d, %s\n",
> >> +                     program->pg_name, version, error,
> >> +                     (boolean ? "succeeded" : "failed"));
> >> +}
> >> +
> >> +/*
> >> + * All transport protocols and ports for this service are removed from
> >> + * the local rpcbind database.  The result of unregistration is reported
> >> + * via dprintk for those who want verification of the result, but is
> >> + * otherwise not important.
> >> + */
> >> +static void svc_unregister(const struct svc_serv *serv)
> >> +{
> >> +     struct svc_program *program;
> >> +     unsigned long flags;
> >> +     u32 version;
> >
> > It may just be brain-damage from too many years of mathematics, but
> > let's leave this as "i" as before: its scope is only a few lines, its
> > meaning is obvious from use, and this is what CodingStyle asks for
> > anyway.
> 
> It may seem like a small thing, but I must disagree here.  I assume
> you are quibbling with the new name only and not the type change.
>
> My reading of CodingStyle Chapter 4 is that "i" is appropriate instead
> of "tmp" or "x" or "index" -- in other words where you need a generic
> iterator.  It doesn't require the name "i" for _all_ loop iterators.
> I certainly wouldn't use "i" if I were iterating over characters or
> addresses.
> 
> In mathematics (as you well know), "i, j, k" are used as subscripts or
> for sequences or summations; often they refer to _every_ possible
> value.  We don't have any of that here.  We are passing in RPC version
> numbers.  These may not even be in sequence:  mountd has versions 1,
> 3, and 4, but not 2, nor 5 and above.

I don't agree that use of "i", "j", or "k" comes with any connotation of
unrestricted range.

> Any modern structured programming text recommends that we should name
> the variable something that reflects its use.  "i" is really quite
> generic; "version" is "short and to the point," as Chapter 4
> recommends.

One-letter variables have readability advantages which for me on balance
win out in the case of a single short loop such as this.

I don't care enough to oppose this in new code if you strongly prefer
it, but at least leave existing uses alone; it's just one more thing I
have to filter out when I read the patch.

> [ "vers" is perhaps more concise, but I think nothing but ambiguity is
> gained from dropping the last three letters.  "lovers" could easily be
> "low version" or "star-crossed lovers", for example].
> 
> Over the past several kernel releases I've included patches that
> change variables storing RPC version numbers to "u32 version" wherever
> they are used.  I really don't see the need to be different here, and
> I'd rather be consistent with nearly every other usage.  If you're
> storing an RPC version number, it is a u32 field or variable called
> "version."  The type and the name match what is in the RFCs.
> 
> >
> >> +
> >> +     clear_thread_flag(TIF_SIGPENDING);
> >> +
> >> +     for (program = serv->sv_program; program; program = program->pg_next) {
> >> +             for (version = 0; version < program->pg_nvers; version++) {
> >> +                     if (program->pg_vers[version] == NULL)
> >> +                             continue;
> >> +                     __svc_unregister(program, version);
> >
> > Isn't there a change in behavior from the omitted vs_hidden check?
> > I assume it's harmless to unregister something that was never
> > registered (if that's indeed what this does), but it seems better to
> > skip it.
> 
> svc_unregister() is used in svc_create() before registering a new
> service, and in svc_destroy() when unregistering a service being shut
> down.
> 
> It's advisable to do this now even for so-called hidden services
> because of the ability for rpcbind to advertise RPC services at
> particular addresses.  The kernel registers an RPC service for the ANY
> address, so all addresses for that service that are already registered
> should be removed first.
> 
> Perhaps for hidden services, svc_unregister() should warn loudly or
> fail immediately as a safety precaution, as these services should not
> have been registered already, and if they are, we may be colliding
> with something in user space.
> 
> > Needs a comment in the changelog in any case.
> 
> OK.

Could you also make it a separate patch?  I'd like any functional
changes split out from pure code rearrangement.

--b.

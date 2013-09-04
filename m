Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58993 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763155Ab3IDRuD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 13:50:03 -0400
Date: Wed, 4 Sep 2013 13:49:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, Jan Stancek <jstancek@redhat.com>
Subject: Re: [PATCH v3] SUNRPC: Ensure that the RPCSEC_GSS daemon uses the
 correct service names
Message-ID: <20130904174959.GB10232@fieldses.org>
References: <1377202213-5031-1-git-send-email-jlayton@redhat.com>
 <1377320162.2814.331.camel@willson.li.ssimo.org>
 <20130824065706.7bf780e8@tlielax.poochiereds.net>
 <20130824124233.GC18084@fieldses.org>
 <20130826165051.GF3121@fieldses.org>
 <1378264314.13768.89.camel@willson.li.ssimo.org>
 <20130904133901.GE557@fieldses.org>
 <1378315313.13768.112.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1378315313.13768.112.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 04, 2013 at 01:21:53PM -0400, Simo Sorce wrote:
> On Wed, 2013-09-04 at 09:39 -0400, J. Bruce Fields wrote:
> > On Tue, Sep 03, 2013 at 11:11:54PM -0400, Simo Sorce wrote:
> > > On Mon, 2013-08-26 at 12:50 -0400, J. Bruce Fields wrote:
> > > > Well, but: after refamiliarizing myself with the code this morning:
> > > > really, it's irrelevant.  The server's setup_callback_client() calls
> > > > rpc_create with client_name set to the principal that performed the
> > > > setclientid.  This sets cl_principal, which results in a "target="
> > > > argument in the upcall.
> > > > 
> > > > (The way this is set looks hairy:
> > > > 
> > > >         - svcgssd case: svcgssd passes it down at the end of the
> > > >           downcall.  It's calculated by
> > > >           utils/gssd/svcgssd_proc.c:get_hostbased_client_name by
> > > > calling
> > > >           gss_display_name() and then changing x/y@REALM to x@y in the
> > > >           krb5 case.  ??
> > > >         - gssproxy case: does the same transformation on the returned
> > > >           name in gssp_accept_sec_context_upcall.
> > > > 
> > > > But Simo'd be the expert on whether this makes sense and what we
> > > > should do instead if not.)
> > > 
> > > The way this is done make little sense, and I guess it is probably
> > > historical due to some deficiency in GSSAPI extensions at the time or
> > > knowledge of whoever was building the support.
> > > 
> > > GSSAPI uses by default service@server form for the target service name
> > > but it is not the only way to import a name. If you are going to force
> > > the usage of the krb5 mechanism (as we are) then we could have simply
> > > exported the name (gives a buffer) and then re-imported back later.
> > > 
> > > In any case it is what it is, I think it makes little sense in principle
> > > to try to 'contact back' the 'client' principal that authenticated
> > 
> > Well, that part at least is required by the spec, unless I've misread
> > something.  (RFC 3530 section 3.4.)
> > 
> > > as
> > > that principal may even be a user principal and you'll probably not be
> > > able to get a ticket to talk to 'it' and the receiving server will
> > > probably not have keys to understand your ticket even if you got one.
> > 
> > So if you want delegations to work you're expected to give the client a
> > principal that the server can authenticate back to.  (Delegations are
> > the only NFSv4.0 feature that depend on callbcks.)
> 
> In many deployments this is not possible, so the original specification
> is unrealistic.
> If the client already has a channel open with the server, why on earth
> the server does not just reuse that channel to send back messages ?
> Why it is trying a call 'back' ?
> 
> Callbacks are notoriously broken, they do not work when clients do not
> have a service principal, and if you are actually trying to open a TCP
> socket back it will break if a client is behind a NAT or has a strict
> firewall in front of it and so on and so forth...

Right, this got fixed in NFSv4.1.

So I'm just describing the legacy responsibility to keep NFSv4.0
callbacks working in those cases where they can, to prevent regressions
for 4.0 users whose setups do meet the requirements.

--b.

> 
> I hoped people stopped using callbacks for this type of operations long
> ago when Microsoft experimented with this bad idea in the 90ies with the
> CIFS protocol and gave up (they tried to use callback for printing for
> example).
> 
> Simo.
> 
> -- 
> Simo Sorce * Red Hat, Inc * New York
> 

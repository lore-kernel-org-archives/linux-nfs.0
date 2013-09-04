Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752537Ab3IDDL6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Sep 2013 23:11:58 -0400
Subject: Re: [PATCH v3] SUNRPC: Ensure that the RPCSEC_GSS daemon uses the
 correct service names
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, Jan Stancek <jstancek@redhat.com>
In-Reply-To: <20130826165051.GF3121@fieldses.org>
References: <1377202213-5031-1-git-send-email-jlayton@redhat.com>
	 <1377320162.2814.331.camel@willson.li.ssimo.org>
	 <20130824065706.7bf780e8@tlielax.poochiereds.net>
	 <20130824124233.GC18084@fieldses.org>  <20130826165051.GF3121@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 03 Sep 2013 23:11:54 -0400
Message-ID: <1378264314.13768.89.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-08-26 at 12:50 -0400, J. Bruce Fields wrote:
> > > > Also the patch seem to add a bunch of other 'service' names ? If
> you are
> > > > going to kerberize those services are you going to expect admins
> to drop
> > > > multiple keys down in the keytabs ? What is the exact intent
> here ?
> 
> Yeah, that seems wrong to me, if (big if) any of the other services
> used gss I'd expect they'd want to authenticate to the same nfs/
> principal.
> 
> > > Mostly, I'm trying to ensure that the nfsacl service uses a nfs/
> > > principal to fix the immediate pain point that nfsv3+krb5 doesn't
> work.
> > > With the rest, I was mainly trusting that Trond knew what he was
> > > doing. ;)
> > > 
> > > I agree though...I've never seen a nfs4_cb/ principal in use, and
> I'm
> > > not sure that we'd really get a lot of value from using a separate
> > > principal for callbacks.
> > 
> > It's wrong, in fact: an NFSv4.0 callback is supposed to authenticate
> to
> > the principal that performed the setclientid.
> 
> Well, but: after refamiliarizing myself with the code this morning:
> really, it's irrelevant.  The server's setup_callback_client() calls
> rpc_create with client_name set to the principal that performed the
> setclientid.  This sets cl_principal, which results in a "target="
> argument in the upcall.
> 
> (The way this is set looks hairy:
> 
>         - svcgssd case: svcgssd passes it down at the end of the
>           downcall.  It's calculated by
>           utils/gssd/svcgssd_proc.c:get_hostbased_client_name by
> calling
>           gss_display_name() and then changing x/y@REALM to x@y in the
>           krb5 case.  ??
>         - gssproxy case: does the same transformation on the returned
>           name in gssp_accept_sec_context_upcall.
> 
> But Simo'd be the expert on whether this makes sense and what we
> should do instead if not.)

The way this is done make little sense, and I guess it is probably
historical due to some deficiency in GSSAPI extensions at the time or
knowledge of whoever was building the support.

GSSAPI uses by default service@server form for the target service name
but it is not the only way to import a name. If you are going to force
the usage of the krb5 mechanism (as we are) then we could have simply
exported the name (gives a buffer) and then re-imported back later.

In any case it is what it is, I think it makes little sense in principle
to try to 'contact back' the 'client' principal that authenticated as
that principal may even be a user principal and you'll probably not be
able to get a ticket to talk to 'it' and the receiving server will
probably not have keys to understand your ticket even if you got one.

TL;DR it kinda sucks but it is not worth changing much except for using
only 'nfs' as the service type and nothing else.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46202 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684Ab1HRJTR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Aug 2011 05:19:17 -0400
Date: Thu, 18 Aug 2011 19:19:06 +1000
From: NeilBrown <neilb@suse.de>
To: Kevin Coffman <kwc@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problems with kerberos auth - possibly against ADS - since
 nfs-utils-1.2.3
Message-ID: <20110818191906.13a6261f@notabene.brown>
In-Reply-To: <CAKnQG+eV_OCk60wN6E2ub-TxA+6NoALYn8C+1PD51fWUZTpcGQ@mail.gmail.com>
References: <20110804092141.3461c9ce@notabene.brown>
	<CAKnQG+cs4SLD-YmLwpnXU_gDWrjfmx9+z-E=7J-SUcsP=KhfSg@mail.gmail.com>
	<20110804111357.0d0a6e85@notabene.brown>
	<CAKnQG+dViSmrjhZV1cFZHj98kM0ixyKRLek9OWkJjFUS6YO3cw@mail.gmail.com>
	<20110811154239.322dee1d@notabene.brown>
	<CAKnQG+eV_OCk60wN6E2ub-TxA+6NoALYn8C+1PD51fWUZTpcGQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 11 Aug 2011 10:06:05 -0400 Kevin Coffman <kwc@umich.edu> wrote:

> On Thu, Aug 11, 2011 at 1:42 AM, NeilBrown <neilb@suse.de> wrote:
> > On Wed, 3 Aug 2011 22:57:10 -0400 Kevin Coffman <kwc@umich.edu> wrote:
> >
> >> On Wed, Aug 3, 2011 at 9:13 PM, NeilBrown <neilb@suse.de> wrote:
> >> > On Wed, 3 Aug 2011 20:51:52 -0400 Kevin Coffman <kwc@umich.edu> wrote:
> >> >
> >> >> On Wed, Aug 3, 2011 at 7:21 PM, NeilBrown <neilb@suse.de> wrote:
> >> >> >
> >> >> > Hi,
> >> >> >  I have some reports of problems with kerberos auth in openSUSE 11.4 (using
> >> >> >  1.2.3) which can be fixed by using the openSUSE 11.3 version of rpc.gssd
> >> >> >  (from 1.2.1).
> >> >> >
> >> >> > https://bugzilla.novell.com/show_bug.cgi?id=614293
> >> >> >
> >> >> >  The important difference seems to be the list of enc_types used in
> >> >> >  limit_krb5_enctypes.
> >> >> >
> >> >> >  In 1.2.1 this list is hard coded in the rpc.gssd to 1,3,2 (I think).
> >> >> >  In 1.2.3 this list is taken from the kernel where is it hard coded
> >> >> >  to  18,17,16,23,3,1,2.
> >> >> >  When I patch the 11.4 code to use the old enctype list, it works perfectly.
> >> >> >
> >> >> >  So presumably it ends up negotiating one of those other enc_types and
> >> >> >  gets confused by it.
> >> >> >
> >> >> >  I'll try to get a comparative tcp dump to see if that helps, but
> >> >> >  if anyone has any idea what the problem might be I'd love to hear
> >> >> >  suggestions.
> >> >> >
> >> >> >  The systems are running a 2.6.37 kernel in case that might make a difference.
> >> >> >
> >> >> > Thanks,
> >> >> > NeilBrown
> >> >>
> >> >> Hi Niel,
> >> >> Seeing the traffic might help.  It wasn't clear to me after reading
> >> >> (most of) the bugzilla info what kernel version the NFS servers
> >> >> involved are running.  If the servers don't have kernels with the
> >> >> newer enctype support, this might be the "subkey assertion" issue.
> >> >>
> >> >
> >> > Hi Kevin,
> >> >  thanks for the reply.  I've asked for that extra info (trace and server
> >> >  details) - hopefully we'll get that in the next day or so.
> >> >
> >> >  The this is a buggy server issue, and it is wide-spread, I wonder if it
> >> >  might make sense for gssd to fall back on the old enctype list if
> >> >  negotiation fails with the new list.  Does that sound at all reasonable?
> >> >
> >> > Thanks,
> >> > NeilBrown
> >>
> >> Hi Niel,
> >> Not totally unreasonable, but if it is the acceptor subkey assertion
> >> issue, it might be less work to forward-port the svcgssd patches to
> >> limit the enctypes on the server side?
> >>
> >> K.C.
> >
> > I assume you mean back-port ??
> >
> > Depends on what you mean by "less work".
> > Situation was that client and server could communicate via nfs/kerberos.
> > Upgrading the client resulted in the client and server not being able to
> > communicate.
> > Suggesting that the server should be upgraded to fix this might be a big ask -
> > it is very likely that they want to keep the server stable - or even that
> > someone else controls the server and isn't interested.
> >
> > So we really need new client code to work with old servers...
> >
> > I'm making slow progress (I should really set up kerberos at home so I can
> > experiment rather than relying on customer to do all the testing ... is there
> > a simple recipe somewhere???),
> > however I had discovered something that seems very strange.
> >
> > In the tcpdump traces that I have of a successful negotiation I see an
> > RPC/NULL being used for RPCSEC_GSS_INIT where the request plus the reply seem
> > to complete the handshake, then I see another RPC/NULL with
> > RPCSEC_GSS_DESTROY just before the connection is closed.
> >
> > The last message is malformed in that there is a credential but no verifier
> > so the server ignores it - which is just as well else it would destroy the
> > context that has just been established.
> >
> > Looking at the code this must be triggered by
> >
> >        if (auth)
> >                AUTH_DESTROY(auth);
> >
> > in process_krb5_upcall.  This presumably calls authgss_destroy which calls
> > authgss_destroy_context which sends the RPCSEC_GSS_DESTROY call.  I don't
> > understand why there is no verifier though.  This should be added in
> > authgss_marshal() and the fact that it is missing suggests that gss_get_mic
> > (on the packet header and credential) failed.  But why would it fail if the
> > context has been set up?
> > Hmmm.... the context has been stolen by authgss_get_private_data() ... or
> > part of the context has ... so authgss_destroy shouldn't be sending
> > RPCSEC_GSS_DESTROY at all.  I'm confused.
> >
> > I guess it is time to set up a kerberos domain myself... can't be that hard.
> >
> > NeilBrown
> 
> Hi Neil,
> 
> Yes, I think back-port is the correct term.
> 
> I'm still in the dark about what the exact issue is.  Here is how the
> acceptor subkey issue comes into play:
> 
> - Server's kernel only supports DES and has a keytab with only DES
> keys.  It has newer Kerberos libraries that can "assert" an "acceptor
> subkey"
> 
> - Older Linux clients limit the negotiated enctypes to DES because
> their kernel only supports DES.  (gssd already has code to do this)
> 
> - New Linux client now has a kernel that supports stronger enctypes
> and stops limiting the enctypes in the negotiation.
> 
> - The Kerberos libraries ignore the fact that the server only has DES
> keys in its keytab and now negotiates a context with an AES subkey
> asserted.  (svcgssd is happy to do this)   This AES context is sent
> down to the server's kernel which still only supports DES and doesn't
> know what to do with it.


Hi Kevin.
I think that does exactly describes what we were seeing.
We ended up working around it by adding 

  default_tkt_enctypes = des-cbc-md5 des-cbc-crc des3-cbc-sha1

to the client config, and recommending a server upgrade.


BTW I've been trying to track down why a successful kerberos negotiation
sends a corrupted RPCSEC_GSS_DESTROY request just before closing the
connection.

There are two issues here.
1/ Why is it trying to send a DESTROY request
2/ Why is it corrupted.

It is just as well that it is corrupted else the server would forget the
session that has just been negotiated.

It is sending a DESTROY request because that is what AUTH_DESTROY called in
gssd_proc does.  But it shouldn't.  After a call to
authgss_get_private_data() the context is owned by someone else so
AUTH_DESTROY should free the memory, but not DESTROY anything on the server.

I think authgss_get_private_data should clear gd->established or possibly 
gd->gc.gc_ctx.length so there is no attempt to use or destroy the auth internally
any more.

But why is it corrupted?  This is because the internal_ctx_id in the gssglue
layer has been zeroed by the call to authgss_get_private_data.  I couldn't
easily see in the code where this is happening, but tracing confirms that it
does.  A NULL internal_ctx_id doesn't stop authgss_destroy_context from
trying to destroy the context, but it does stop it from succeeding.

So I suspect all we need to do to address this is change
authgss_get_private_data to set gd->gc.gc_ctx.length to zero.

Does that seem reasonable to you?


Thanks,
NeilBrown


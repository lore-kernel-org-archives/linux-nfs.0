From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Wed, 22 Sep 2004 16:54:12 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16721.8596.980204.899779@cse.unsw.edu.au>
References: <1095375544.839c1c96.3@fieldses.org>
	<1095383919.10216.142.camel@lade.trondhjem.org>
	<20040917022015.GA15212@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CA11X-0006lP-91
	for nfs@lists.sourceforge.net; Tue, 21 Sep 2004 23:54:43 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CA11V-0008GE-8n
	for nfs@lists.sourceforge.net; Tue, 21 Sep 2004 23:54:41 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Thursday September 16
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thursday September 16, bfields@fieldses.org wrote:
> On Thu, Sep 16, 2004 at 09:18:39PM -0400, Trond Myklebust wrote:
> > You are making a special method that is really very specific to
> > svcauth_unix and svcauth_null, yet the pg_set_client() appears as a
> > generic method in the generic svc_program object.
> > 
> > Firstly, I'd strongly suggest that we call this callback pg_set_domain
> > so that there is no confusion about what it does.
> 
> After considering that, I decided that "client" (which is used in
> rq_client, in the nfsctl's (add_client), etc., in the exportfs
> documentation, etc.) makes more sense than "domain" (used only in the
> type struct auth_domain).
> 
> > Secondly, please explain why we're leaving RPCSEC_GSS as a special case
> > here? Isn't the current implementation also calling up to "rpc.mountd"
> > in order to check "/etc/exports"?
> 
> Yes, but that doesn't happen till later--we have to have a filehandle
> for that.  The mistake was probably referring to "the export table" in
> the patch comments--we're not really looking at that yet, we're only
> looking up the name of this client--it's not much more than a reverse
> dns lookup.  (So in the worst case, in auth_unix, there are *two*
> upcalls--one here, to get the name of the client, then one later to
> actually see whether something's exported to that client.)
> 
> So this upcall really is auth_unix/auth_null-specific.
> 
> But still there's some odd asymmetry here, I agree--I need to think
> about the auth_gss case.

I suspect that is an excellent idea.  Work out the auth_gss case which
is likely to be more general, and then make auth_{unix,null} fit in
with that.

For nfsd, there are three up-calls that can be made for an auth_unix
authenticated request.
  1 - lookup IP address and get 'client' identifier
  2 - lookup filehandle (prefix) and get filesystem
  3 - lookup client + filesystem and get export flags.

(1) could be seen as an "authentication" step, while (3) is an
"authorisation" step. ( (2) is just an internal lookup).
(1) doesn't look much like authentication, but the equivalent with
auth_gss does (I think).

For call-backs, the authorisation and any other lookup would be
handled inside the kernel, but the authentication could still need an
up-call - to start a gss session for example.

In 2.4, lockd authentication piggy-backed on nfsd authentication for
just those requests that were thought to need it.  The rest were
unauthenticated.   Presumably we should be doing the same in 2.6 - not
require auth for some requests, and just leave nfsd auth for the
remaining.
One approach is the patches you produced.  Another might be a
per-svc_procedure flag to say whether auth was required or not.  There
are doubtlessly others.

Alternately, the code which causes a call-back to be meaningful
(e.g. nlmclnt_lock in lockd (??)) could insert the relevant
information into the auth cache in advance.


For gss, I presume a callback needs the same authentication as a
regular service so it would be nice to use the same mechanism.
Presumably this couldn't be satisfied completely within the kernel
without adding too much extra gss_init code. i.e. the kernel shouldn't
need upcalls to find out keys, but only to perform the
context-establishment handshake.  But who's upcall mechanism do we use
here??

I've rambled a bit, hopefully not to much.

To summarise:
  - I'm not in favour of the pg_set_client method in it's current
    form.
  - I think that for AUTH_UNIX call-backs, the best approach would be
    do have the caller insert the relevant information into the
    current ip-lookup cache, but that due to the vagaries of
    multi-homed hosts(*), that might not work.  Second best would be to
    ignore the IP address (as 2.4 lockd does) and trust to the
    contents of the request being hard to fake.
  - For gss, an upcall will be needed to authenticate the call-back,
    so use the current kernel-side infrastructure for request
    authentication.


(*) I note that nfs/callback.c find the client based in the IP
address.  Is there anything in the code or the NFSv4 spec that allows
for the fact that a server might have multiple IP addresses and that
the callback might come from a different address than requests are
being sent to??

> 
> > Ideally, all the *_accept() methods
> > should be calling the same function to set the domain (or not to set it
> > as the case may be). Better still: could we defer calling
> > pg_set_domain() until after the call to svc_authenticate?
> 
> That would be nice.

I don't think that makes sense.  It is the client that is being
authenticated.  The end-product of authentication is knowing who the
client is.  How can you separate one for the other?

> 
> > Finally, please could we move the domain_release() method out of struct
> > auth_ops and into struct auth_domain itself?
> 
> Yeah, that's probably a good idea.

Agreed.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

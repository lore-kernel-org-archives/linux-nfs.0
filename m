From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Thu, 16 Sep 2004 22:20:15 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040917022015.GA15212@fieldses.org>
References: <1095375544.839c1c96.3@fieldses.org> <1095383919.10216.142.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C88MK-00063p-Gz
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 19:20:24 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C88MJ-00050T-Lk
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 19:20:24 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1095383919.10216.142.camel@lade.trondhjem.org>
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

On Thu, Sep 16, 2004 at 09:18:39PM -0400, Trond Myklebust wrote:
> You are making a special method that is really very specific to
> svcauth_unix and svcauth_null, yet the pg_set_client() appears as a
> generic method in the generic svc_program object.
> 
> Firstly, I'd strongly suggest that we call this callback pg_set_domain
> so that there is no confusion about what it does.

After considering that, I decided that "client" (which is used in
rq_client, in the nfsctl's (add_client), etc., in the exportfs
documentation, etc.) makes more sense than "domain" (used only in the
type struct auth_domain).

> Secondly, please explain why we're leaving RPCSEC_GSS as a special case
> here? Isn't the current implementation also calling up to "rpc.mountd"
> in order to check "/etc/exports"?

Yes, but that doesn't happen till later--we have to have a filehandle
for that.  The mistake was probably referring to "the export table" in
the patch comments--we're not really looking at that yet, we're only
looking up the name of this client--it's not much more than a reverse
dns lookup.  (So in the worst case, in auth_unix, there are *two*
upcalls--one here, to get the name of the client, then one later to
actually see whether something's exported to that client.)

So this upcall really is auth_unix/auth_null-specific.

But still there's some odd asymmetry here, I agree--I need to think
about the auth_gss case.

> Ideally, all the *_accept() methods
> should be calling the same function to set the domain (or not to set it
> as the case may be). Better still: could we defer calling
> pg_set_domain() until after the call to svc_authenticate?

That would be nice.

> Finally, please could we move the domain_release() method out of struct
> auth_ops and into struct auth_domain itself?

Yeah, that's probably a good idea.

Thanks for the comments.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

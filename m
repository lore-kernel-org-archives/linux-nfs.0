From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Tue, 28 Sep 2004 18:00:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040928220055.GI5554@fieldses.org>
References: <1095375544.839c1c96.3@fieldses.org> <1095383919.10216.142.camel@lade.trondhjem.org> <20040917022015.GA15212@fieldses.org> <16721.8596.980204.899779@cse.unsw.edu.au> <20040923214644.GA19291@fieldses.org> <16723.40128.804230.618580@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CCQ23-0008UX-2O
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 15:01:11 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CCQ1y-0002hz-LZ
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 15:01:10 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16723.40128.804230.618580@cse.unsw.edu.au>
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

On Fri, Sep 24, 2004 at 02:04:16PM +1000, Neil Brown wrote:
> On Thursday September 23, bfields@fieldses.org wrote:
> > On Wed, Sep 22, 2004 at 04:54:12PM +1000, Neil Brown wrote:
> > > Alternately, the code which causes a call-back to be meaningful
> > > (e.g. nlmclnt_lock in lockd (??)) could insert the relevant
> > > information into the auth cache in advance.
> > 
> > There's not really a reliable way to do that with the current code since
> > userspace can flush the auth_domain cache at whim.
> 
> 
> Hmm... yes. Thanks.
> 
> I'm thinking that you really need to either involve user-space in
> authenticating callbacks (issues like multi-homed servers mean that
> the kernel cannot cope by itself at all)

I can't find anything definitive on this in any rfc, but I don't believe
that clients are required to be able to deal with callbacks from a
different IP address (or that a server should allow such a thing to
happen).  Can anyone find evidence to the contrary?

> or not require RPC authentication at all (the way 2.4 works).

I believe the ip-address checking done by the nfsv4 callback service and
by lockd are correct.

Over rpcsec_gss, nfsv4 callbacks also have to be authenticated (by
checking that the principal making the callback is the server's).

> Does anyone have objections to the following patch, which presumes the 
> svcauth_unix_set_client patch from Bruce.  With it, locking starts
> working again.

This patch would suffice if we're content to postpone authentication
until the dispatch or procedure-specific code.  If we do that, then we
end up returning an NFS or NLM error instead of having the call rejected
at the rpc layer.

So, do we require the ability to e.g return an rpc auth error on
authentication failure?

If not, then the cleaner solution would be to do the same thing for
nfsd--don't do any upcalls at accept() time, and move that stuff into,
say, nfsd_dispatch(), instead.

If we *do* need to allow programs to reject rpc calls at the rpc layer,
then we need something like the program-specific hook I propose (with
some modifications to make it flavor-independent, so it works for gss as
well).

--b.


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

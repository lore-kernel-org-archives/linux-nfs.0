From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: [PATCH] kNFSd - 2 of 5 - ip_map_init does a kmalloc which isn't checked...
Date: Sun, 8 Feb 2004 00:59:21 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040208055921.GA14053@fieldses.org>
References: <20040206161050.27799.patches@notabene> <E1AoyIo-0007FS-00@notabene> <20040207012423.396efe73.akpm@osdl.org> <20040208043723.GC13391@fieldses.org> <20040207214637.387d3018.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aphyc-0006BT-1T
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 21:59:30 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Aphyb-0003r9-DB
	for nfs@lists.sourceforge.net; Sat, 07 Feb 2004 21:59:29 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040207214637.387d3018.akpm@osdl.org>
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

On Sat, Feb 07, 2004 at 09:46:37PM -0800, Andrew Morton wrote:
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >
> > On Sat, Feb 07, 2004 at 01:24:23AM -0800, Andrew Morton wrote:
> > > NeilBrown <neilb@cse.unsw.edu.au> wrote:
> > > >
> > > > There is no way to return an error from a cache init routine,
> > > >  so instead we make sure to pre-allocate the memory needed,
> > > >  and free it after the lookup if the lookup failed.
> > > 
> > > This patch causes an oops when the initscripts run exportfs.
> > 
> > Ugh.  The patches were submitted out of order; #3 should have come
> > before #2.
> > 
> 
> OK.
> 
> But with all five patches applied (or the first three) there remains the
> deadlock over that write_lock.

Yeah, I took a look and noticed there's an exit from that lookup
function that doesn't release the lock.  Something like the following
(untested) probably fixes it; I'll test and resubmit revised patches if
Neil doesn't first.

Returns in macro arguments, ugh.

--Bruce Fields


 net/sunrpc/svcauth.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff -puN net/sunrpc/svcauth.c~neil_NfsdCacheImprove_fix net/sunrpc/svcauth.c
--- linux-2.6.1/net/sunrpc/svcauth.c~neil_NfsdCacheImprove_fix	2004-02-07 23:46:28.000000000 -0500
+++ linux-2.6.1-bfields/net/sunrpc/svcauth.c	2004-02-07 23:52:31.000000000 -0500
@@ -150,7 +150,11 @@ DefineCacheLookup(struct auth_domain,
 		  &auth_domain_cache,
 		  auth_domain_hash(item),
 		  auth_domain_match(tmp, item),
-		  kfree(new); if(!set) return NULL;
+		  kfree(new); if(!set) {
+		  if (new) write_unlock(&auth_domain_cache.hash_lock);
+		  else read_unlock(&auth_domain_cache.hash_lock);
+		  return NULL;
+		  }
 		  new=item; atomic_inc(&new->h.refcnt),
 		  /* no update */,
 		  0 /* no inplace updates */

_


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

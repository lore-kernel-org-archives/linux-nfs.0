From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] RPC: add wrapper for svc_reserve to account
	for	checksum
Date: Tue, 1 May 2007 13:11:22 -0400
Message-ID: <20070501171121.GC15222@salusa.poochiereds.net>
References: <20070421131523.GA18100@dantu.rdu.redhat.com>
	<17974.41587.666167.650575@notabene.brown>
	<20070501170123.GB15222@salusa.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@linux-foundation.org
To: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hivsv-0002bQ-Qs
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 10:11:31 -0700
Received: from ms-smtp-05.southeast.rr.com ([24.25.9.104])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hivsw-0003DB-Fo
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 10:11:32 -0700
In-Reply-To: <20070501170123.GB15222@salusa.poochiereds.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, May 01, 2007 at 01:01:27PM -0400, Jeff Layton wrote:
> On Tue, May 01, 2007 at 12:14:11PM +1000, Neil Brown wrote:
> > 
> > Yes, that asn1 encoding does seem rather awkward.
> > 
> > Maybe we should just use RPC_MAX_AUTH_SIZE like other bits of GSS code
> > does.  There is no great cost in reserving too much space - it just
> > might slow things down a little when tight on memory.
> > What would you think of submitting an incremental patch which replaces
> > the "56" with "RPC_MAX_AUTH_SIZE" ?
> > 
> > Thanks (and sorry for the delay).
> > NeilBrown
> > 
> 
> Thanks for looking into this, Neil. I wasn't sure how hard a reservation that
> was (still working on wrapping my brain around the RPC code). I'll have a look
> at the patch you posted. Hopefully that is the problem...
> 
> As far as your suggestion to use RPC_MAX_AUTH_SIZE, that sounds like a good
> idea to me. I'm all for avoiding "magic" numbers. How does this look? I also
> cleaned up the comments as well.
> 

Resending patch with a proper signed-off-by line. Also cc'ing Andrew:

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 9114f11..ed7cbf1 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -399,10 +399,9 @@ char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
 /*
  * When we want to reduce the size of the reserved space in the response
  * buffer, we need to take into account the size of any checksum data that
- * may be at the end of the packet. For now, just use a hardcoded value
- * for each possible authflavor. This will need to be updated when new
- * encryption types or algorithms are added, or we'll have to come up with
- * a way to reasonably calculate this on the fly (maybe via a new auth_op).
+ * may be at the end of the packet. This is difficult to determine exactly
+ * for all cases without actually generating the checksum, so we just use a
+ * static value.
  */
 static inline void 
 svc_reserve_auth(struct svc_rqst *rqstp, int space)
@@ -411,7 +410,7 @@ svc_reserve_auth(struct svc_rqst *rqstp, int space)
 
 	switch(rqstp->rq_authop->flavour) {
 		case RPC_AUTH_GSS:
-			added_space = 56; /* determined empirically */
+			added_space = RPC_MAX_AUTH_SIZE;
 	}
 	return svc_reserve(rqstp, space + added_space);
 }

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

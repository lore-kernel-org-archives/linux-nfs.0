From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] DefineSimpleCache macro problem
Date: Thu, 13 May 2004 15:15:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040513191533.GB20649@fieldses.org>
References: <20040513082245.GM22052@suse.de> <16547.16795.844328.645694@cse.unsw.edu.au> <20040513104552.GT22052@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOLgI-0000BH-1m
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 12:15:46 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BOLgH-0002UE-HE
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 12:15:45 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040513104552.GT22052@suse.de>
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

On Thu, May 13, 2004 at 12:45:52PM +0200, Olaf Kirch wrote:
> On Thu, May 13, 2004 at 07:36:27PM +1000, Neil Brown wrote:
> > That would be wrong.  Always returning an entry (possibly non-VALID)
> > - except on kmalloc failure - is a design feature.
> 
> Does this mean I can eat all your memory by flooding your NFS server
> with NULL calls from bogus addresses? That would be bad.

There is an expiration time on those entries (2 minutes), but I don't
see any bound on the number of them.

I'm guessing one of those ip_map cache entries is about 80 bytes on
i386?  I'm not sure what a reasonable assumption is about packet rates,
but it seems like it could be a problem, unless I'm missing some other
constraint here.

> The problem is that somewhere somehow an invalid entry is created,
> which remains in the cache and the flags don't get updated.

Ugh, and it's the failure to update the flags that's the bug, I suspect.
Does this help?  (Caveat: looks straightforward enough, but I haven't
actually tested it!)

--b.

Normally the _lookup functions are only called with set = 1 on items with
CACHE_NEGATIVE not set; however in the case of the export cache it can happen,
and is especially likely if mountd isn't listening in on the
proc/net/rpc/*/content files, since then any lookup (if followed by
cache_check()) generates a CACHE_NEGATIVE entry.

Make sure we clear the CACHE_NEGATIVE bit on update if necessary in
DefineCacheLookup.


 include/linux/sunrpc/cache.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff -puN include/linux/sunrpc/cache.h~nfsd_cache_update_negative include/linux/sunrpc/cache.h
--- linux-2.6.6-rc3/include/linux/sunrpc/cache.h~nfsd_cache_update_negative	2004-05-13 14:44:13.000000000 -0400
+++ linux-2.6.6-rc3-bfields/include/linux/sunrpc/cache.h	2004-05-13 14:45:47.000000000 -0400
@@ -195,7 +195,10 @@ RTN *FNAME ARGS										\
 				}							\
 				if (test_bit(CACHE_NEGATIVE,  &item->MEMBER.flags))	\
 					 set_bit(CACHE_NEGATIVE, &tmp->MEMBER.flags);	\
-				else {UPDATE;}						\
+				else {							\
+					clear_bit(CACHE_NEGATIVE, &tmp->MEMBER.flags); \
+					UPDATE;						\
+				}							\
 			}								\
 			if (set||new) write_unlock(&(DETAIL)->hash_lock);		\
 			else read_unlock(&(DETAIL)->hash_lock);				\

_


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

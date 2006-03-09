From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 14] knfsd: Introduction
Date: Thu, 9 Mar 2006 17:51:22 +1100
Message-ID: <20060309174755.24381.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHF0h-0000Y9-BN
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:52:31 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHF0g-0006t5-60
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:52:31 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
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

The following series of patches changes the code for lookup up
authentication/authorisation caches in sunrpc as used by nfsd.  That
than having a delightful macro that defines a function of a particular
type of cache, the functions are coded on a more traditional manner
using library routines.

This will hopefully make the code more maintainable.

This series should not effect the functionality at all -- except maybe
to fix some very minor bugs

This is against 2.6.16-rc5-mm2 and is NOT suitable for 2.6.16, but maybe for .17
(though holding it back to .18 wouldn't be a big problem if any issues came up).

Thanks,
NeilBrown


 [PATCH 000 of 14] knfsd: Introduction
 [PATCH 001 of 14] knfsd: Change the store of auth_domains to not be a 'cache'.
 [PATCH 002 of 14] knfsd: Break the hard linkage from svc_expkey to svc_export
 [PATCH 003 of 14] knfsd: Get rid of 'inplace' sunrpc caches
 [PATCH 004 of 14] knfsd: Create cache_lookup function instead of using a macro to declare one.
 [PATCH 005 of 14] knfsd: Convert ip_map cache to use the new lookup routine.
 [PATCH 006 of 14] knfsd: Use new cache_lookup for svc_export
 [PATCH 007 of 14] knfsd: Use new cache_lookup for svc_expkey cache.
 [PATCH 008 of 14] knfsd: Use new sunrpc cache for rsi cache
 [PATCH 009 of 14] knfsd: Use new cache code for rsc cache
 [PATCH 010 of 14] knfsd: Use new cache code for name/id lookup caches
 [PATCH 011 of 14] knfsd: An assortment of little fixes to the sunrpc cache code.
 [PATCH 012 of 14] knfsd: Remove DefineCacheLookup
 [PATCH 013 of 14] knfsd: Unexport cache_fresh and fix a small race.
 [PATCH 014 of 14] knfsd: Convert sunrpc_cache to use krefs


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

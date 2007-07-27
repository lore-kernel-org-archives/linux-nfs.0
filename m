From: Fabio Olive Leite <fleite@redhat.com>
Subject: Re: [PATCH] Attribute timeout handling and wrapping u32
	jiffies
Date: Thu, 26 Jul 2007 22:59:00 -0300
Message-ID: <20070727015900.GA3000@sleipnir.redhat.com>
References: <20070725030809.GB27619@sleipnir.redhat.com>
	<1185372013.6585.73.camel@localhost>
	<20070725142824.GA24321@sleipnir.redhat.com>
	<1185373979.6585.81.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEF6Q-0001U7-W9
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 18:58:51 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEF6U-0000pf-Jp
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 18:58:55 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l6R1wlx2010223
	for <nfs@lists.sourceforge.net>; Thu, 26 Jul 2007 21:58:47 -0400
Received: from pobox-2.corp.redhat.com (pobox-2.corp.redhat.com [10.11.255.15])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l6R1wlPa031994
	for <nfs@lists.sourceforge.net>; Thu, 26 Jul 2007 21:58:47 -0400
Received: from sleipnir.redhat.com (vpn-14-147.rdu.redhat.com [10.11.14.147])
	by pobox-2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id
	l6R1wi2F008478
	for <nfs@lists.sourceforge.net>; Thu, 26 Jul 2007 21:58:46 -0400
Received: from sleipnir.redhat.com (localhost.localdomain [127.0.0.1])
	by sleipnir.redhat.com (8.13.8/8.13.7) with ESMTP id l6R1x39S004925
	for <nfs@lists.sourceforge.net>; Thu, 26 Jul 2007 22:59:04 -0300
Received: (from fleite@localhost)
	by sleipnir.redhat.com (8.13.8/8.13.8/Submit) id l6R1x1WI004922
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 22:59:01 -0300
In-Reply-To: <1185373979.6585.81.camel@localhost>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Jul 25, 2007 at 10:32:59AM -0400, Trond Myklebust wrote:
> =

> No. IMO [b;c] should be the range for the generic function, and it
> should be up to the NFS code to do the 'stored jiffies + constant
> timeout' calculation. You will note that time_in_range() does in any
> case return true if you are inside the valid time range, so you will
> usually want to do
> =

> if (!time_in_range())...
> =

> in order to do the timeout_or_wrap() test.

Tried it out and it behaves correctly. Thanks for your suggestions.
The patch below is the final version, and fixes the attribute timeout
issue with wrapping jiffies.

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ea97408..54d3926 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1852,7 +1852,7 @@ int nfs_access_get_cached(struct inode *inode, struct=
 rpc_cred *cred, struct nfs
 	cache =3D nfs_access_search_rbtree(inode, cred);
 	if (cache =3D=3D NULL)
 		goto out;
-	if (time_after(jiffies, cache->jiffies + NFS_ATTRTIMEO(inode)))
+	if (!time_in_range(jiffies, cache->jiffies, cache->jiffies + NFS_ATTRTIME=
O(inode)))
 		goto out_stale;
 	res->jiffies =3D cache->jiffies;
 	res->cred =3D cache->cred;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bca6cdc..89c3e91 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -662,7 +662,7 @@ int nfs_attribute_timeout(struct inode *inode)
 =

 	if (nfs_have_delegation(inode, FMODE_READ))
 		return 0;
-	return time_after(jiffies, nfsi->read_cache_jiffies+nfsi->attrtimeo);
+	return !time_in_range(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache=
_jiffies + nfsi->attrtimeo);
 }
 =

 /**
@@ -1061,7 +1061,7 @@ static int nfs_update_inode(struct inode *inode, stru=
ct nfs_fattr *fattr)
 		nfs_inc_stats(inode, NFSIOS_ATTRINVALIDATE);
 		nfsi->attrtimeo =3D NFS_MINATTRTIMEO(inode);
 		nfsi->attrtimeo_timestamp =3D now;
-	} else if (time_after(now, nfsi->attrtimeo_timestamp+nfsi->attrtimeo)) {
+	} else if (!time_in_range(now, nfsi->attrtimeo_timestamp, nfsi->attrtimeo=
_timestamp + nfsi->attrtimeo)) {
 		if ((nfsi->attrtimeo <<=3D 1) > NFS_MAXATTRTIMEO(inode))
 			nfsi->attrtimeo =3D NFS_MAXATTRTIMEO(inode);
 		nfsi->attrtimeo_timestamp =3D now;
diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
index c080f61..f1c87ad 100644
--- a/include/linux/jiffies.h
+++ b/include/linux/jiffies.h
@@ -115,6 +115,10 @@ static inline u64 get_jiffies_64(void)
 	 ((long)(a) - (long)(b) >=3D 0))
 #define time_before_eq(a,b)	time_after_eq(b,a)
 =

+#define time_in_range(a,b,c) \
+	(time_after_eq(a,b) && \
+	 time_before_eq(a,c))
+
 /* Same as above, but does so with platform independent 64bit types.
  * These must be used when utilizing jiffies_64 (i.e. return value of
  * get_jiffies_64() */

Cheers!
F=E1bio
-- =

ex sed lex awk yacc, e pluribus unix, amem

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Neil Brown <neilb@suse.de>
Subject: Possible jiffy wrap-around problem in NFS client.
Date: Fri, 2 Feb 2007 13:08:27 +1100
Message-ID: <17858.40219.500690.988191@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCnrD-0001gy-Hh
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 18:08:55 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HCnrE-0004pG-RZ
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 18:08:57 -0800
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


Hi Trond (and anyone else who might know...)

 I'm chasing an apparent NFS client problem, and I'm wondering if it
 could be a jiffy-wrap around problem.

 In particular, ->cache_change_attribute.

 This seems to be set to 'jiffies' only when the inode is first
 allocated, or when we have changed the file, or when a GETATTR or wcc
 shows that the file has changed.
 So if a file is unchanged on the server, cache_change_attribute will
 not change after it is first assigned.

 If the file remains in cache for 24 days (2^31 jiffies at 1000Hz),
	data_stable = nfs_verify_change_attribute(inode, fattr->time_start);
	if (data_stable)
		nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_ATIME);
 in nfs_update_inode will start clearing those flags (as
 cache_change_attribute will always be in the future) and so will
 trigger more GETATTR requests.

 Could this be correct?
 If so, what is the best fix?  Maybe somewhere central like
 nfs_update_inode we could put:

   if (time_after(nfsi->cache_change_attribute, jiffies))
		nfsi->cache_change_attributes = jiffies;

 so that we only trigger extra GETATTRS once every 3 weeks.


 This came up with a customer using SLES10 (which has very similar
 cache_change_attribute code) with several web servers serving data
 from 1 central NFS server.
 The web servers have almost everything they need in local cache, so
 the vast majority of their NFS requests are GETATTR, one for every
 'open'.  After a period of time (at least 15 days, I'm getting
 confirmation of actual time if they have it) the web servers start
 generating about twice the number of GETATTR requests, often 5 or 7
 per 'open'.

Thanks,
NeilBrown


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

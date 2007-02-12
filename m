From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 4] knfsd: fixes and enhancements for 2.6.21
Date: Mon, 12 Feb 2007 16:49:35 +1100
Message-ID: <20070212164133.26352.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGU5G-0001sv-KF
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 21:50:38 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGU5I-0001nh-9z
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 21:50:40 -0800
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

Following are 4 patchs from knfsd suitable for 2.6.21.

Numbers 3 and 4 provide new usability features that require a new
nfs-utils to make full use of (all nfs-utils will ofcourse continue to
work providing the functionality it always provided).

(3) allows a 16 byte uuid to be used to identify the filesystem rather
than the device id (which is volatile) or a 32bit number (which has to
be managed manually).  nfs-utils used libblkid to extract a uuid from
most filesystems. (Thanks Trond for reviewing this code - I hope you
like the changes).

(4) allows an upcall to be made to map a 'uid' to a list of 'gids'.
The AUTH_UNIX authentication protocol only carries 16 group ids which
causes problems for people with more than 16 group ids.

 [PATCH 001 of 4] knfsd: Fix return value for writes to some files in 'nfsd' filesystem.
 [PATCH 002 of 4] knfsd: Tidy up choice of filesystem-identifier when creating a filehandle.
 [PATCH 003 of 4] knfsd: Add some new fsid types.
 [PATCH 004 of 4] knfsd: Allow the server to provide a gid list when using AUTH_UNIX authentication.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

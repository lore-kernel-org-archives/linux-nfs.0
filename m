From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 000 of 14] knfsd: Preparation for IPv6 support in
	NFS server.
Date: Thu, 01 Feb 2007 20:50:49 -0800
Message-ID: <adahcu55fiu.fsf@cisco.com>
References: <20070202153531.18622.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCqNz-0000ic-Uj
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 20:50:56 -0800
Received: from sj-iport-6.cisco.com ([171.71.176.117])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCqO0-00055L-My
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 20:50:57 -0800
In-Reply-To: <20070202153531.18622.patches@notabene> (NeilBrown's message of
	"Fri, 2 Feb 2007 15:39:36 +1100")
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

 > They are mostly from Chuck Level and make preparating for IPv6 support
 > in the NFS server.
 > They are *not* for 2.6.20, but should be ok for .21.

Out of curiousity, does this patch series reduce the delta between the
NFS/RDMA tree and mainline Linux?  In other words does this bring
NFS/RDMA closer to merging?

 - R.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

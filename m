From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 000 of 14] knfsd: Preparation for IPv6 support in
 NFS server.
Date: Fri, 02 Feb 2007 01:02:24 -0500
Message-ID: <45C2D3F0.9050907@garzik.org>
References: <20070202153531.18622.patches@notabene> <adahcu55fiu.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCrVI-0007cC-HE
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 22:02:32 -0800
Received: from srv5.dvmed.net ([207.36.208.214] helo=mail.dvmed.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCrVH-0002WO-Bv
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 22:02:32 -0800
In-Reply-To: <adahcu55fiu.fsf@cisco.com>
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

Roland Dreier wrote:
>  > They are mostly from Chuck Level and make preparating for IPv6 support
>  > in the NFS server.
>  > They are *not* for 2.6.20, but should be ok for .21.
> 
> Out of curiousity, does this patch series reduce the delta between the
> NFS/RDMA tree and mainline Linux?  In other words does this bring
> NFS/RDMA closer to merging?

NFS/RDMA is IMO more than a little bit questionable, and the likely 
userbase is also quite small.  I'm not sure its worth a mainline merge 
at this point.

	Jeff




-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

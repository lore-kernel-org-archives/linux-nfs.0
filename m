From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 000 of 14] knfsd: Preparation for IPv6 support in
	NFS server.
Date: Fri, 2 Feb 2007 15:56:52 +1100
Message-ID: <17858.50324.772378.397661@notabene.brown>
References: <20070202153531.18622.patches@notabene> <adahcu55fiu.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCqUF-0001Q1-7o
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 20:57:23 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCqUD-0003YX-Dq
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 20:57:22 -0800
In-Reply-To: message from Roland Dreier on Thursday February 1
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

On Thursday February 1, rdreier@cisco.com wrote:
>  > They are mostly from Chuck Level and make preparating for IPv6 support
>  > in the NFS server.
>  > They are *not* for 2.6.20, but should be ok for .21.
> 
> Out of curiousity, does this patch series reduce the delta between the
> NFS/RDMA tree and mainline Linux?  In other words does this bring
> NFS/RDMA closer to merging?
> 
>  - R.

No idea.  I haven't seen any RDMA patches.  I seem to remember hearing
them mentioned some time ago, but I haven't gone looking for them.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

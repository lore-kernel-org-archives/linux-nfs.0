From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 00/19] NFS/RDMA client support
Date: Thu, 20 Sep 2007 11:20:20 -0400
Message-ID: <1190301620.6763.52.camel@heimdal.trondhjem.org>
References: <EXNANE01TIVvLVKi3s1000004af@exnane01.hq.netapp.com>
	<EXNANE010ZkfzDskqC500000565@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYNpM-0004bp-PX
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 08:20:28 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IYNpO-0007gK-26
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 08:20:33 -0700
In-Reply-To: <EXNANE010ZkfzDskqC500000565@exnane01.hq.netapp.com>
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

On Thu, 2007-09-20 at 10:57 -0400, Talpey, Thomas wrote:
> Trond - I believe the NFS/RDMA client patchset is ready for kernel
> inclusion. The one open issue of transport naming as integers, is
> compatible with the existing kernel code and user binaries. So, while
> using a string is better long-term, there are a bunch of issues and
> a fairly large patch set to get there. Since transport naming isn't
> an NFS/RDMA issue, I feel they should be considered separately.
> 
> Do you agree? If there are any remaining issues in the patchset
> already sent, I'm happy to address them.
> 

OK. Given the size of the changes, and the fact that we're in 2.6.23-rc7
(Arr') already, I'm not sure I can promise you inclusion in 2.6.24, but
I'll give the patches a review and put then into the git repository and
NFS_ALL as soon as possible.
In the worst case, we can defer the actual merging into mainline until
2.6.25...

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

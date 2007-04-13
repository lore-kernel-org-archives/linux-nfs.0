From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Merge plans for RPC/RDMA? (Was: Re: [PATCH 000 of 14] knfsd:
	Preparation for IPv6 support in NFS server.)
Date: Fri, 13 Apr 2007 16:47:20 -0400
Message-ID: <170fa0d20704131347u4a28b5d1h1959227980449fbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	Roland Dreier <rdreier@cisco.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcSfu-0003WT-PU
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 13:47:18 -0700
Received: from wx-out-0506.google.com ([66.249.82.225])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HcSfx-0002Rq-5D
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 13:47:21 -0700
Received: by wx-out-0506.google.com with SMTP id i30so1743976wxd
	for <nfs@lists.sourceforge.net>; Fri, 13 Apr 2007 13:47:20 -0700 (PDT)
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

On 2/2/07, Chuck Lever <chuck.lever@oracle.com> wrote:
> Roland Dreier wrote:
> >  > They are mostly from Chuck Level and make preparating for IPv6 support
> >  > in the NFS server.
> >  > They are *not* for 2.6.20, but should be ok for .21.
> >
> > Out of curiousity, does this patch series reduce the delta between the
> > NFS/RDMA tree and mainline Linux?  In other words does this bring
> > NFS/RDMA closer to merging?
>
> Hi Roland-
>
> The client side support for an RPC/RDMA module is almost completely
> integrated into mainline.  There is still a minimal set of patches
> required to support alternate transports in loadable kernel modules
> which Trond has indicated he will integrate when the RPC/RDMA transport
> is ready to be integrated.

Hi Chuck,

I must be missing something because I don't see _any_ trace of the
core RPC over RDMA support (xprtrdma et al), your RPC Transport
Switch, or any of the other supporting changes in mainline.  Could
you, or others, please clarify the plan for merging RPC/RDMA?

> At this time I'm not aware of a plan to integrate server-side support
> for NFS/RDMA.  Perhaps the NetApp RDMA developers could respond.

Do you mean the NFS/RDMA server code from Tom Tucker of Open Grid
Computing?  Why wouldn't this code be included?

please advise, thanks.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

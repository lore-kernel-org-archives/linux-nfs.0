From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 019 of 19] knfsd: Register all RPC programs with
	portmapper by default
Date: Fri, 1 Sep 2006 15:47:10 +0200
Message-ID: <20060901134710.GB29574@suse.de>
References: <20060901141639.27206.patches@notabene>
	<1060901043948.27677@suse.de> <44F8359D.40303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ9Ma-0002nX-6T
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 06:47:16 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ9MZ-0005OT-Jo
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 06:47:16 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <44F8359D.40303@redhat.com>
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

On Fri, Sep 01, 2006 at 09:29:01AM -0400, Peter Staubach wrote:
> While I'm thinking about it a little more, why not register NFS_ACL with
> portmap/rpcbind?  That would make it pingable via rpcinfo.

I can't say, but I dimly recall that this was intentional, and I
did not want to change this behavior. Andreas Gruenbacher should
know.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

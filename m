From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 019 of 19] knfsd: Register all RPC programs
	with	portmapper by default
Date: Fri, 01 Sep 2006 12:13:34 -0400
Message-ID: <1157127214.5632.62.camel@localhost>
References: <20060901141639.27206.patches@notabene>
	<1060901043948.27677@suse.de>
	<76bd70e30609010831m9e80cfav514d60718d35e7d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, Olaf Kirch <okir@suse.de>,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJBeS-0000Uq-JO
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:13:52 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJBeR-0000l7-Oo
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 09:13:53 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30609010831m9e80cfav514d60718d35e7d5@mail.gmail.com>
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

On Fri, 2006-09-01 at 11:31 -0400, Chuck Lever wrote:

> I don't like this.  The idea that multiple RPC services are listening
> on the same port is a total hack.  What other service might use this
> besides NFSACL?

Ermm... Any RPC server process that doesn't want to register with the
portmapper. The NFSv4 callback channel is one obvious candidate.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

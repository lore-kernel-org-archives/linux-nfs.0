From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 8/9] SUNRPC: Store formatted addresses in private
	data structure
Date: Wed, 18 Oct 2006 16:41:10 -0400
Message-ID: <76bd70e30610181341i1da2eeadw70e5098f9f421973@mail.gmail.com>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
	<20061012211521.8734.29674.stgit@ingres.dsl.sfldmi.ameritech.net>
	<1161203761.6095.137.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaIDz-0004yY-Me
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:41:15 -0700
Received: from ug-out-1314.google.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GaIDz-0001Pt-EK
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:41:16 -0700
Received: by ug-out-1314.google.com with SMTP id p27so263884ugc
	for <nfs@lists.sourceforge.net>; Wed, 18 Oct 2006 13:41:11 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1161203761.6095.137.camel@lade.trondhjem.org>
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

On 10/18/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Thu, 2006-10-12 at 17:15 -0400, Chuck Lever wrote:
> > Hide buffers that store formatted IP addresses in a private data structure
> > maintained in net/sunrpc/xprtsock.c.
>
> Why? Aren't those generic?

Not necessarily.  A transport may choose to use a dynamic algorithm to
generate the addresses, for example; in which case, it would have no
need for such buffers.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

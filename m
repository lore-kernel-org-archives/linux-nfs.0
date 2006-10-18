From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS inconsistent behaviour
Date: Wed, 18 Oct 2006 16:44:35 -0400
Message-ID: <1161204275.6095.143.camel@lade.trondhjem.org>
References: <A93BD15112CD05479B1CD204F7F1D4730513DB@exch-04.noida.hcltech.com>
	<20061016084656.GA13292@janus>
	<46465bb30610160235m211910b6g2eb074aa23060aa9@mail.gmail.com>
	<20061016093904.GA13866@janus>
	<46465bb30610171822h3f747069ge9a170f1759af645@mail.gmail.com>
	<20061018063945.GA5917@janus>
	<1161194229.6095.81.camel@lade.trondhjem.org>
	<20061018183807.GA12018@janus>
	<1161199580.6095.112.camel@lade.trondhjem.org>
	<20061018200936.GA14733@janus>
	<76bd70e30610181317w3e8315e5m75056305904a1bce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Mohit Katiyar <katiyar.mohit@gmail.com>,
	Linux NFS mailing list <nfs@lists.sourceforge.net>,
	linux-kernel@vger.kernel.org,
	Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaIHS-0005Jf-5e
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:44:52 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaIHS-0002Gx-Lm
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:44:51 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30610181317w3e8315e5m75056305904a1bce@mail.gmail.com>
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

On Wed, 2006-10-18 at 16:17 -0400, Chuck Lever wrote:
> Both client implementations (kernel and glibc) should re-use port
> numbers or connections aggressively.  To that end, the kernel RPC
> client is already doing this.  I know Red Hat has suggested using a
> connection manager for user-level RPC applications to share.  In
> addition the kernel NFS client is sharing connections to a server
> between all mount points going to that server.

IIRC, Mike Waychison did some work a couple of years ago on a userspace
daemon that managed RPC connections.

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

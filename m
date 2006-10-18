From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: NFS inconsistent behaviour
Date: Wed, 18 Oct 2006 16:17:37 -0400
Message-ID: <76bd70e30610181317w3e8315e5m75056305904a1bce@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Mohit Katiyar <katiyar.mohit@gmail.com>,
	Linux NFS mailing list <nfs@lists.sourceforge.net>,
	linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaHrG-0002lf-H3
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:17:47 -0700
Received: from ug-out-1314.google.com ([66.249.92.175])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GaHrE-0002uU-VE
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 13:17:47 -0700
Received: by ug-out-1314.google.com with SMTP id p27so258114ugc
	for <nfs@lists.sourceforge.net>; Wed, 18 Oct 2006 13:17:38 -0700 (PDT)
To: "Frank van Maarseveen" <frankvm@frankvm.com>
In-Reply-To: <20061018200936.GA14733@janus>
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

On 10/18/06, Frank van Maarseveen <frankvm@frankvm.com> wrote:
> On Wed, Oct 18, 2006 at 03:26:20PM -0400, Trond Myklebust wrote:
> > On Wed, 2006-10-18 at 20:38 +0200, Frank van Maarseveen wrote:
> > > I ran out of privileged ports due to treemounting on /net from about 50
> > > servers. The autofs program map for this uses the "showmount" command and
> > > that one apparently uses privileged ports too (buried inside RPC client
> > > libs part of glibc IIRC). The combination broke autofs and a number of
> > > other services because there were no privileged ports left anymore.
> >
> > Yeah. The RPC library appears to always try to grab a privileged port if
> > it can. One solution would be to have the autofs scripts drop all
> > privileges before calling showmount.
> >
> > I suppose we could also change the showmount program to create a socket
> > that is bound to an unprivileged port, then use
> > clnttcp_create()/clntudp_create().
> >
> > We could probably do the same in the "mount" program when doing things
> > like interrogating the portmapper, probing for rpc ports etc. The only
> > case where mount might actually need to use a privileged port is when
> > talking to mountd. Even then, it could be trained to first try using an
> > unprivileged port.
>
> If we could fix why there are that many connections in state TIME_WAIT
> then using privileged ports would not be a problem either.

Some discussion on both FreeBSD and Linux mailing lists suggests that
ignoring TIME_WAIT has some risk to it, so that may not be an
advisable path to take.  However, there are probably some cases where
it is safe, such as idle timeouts, where the client is certain there
is no traffic in flight.

Both client implementations (kernel and glibc) should re-use port
numbers or connections aggressively.  To that end, the kernel RPC
client is already doing this.  I know Red Hat has suggested using a
connection manager for user-level RPC applications to share.  In
addition the kernel NFS client is sharing connections to a server
between all mount points going to that server.

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

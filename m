From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: NFS inconsistent behaviour
Date: Wed, 18 Oct 2006 20:38:07 +0200
Message-ID: <20061018183807.GA12018@janus>
References: <A93BD15112CD05479B1CD204F7F1D4730513DB@exch-04.noida.hcltech.com>
	<46465bb30610160013v47524589g39c61465b5955f65@mail.gmail.com>
	<20061016084656.GA13292@janus>
	<46465bb30610160235m211910b6g2eb074aa23060aa9@mail.gmail.com>
	<20061016093904.GA13866@janus>
	<46465bb30610171822h3f747069ge9a170f1759af645@mail.gmail.com>
	<20061018063945.GA5917@janus>
	<1161194229.6095.81.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Mohit Katiyar <katiyar.mohit@gmail.com>,
	Linux NFS mailing list <nfs@lists.sourceforge.net>,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaGIu-00019l-VP
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 11:38:13 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GaGIs-00022S-FX
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 11:38:14 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1161194229.6095.81.camel@lade.trondhjem.org>
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

On Wed, Oct 18, 2006 at 01:57:09PM -0400, Trond Myklebust wrote:
> On Wed, 2006-10-18 at 08:39 +0200, Frank van Maarseveen wrote:
> > On Wed, Oct 18, 2006 at 10:22:44AM +0900, Mohit Katiyar wrote:
> > > I checked it today and when i issued the netstat -t ,I could see a lot
> > > of tcp connections in TIME_WAIT state.
> > > Is this a normal behaviour?
> > 
> > yes... but see below
> > 
> > > So we cannot mount and umount infinitely
> > > with tcp option? Why there are so many connections in waiting state?
> > 
> > I think it's called the 2MSL wait: there may be TCP segments on the
> > wire which (in theory) could disrupt new connections which reuse local
> > and remote port so the ports stay in use for a few minutes. This is
> > standard TCP behavior but only occurs when connections are improperly
> > shutdown. Apparently this happens when umounting a tcp NFS mount but
> > also for a lot of other tcp based RPC (showmount, rpcinfo).  I'm not
> > sure who's to blame but it might be the rpc functions inside glibc.
> > 
> > I'd switch to NFS over udp if this is problem.
> 
> Just out of interest. Why does anyone actually _want_ to keep
> mount/umounting to the point where they run out of ports? That is going
> to kill performance in all sorts of unhealthy ways, not least by
> completely screwing over any caching.

I ran out of privileged ports due to treemounting on /net from about 50
servers. The autofs program map for this uses the "showmount" command and
that one apparently uses privileged ports too (buried inside RPC client
libs part of glibc IIRC). The combination broke autofs and a number of
other services because there were no privileged ports left anymore.

So it can happen in practice.

> Note also that you _can_ change the range of ports used by the NFS
> client itself at least. Just edit /proc/sys/sunrpc/{min,max}_resvport.
> On the server side, you can use the 'insecure' option in order to allow
> mounts that originate from non-privileged ports (i.e. port > 1024).

Increasing the privileged port range in the kernel might be doable in
some cases. It might be useful to extend it to include port 2049 too.

-- 
Frank

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

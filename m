From: Seth Vidal <skvidal@phy.duke.edu>
Subject: Re: RH 7.3 kernels and NFS performance
Date: Thu, 8 Aug 2002 01:08:53 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208080106550.16997-100000@opus.phy.duke.edu>
References: <Pine.LNX.4.44.0208071142060.1462-100000@duran.unl.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.phy.duke.edu ([152.3.182.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cfXd-0001f4-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 22:08:57 -0700
To: Rex Dieter <rdieter@math.unl.edu>
In-Reply-To: <Pine.LNX.4.44.0208071142060.1462-100000@duran.unl.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

> >      > I tried primarily v3, but I think I remember testing v2 as
> >      > well, with similar results.
> > 
> > If you are getting that performance with v3, then it does indeed sound
> > like a bug somewhere. Try with a stock 2.4.19 kernel instead...
> 
> I just tested things with a test kernel (2.4.18-7) from redhat, and it 
> sync write speeds were again way up there.  Problem fixed, as far as I'm 
> concerned... hopefully, they'll release an errata soon.

look carefully - the only patches in  2.4.18-X (where X >5) are to misc 
network drivers. 2.4.18-5 with some network cards (specifically eepros and 
3c905s) were terribly slow. 2.4.18-5e+ fix it.

-sv





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

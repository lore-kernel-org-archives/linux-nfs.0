From: "Steve M. Robbins" <steven.robbins@videotron.ca>
Subject: Re: how experimental is the seekdir patch
Date: Sat, 03 May 2003 14:24:37 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030503182436.GA1613@nyongwa.montreal.qc.ca>
References: <6440EA1A6AA1D5118C6900902745938E07D55592@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relais.videotron.ca ([24.201.245.36] helo=VL-MS-MR002.sc1.videotron.ca)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19C2gi-0004J0-00
	for <nfs@lists.sourceforge.net>; Sat, 03 May 2003 12:28:48 -0700
Received: from riemann.nyongwa.montreal.qc.ca ([24.202.211.97])
 by VL-MS-MR002.sc1.videotron.ca
 (iPlanet Messaging Server 5.2 HotFix 1.10 (built Jan 23 2003))
 with ESMTP id <0HEB00GJ0PT12B@VL-MS-MR002.sc1.videotron.ca> for
 nfs@lists.sourceforge.net; Sat, 03 May 2003 14:24:37 -0400 (EDT)
In-reply-to: <6440EA1A6AA1D5118C6900902745938E07D55592@black.eng.netapp.com>
To: "Lever, Charles" <Charles.Lever@netapp.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Charles,

Thanks for the info!

On Mon, Apr 28, 2003 at 06:34:33PM -0700, Lever, Charles wrote:

> > I was having problems with mounting a filesystem exported by 
> > an IRIX server that appear to be fixed by the "seekdir.dif" 
> > patch located at
> > 
> >    http://www.fys.uio.no/~trondmy/src/2.4.21-pre6/
> >
> > According to the NFS FAQ, this problem has been known since
> > 2.4.17. Yet the patch does not appear in the 2.4.21-rc1 kernel.
> > Why not?
> 
> the seekdir patch is provided because the real cause of the
> problem (a bug in glibc) has not been addressed.

I see.  Is this tricky to fix in glibc?

> the seekdir patch will never appear in a stock Linux kernel,

Supposing the glibc got fixed.  Would the seekdir patch cause a
problem?  Is there no way that a similar kernel patch could coexist
with a fixed glibc?

-S


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

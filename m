From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: client side noac
Date: Sun, 27 Jun 2004 15:28:29 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1088364509.4295.14.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
	 <1088186851.4333.65.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
	 <1088191021.4333.75.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0406251321030.3853@harp.ngdc.noaa.gov>
	 <1088192302.4333.83.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0406261615060.10096@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BefKN-0006ur-Ij
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 12:28:35 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BefKN-0008AF-7k
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 12:28:35 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0406261615060.10096@harp.ngdc.noaa.gov>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

P=E5 lau , 26/06/2004 klokka 18:17, skreiv Ara.T.Howard:
> On Fri, 25 Jun 2004, Trond Myklebust wrote:
> > As for whether or not lookups are cached: We check the mtime of the
> > parent directory in order to find out whether or not it has changed. If
> > it has, then we do a new lookup of the file.

> so i can see how opening a file may result in a later ESTALE (mtime cachi=
ng)
> but how could open ITSELF return ESTALE?  this is the behaviour i'm seein=
g.

Read the above paragraph carefully: we check the mtime on the parent
directory in order to decide whether or not to lookup again...

That mtime value is subject to caching rules. The whole point is to
reduce the number of on-the-wire RPC calls on sane setups.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

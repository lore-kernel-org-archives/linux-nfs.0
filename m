From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: link(2) - atomic?
Date: Thu, 17 Jun 2004 17:54:40 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1087509279.4042.101.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0406171128570.31212@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bb4qJ-0007Wb-8Q
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 14:54:43 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Bb4qI-0003by-Tt
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 14:54:43 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0406171128570.31212@harp.ngdc.noaa.gov>
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

P=E5 to , 17/06/2004 klokka 13:31, skreiv Ara.T.Howard:
> is link(2) atomic on nfs filesystems?  i have a lockfile library which re=
lies
> on this fact - as i've read that it is on many lists and web pages - howe=
ver
> i've never really bothered to ask __this__ list ;-).  so, is it?  are any
> other system calls?

Yes: link() is atomic.

Ditto for open (on Linux 2.6 clients only) and symlink().

rename() would normally be atomic too, except that we have a special
case if the target is an open file: in that case, all clients tend to
"sillyrename" the target file first in order to avoid killing the
process that is using the target.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

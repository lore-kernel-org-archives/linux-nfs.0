From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: link(2) - atomic?
Date: Thu, 17 Jun 2004 16:52:42 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406171650060.520@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0406171128570.31212@harp.ngdc.noaa.gov>
 <1087509279.4042.101.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1395401557-1087512762=:520"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bb5ko-0002HH-To
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 15:53:06 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Bb5ko-0006Bi-Hy
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 15:53:06 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1087509279.4042.101.camel@lade.trondhjem.org>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1395401557-1087512762=:520
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 17 Jun 2004, Trond Myklebust wrote:

> P=E5 to , 17/06/2004 klokka 13:31, skreiv Ara.T.Howard:
>> is link(2) atomic on nfs filesystems?  i have a lockfile library which r=
elies
>> on this fact - as i've read that it is on many lists and web pages - how=
ever
>> i've never really bothered to ask __this__ list ;-).  so, is it?  are an=
y
>> other system calls?
>
> Yes: link() is atomic.
>
> Ditto for open (on Linux 2.6 clients only) and symlink().
>
> rename() would normally be atomic too, except that we have a special
> case if the target is an open file: in that case, all clients tend to
> "sillyrename" the target file first in order to avoid killing the
> process that is using the target.
>
> Cheers,
>  Trond

thanks alot trond,

by

> Ditto for open (on Linux 2.6 clients only) and symlink().

do you mean

   0)
     open    =3D> atomic 2.6 only
     symlink =3D> atomic 2.6 only

or

   1)
     open    =3D> atomic 2.6 only
     symlink =3D> atomic all kernels

??

-a
--
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it; and a weed grows, even though we =
do
| not love it. --Dogen
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
--8323328-1395401557-1087512762=:520--


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

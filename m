From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Re: more on silly names
Date: Sat, 4 Sep 2004 18:15:04 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0409041813340.17016@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0409041610230.17016@harp.ngdc.noaa.gov>
 <1094338737.13791.15.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1724085044-1094343304=:17016"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C3kgb-0000pR-Dq
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 17:15:13 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C3kgV-0004Pf-VS
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 17:15:11 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094338737.13791.15.camel@lade.trondhjem.org>
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

--8323328-1724085044-1094343304=:17016
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 4 Sep 2004, Trond Myklebust wrote:

> P=E5 lau , 04/09/2004 klokka 18:27, skreiv Ara.T.Howard:
>> i think i've found the cause of the sillnames appearing in my directory:
>> for transaction sqlite aquires a lock, writes changes first to a db-jour=
nal
>> file, then to the actual db, closes the journal, unlinks the journal, an=
d
>> releases the lock.  this sequence should not create a silly file, but se=
ems
>> to do so:
>
> I believe that the Berkeley database code uses mmap() to read/write the
> data, in which case close() will not actually suffice to sync the data
> to the server (unlike the case of ordinary file write).
>
> If mmapped data needs to be committed to disk before the flushd/pdflush
> daemon gets round to doing it, you need to explicitly call msync().

it's sqlite - not berkeley db - so there is no mmap'ing at all going on
(confirmed by strace).

i've been able to reproduce the problem with a single client using the
database - eg. the client causes a sillyname on one of it's own files via t=
he
sequence i outlined before.

-a
--
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it;
| and a weed grows, even though we do not love it.=20
|   --Dogen
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
--8323328-1724085044-1094343304=:17016--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: read-error on utmp file
Date: Tue, 7 Sep 2004 11:21:04 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0409071120350.17332@harp.ngdc.noaa.gov>
References: <41383991.1020108@bio.ifi.lmu.de>  <1094230320.8196.32.camel@lade.trondhjem.org>
  <413C0F25.9010206@bio.ifi.lmu.de> <1094490287.8342.69.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-976443041-1094577664=:17332"
Cc: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4jeg-0005QV-Pm
	for nfs@lists.sourceforge.net; Tue, 07 Sep 2004 10:21:18 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C4jee-0007m8-GX
	for nfs@lists.sourceforge.net; Tue, 07 Sep 2004 10:21:17 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094490287.8342.69.camel@lade.trondhjem.org>
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

--8323328-976443041-1094577664=:17332
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 6 Sep 2004, Trond Myklebust wrote:

> P=E5 m=E5 , 06/09/2004 klokka 03:17, skreiv Frank Steiner:
>
>> tcpdump -s 9000 -w <file> host curry & while runlevel /boot/utmp; do tru=
e; done; killall tcpdump
>>
>> and started the second loop in another window which caused this first lo=
op
>> to fail and stop the tcpdump...
>
> Ah, right... Sorry, my head hasn't been screwed on correctly...
>
> Although we wait on writes, we don't bother to wait on all *reads* to
> complete when closing the file. This means that readahead (which can
> schedule extra pageins asynchronously) may end up causing the file to be
> kept open for longer.
>
> That is why you are seeing sillyrenames here...

do you think this could contribute to my situation with sillyrenames too?

cheers.

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
--8323328-976443041-1094577664=:17332--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

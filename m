From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: binaries becoming corrupt on nfs
Date: Mon, 14 Mar 2005 16:00:23 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0503141557210.7704@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
 <1110835899.19295.42.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0503141434390.4702@harp.ngdc.noaa.gov>
 <1110836857.24466.4.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0503141456140.4702@harp.ngdc.noaa.gov>
  <1110838426.24466.17.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0503141521510.4702@harp.ngdc.noaa.gov>
 <1110840571.24466.52.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1400135742-1110841223=:7704"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAyY3-00060O-Iv
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 15:00:31 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAyY3-000308-5s
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 15:00:31 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110840571.24466.52.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

--8323328-1400135742-1110841223=:7704
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 14 Mar 2005, Trond Myklebust wrote:

> m=E5 den 14.03.2005 Klokka 15:24 (-0700) skreiv Ara.T.Howard:
>>> On Linux-2.4.x, mmap() will prevent the NFS client from clearing the ca=
che
>>> in a timely fashion, and so pages that should have been thrown out of c=
ache
>>> may become "frozen in" to the cache.
>>
>> you mean ANY mmap - or one of the file in question?  i do a LOT of memor=
y
>> mapping - sometimes of nfs mounted files, though generally only when tes=
ting
>> some command or something.  our production jobs always copy data locally
>> before working on it...  now i'm worried that i could cause this by mmap=
'ing
>> nfs mounted files!
>
> I mean an mmap of the file in question. In the case of an executable
> then you should note that the kernel will mmap() the file whenever you
> run it.

o.k. - so my mmap of data are only most stupid and this is out of my contro=
l.
i put what you meant together while i waiting for your response.  it seems =
the
right answer then is to install using

   cp a.out bindir/a.out.tmp && mv bindir/a.out.tmp bindir/a.out

or perhaps 'install' is good enough since it unlinks the dest first.  boy -
you learn something every day.

of course the best thing would be to move to a 2.6 kernel - gotta love the
fact that we are paying for a 2.4 one...

thanks for the help - it must be quite late there.

cheers.

-a
--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
--8323328-1400135742-1110841223=:7704--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

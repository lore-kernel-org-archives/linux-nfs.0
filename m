From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: binaries becoming corrupt on nfs
Date: Mon, 14 Mar 2005 15:24:36 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0503141521510.4702@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
 <1110835899.19295.42.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0503141434390.4702@harp.ngdc.noaa.gov>
 <1110836857.24466.4.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0503141456140.4702@harp.ngdc.noaa.gov>
 <1110838426.24466.17.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-891771843-1110839076=:4702"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAxzR-0004WH-GW
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 14:24:45 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAxzR-0006hh-3d
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 14:24:45 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110838426.24466.17.camel@lade.trondhjem.org>
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

--8323328-891771843-1110839076=:4702
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 14 Mar 2005, Trond Myklebust wrote:

> m=E5 den 14.03.2005 Klokka 14:59 (-0700) skreiv Ara.T.Howard:
>> On Mon, 14 Mar 2005, Trond Myklebust wrote:
>>
>>> That was why I asked. If you update the binaries by copying into them (=
not
>>> renaming + creating new file), then strange things will happen: you wil=
l not
>>> see ESTALE, but you will usually see cache corruption.
>>
>> hmmm.  i HAVE compiled these binaries and copied them up - but last week=
=2E
>> coud that make the cache so sick that it would not recover?
>
> On Linux-2.4.x, mmap() will prevent the NFS client from clearing the cach=
e
> in a timely fashion, and so pages that should have been thrown out of cac=
he
> may become "frozen in" to the cache.

you mean ANY mmap - or one of the file in question?  i do a LOT of memory
mapping - sometimes of nfs mounted files, though generally only when testin=
g
some command or something.  our production jobs always copy data locally
before working on it...  now i'm worried that i could cause this by mmap'in=
g
nfs mounted files!

> In Linux-2.6.x, that problem should hopefully have been fixed due to a
> combination of updates to the memory management layer + NFS client fixes.

man - why can't the redhat guys send out a 'modern' kernel - it's not like =
we
aren't paying for it... arghh.

thanks for helping out (again.)

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
--8323328-891771843-1110839076=:4702--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

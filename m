From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: binaries becoming corrupt on nfs
Date: Mon, 14 Mar 2005 14:40:07 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0503141434390.4702@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
 <1110835899.19295.42.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-298031214-1110836407=:4702"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAxIP-0002CN-8T
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:40:17 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAxIO-0002Ur-RN
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:40:17 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110835899.19295.42.camel@lade.trondhjem.org>
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

--8323328-298031214-1110836407=:4702
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 14 Mar 2005, Trond Myklebust wrote:

> m=E5 den 14.03.2005 Klokka 14:25 (-0700) skreiv Ara.T.Howard:
>> we are seeing some really bizarre strange behaviour on our nfs systems.
>> essentially a system will hum along nicely, running binaries from our nf=
s
>> server without issue.  for no apparent reason these binaries suddenly be=
come
>> corrupt on the client side and stop working.  running md5sum on the affe=
cted
>> binary on a 'good' host and a 'bad' one shows them to, in fact, be diffe=
rent.
>>
>> doing and unmount and remount fixes the issue.  obviously so does a rebo=
ot.
>> both are temporary fixes though - eventually a node will start getting c=
orrupt
>> binaries - or perhaps not.
>
> Do you perhaps have some cronjob or something that is updating the binari=
es
> on the server?

absolutely nothing.  bear in mind we are not seeing stale file handles - th=
e
binaries are truely corrupt.  very, very weird things will happen:

   * maybe the binaries core dump on startup
   * maybe it runs, but errors in strange ways
   * maybe it runs, but core dumps
   * sometimes it can be loaded into a debugger - sometimes not

never is it given stale file handles though...

btw.  i forgot to show our mount options:

   nfs  bg,rw,hard,intr,rsize=3D8192,wsize=3D8192

and that's it.

ps. i just had to point out to our sysads, who are big fans of rhn, that yo=
u
just got back to me in under two minutes!  amazing ;-) !

kind regards.

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
--8323328-298031214-1110836407=:4702--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

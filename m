From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: debugging hanging locks
Date: Mon, 16 Aug 2004 18:51:22 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408161846440.5649@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0408161741020.5649@harp.ngdc.noaa.gov>
 <1092702159.11722.77.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1404923101-1092703882=:5649"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BwsEb-0006OU-HM
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 17:53:53 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BwsCg-0008Df-FU
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 17:53:53 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1092702159.11722.77.camel@lade.trondhjem.org>
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

--8323328-1404923101-1092703882=:5649
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 16 Aug 2004, Trond Myklebust wrote:

> P=E5 m=E5 , 16/08/2004 klokka 19:47, skreiv Ara.T.Howard:
>
>> which, i imagine, leaves some phantom process/lock hanging around with t=
he old
>> file handle.  my questions are
>>
>>    - what could cause this type of random hanging
>
> a client that fails to clean up after itself.

the lock/unlock method is wrapped in a try/catch block - eg. only 'kill -9'
could cause failure to unlock.  if i assume this to be the case - then what
else can be done?  will sending -9 always cause this?  will it ever
automatically resolve itself?  i was under the impression that a process wo=
uld
clean up fcntl locks on death anyhow - i am obviously mistaken, but to what
degree?


>>    - how does one tell, on server, who has what locks
>
> Not much you can do beyond 'cat /proc/locks'. That will tell you whether =
or
> not a lock is held, and will also give you the pid of the remote process
> that holds the lock (in the 4th column).

good enough - thanks for the tip.  btw.  where would i find this info?  i
pokeda around the docs/man pages and it was not obvious.

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
--8323328-1404923101-1092703882=:5649--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

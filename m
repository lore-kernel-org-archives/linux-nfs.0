From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: extremely bad locking performance on 2.4.21-15.0.4.EL
Date: Mon, 16 Aug 2004 16:41:40 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408161638530.5649@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0408161440170.4655@harp.ngdc.noaa.gov>
 <1092695033.11722.37.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1310310947-1092696100=:5649"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BwqDb-0005b7-5o
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 15:44:43 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BwqB6-0000SD-GM
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 15:44:43 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1092695033.11722.37.camel@lade.trondhjem.org>
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

--8323328-1310310947-1092696100=:5649
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 16 Aug 2004, Trond Myklebust wrote:

> P=E5 m=E5 , 16/08/2004 klokka 17:17, skreiv Ara.T.Howard:
>
>> in otherwords the nodes will get the lock at a very rapid rate and then
>> experience a 30s timeout... is this normal?
>
> 30s is of the order of a soft timeout. I would guess it probably means
> that something is going wrong with the GRANTED callback. Have you tried
> turning on rpc_debug on the client? Use something like
>
> sysctl -w sunrpc.rpc_debug=3D10
> or
> echo "10" >/proc/sys/sunrpc/rpc_debug
>
> Note: thinking about this, I suspect that the 2.6 kernel is very likely
> to have a similar problem due to the existance of the svcauth_unix.c
> domain stuff. (That all belongs deep in the bowels of nfsd - not in the
> RPC code). That can't be affecting the 2.4 kernel, though.


i will look into this pronto... next problem:

calls to fcntl64 are hanging when files have been opened with O_LARGEFILE!
looking at this

http://rhn.redhat.com/errata/RHSA-2004-413.html

which is the upgrade we (sysads) just applied makes me more than a little
suspect...

at the momment i can replicate the problem using ruby/perl - working on a c
program...

anyone know where O_LARGEFILE is defined?


regards.

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
--8323328-1310310947-1092696100=:5649--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

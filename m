From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: combined ac/noac mounts
Date: Thu, 2 Sep 2004 18:56:48 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0409021853100.1684@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0409021822160.1684@harp.ngdc.noaa.gov>
 <1094172012.26067.21.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1042526758-1094173008=:1684"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C32Np-0002YV-SF
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 17:56:53 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C32No-0003EP-Lc
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 17:56:53 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094172012.26067.21.camel@lade.trondhjem.org>
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

--8323328-1042526758-1094173008=:1684
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 2 Sep 2004, Trond Myklebust wrote:

> P=E5 to , 02/09/2004 klokka 20:25, skreiv Ara.T.Howard:
>> if one exports a file system and also does a sub-export of that file sys=
tem
>> from a server and a client has two mounts to that system: one noac and o=
ne
>> 'ac' - will accesses to files via the various paths do the 'right thing'=
=2E  eg.
>> accesses via the noac path will hit the server while accesses via the 'a=
c'
>> mount will try to use the cache?
>
> No. "noac" is *NOT* the same thing as directIO.

let me rephrase - the __attribute__ cache.  i was to set up a subdirectory =
in
an already existing partion where i can know that inode checks are correct.

what is directIO - all operations sent to server and committed back?  sound=
s
like a good thing for doing crazy stuff like accessing an sqlite database f=
rom
30 nodes at once huh?  in general, what would the __safest__ export/mount
setup be?  would it kill performance that greatly accessing an approx. 40MB
file once every minute or so from 30 clients?

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
--8323328-1042526758-1094173008=:1684--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: client side noac
Date: Fri, 25 Jun 2004 13:31:26 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406251321030.3853@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
 <1088186851.4333.65.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
 <1088191021.4333.75.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-909775283-1088191886=:3853"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdwQA-0004NC-0b
	for nfs@lists.sourceforge.net; Fri, 25 Jun 2004 12:31:34 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BdwQ9-0003H4-IX
	for nfs@lists.sourceforge.net; Fri, 25 Jun 2004 12:31:33 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1088191021.4333.75.camel@lade.trondhjem.org>
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

--8323328-909775283-1088191886=:3853
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 25 Jun 2004, Trond Myklebust wrote:

> P=E5 fr , 25/06/2004 klokka 14:59, skreiv Ara.T.Howard:
>
>> what i mean is, suprising things can raise ESTALE (i'm using an exceptio=
n
>> based language that maps errno to exceptions - ruby)
>

> If the server is acting sanely, the only thing that can cause an ESTALE
> to occur is if a file gets deleted from some process on another client.

yes this is what is happening.

> Unless you are playing really silly games (allowing other clients to
> delete *open* files from underneath you)

no silly games: all access to the file in question is gaurded via a lockfil=
e
(link(2)) and an fcntl based exclusive lock placed on the lockfile itself t=
o
prevent open->lock race conditions.  eg:

   f =3D create_lockfile    # external lock 1
   f.lockf                # external lock 2

   ...
   open file_in_question  # access file - throws ESTALE
   ...
   on_some_conditions_file_is_deleted
   ...

   f.unlock
   destroy_lockfile f

no read locks are ever used, and the file format itself is sensitive to
corruption and i am seeing none.  therefore, i'm as confident as i can be t=
hat
no two processes are accessing the file at the same moment in time.  howeve=
r,
as the above shows, sometimes the file is deleted within the confines of th=
e
double lock.  i think what is happening is that the nfs client is caching i=
nfo
about the file_in_question between invocations.  i assumed that a call to o=
pen
would flush the cache - i am not maintaining an open file handle across
invocations - the file is closed each time, also within the confines of the
lock.

> , you should usually be able to get round that problem by turning off
> attribute caching on the parent directories: acdirmin=3Dacdirmax=3D0.

i am unfamiliar with that option but will read about it and fwd to my
sysad....

>
> Cheers,
>  Trond
>

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
--8323328-909775283-1088191886=:3853--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

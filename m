From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: client side noac
Date: Sun, 27 Jun 2004 21:55:19 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406272148170.31370@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
 <1088186851.4333.65.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
  <1088191021.4333.75.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0406251321030.3853@harp.ngdc.noaa.gov>
 <1088192302.4333.83.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0406261615060.10096@harp.ngdc.noaa.gov>
 <1088364509.4295.14.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1749313679-1088394919=:31370"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BenEs-0005Xf-Bv
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 20:55:26 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BenEr-0001g3-VW
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 20:55:26 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1088364509.4295.14.camel@lade.trondhjem.org>
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

--8323328-1749313679-1088394919=:31370
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sun, 27 Jun 2004, Trond Myklebust wrote:

> P=E5 lau , 26/06/2004 klokka 18:17, skreiv Ara.T.Howard:
>> On Fri, 25 Jun 2004, Trond Myklebust wrote:
>>> As for whether or not lookups are cached: We check the mtime of the
>>> parent directory in order to find out whether or not it has changed. If
>>> it has, then we do a new lookup of the file.
>
>> so i can see how opening a file may result in a later ESTALE (mtime cach=
ing)
>> but how could open ITSELF return ESTALE?  this is the behaviour i'm seei=
ng.
>
> Read the above paragraph carefully: we check the mtime on the parent
> directory in order to decide whether or not to lookup again...
>
> That mtime value is subject to caching rules. The whole point is to
> reduce the number of on-the-wire RPC calls on sane setups.
>
> Cheers,
>  Trond

i understand what you are saying.  i guess i should clarify by saying "i do=
n't
understand _why_ open itself should return ESTALE".  i mean, in the case of=
 a
read or write the client cannot know what action to take.  in this case it
seems like the client certainly can: make an RPC call.  i realize the desig=
n
emphsizes making the minumum number of calls, but this seems like one too f=
ew
doesn't it?  i really don't know the code at all so please forgive me if th=
is
sounds stupid: but why, upon finding a statle filehandle, is it deemed bett=
er
to return this known bad value instead of checking for a newer (and still
possibly bad) one?  are there certain conditions which warrant this behavio=
ur?

more to the point, this is what i'm doing in my code

   fd =3D
     begin
       open path
     rescue Errno::ESTALE
       open path
     end

in otherwords - if ESTALE is found on open, try once more.  this seems to
work.  should i not be doing this?  if i should, why shouldn't the nfs clie=
nt
code do it for me?

thanks for the help understanding this matter.

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
--8323328-1749313679-1088394919=:31370--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

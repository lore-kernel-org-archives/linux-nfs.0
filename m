From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: client side noac
Date: Fri, 25 Jun 2004 12:59:22 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406251252570.3683@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0406251148570.3197@harp.ngdc.noaa.gov>
 <1088186851.4333.65.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1596991269-1088189962=:3683"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bdvv8-000798-8M
	for nfs@lists.sourceforge.net; Fri, 25 Jun 2004 11:59:30 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Bdvv7-0005u2-Rn
	for nfs@lists.sourceforge.net; Fri, 25 Jun 2004 11:59:29 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1088186851.4333.65.camel@lade.trondhjem.org>
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

--8323328-1596991269-1088189962=:3683
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 25 Jun 2004, Trond Myklebust wrote:

> P=E5 fr , 25/06/2004 klokka 13:49, skreiv Ara.T.Howard:
>> is there any way for user code to make nfs file handles behave as if the=
y were
>> mounted noac?
>
> I don't understand the question.
>
> Filehandles are used as the unique identifier of a file. If a filehandle
> changes, it is considered to belong to a different file. In consequence,
> the only time you can revalidate a filehandle is at file lookup time.
>
> Cheers,
>  Trond

hi trond-

what i mean is, suprising things can raise ESTALE (i'm using an exception
based language that maps errno to exceptions - ruby)

for example

   - File::copy src, dest
   - open path, 'r'

to get around this i have a method, 'uncache', which:

   - opens a file, retrying one time if this returns ESTALE
   - applies a non-blocking shared fcntl lock to file
   - links the file to a unique name, rm's name
   - does a chmod file to current mode
   - does a utime file to current file's utime

this is every thing i know of which could possibly invalidate the attribute
cache.

this seems to work but it's a performance KILLER.  i'm exploring keeping
certain files (in this case an nfs accessed object database work queue) on =
a
fs exported/mounted noac and sync to get around some problems my code is
having.  my code is very fault tolerant now and deals errors quite graceful=
ly
- i've fed about 50,000 jobs through my queue with no errors - but i wonder=
ing
if their are more elegant approaches.

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
--8323328-1596991269-1088189962=:3683--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
